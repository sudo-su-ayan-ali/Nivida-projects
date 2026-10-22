import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_saver/file_saver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'erp_backup_tables.dart';

/// Ek table ka export/import result — kitni rows gayi, ya kya error aayi.
class ErpTableResult {
  final String table;
  int rows = 0;
  String? error;
  /// Row-level failures from the import RPC — e.g. FK violations,
  /// bad data — captured individually instead of failing the whole table.
  List<Map<String, dynamic>> rowErrors = [];
  ErpTableResult(this.table);
}

class ErpBackupOutcome {
  final List<ErpTableResult> tables = [];
  int get totalRows => tables.fold(0, (a, b) => a + b.rows);
  List<ErpTableResult> get failed =>
      tables.where((t) => t.error != null).toList();
}

/// Poore ERP ka Excel export/import engine.
/// Har table ka apna sheet — file me kabhi bhi ek hi baar me
/// [ErpBackupTables.all] ke saare tables process hote hain.
class ErpBackupService {
  final _client = Supabase.instance.client;

  static const int _pageSize = 1000; // Supabase ek call me max rows deta hai
  static const int _upsertBatchSize = 500;

  Future<String?> _currentInstitutionId() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', uid)
          .maybeSingle();
      return row?['institution_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ======================= EXPORT =======================

  Future<ErpBackupOutcome> exportAllToExcel({
    void Function(String table, int done, int total)? onProgress,
  }) async {
    final outcome = ErpBackupOutcome();
    final institutionId = await _currentInstitutionId();
    final workbook = xls.Excel.createExcel();

    final tables = ErpBackupTables.all;
    for (var i = 0; i < tables.length; i++) {
      final table = tables[i];
      onProgress?.call(table, i + 1, tables.length);
      final tr = ErpTableResult(table);
      try {
        final rows = await _fetchAllRows(table, institutionId);
        _writeDataSheet(workbook, table, rows);
        tr.rows = rows.length;
      } catch (e) {
        tr.error = e.toString();
        _writeNoteSheet(workbook, table, 'EXPORT FAILED: $e');
      }
           outcome.tables.add(tr);
      await Future.delayed(Duration.zero); // browser ko repaint ka moka do
    }

    // Excel package ek default 'Sheet1' bana deta hai — hata do.
    if (workbook.sheets.length > 1 && workbook.sheets.containsKey('Sheet1')) {
      workbook.delete('Sheet1');
    }

    final bytes = workbook.encode();
    if (bytes == null) throw Exception('Excel file generate nahi ho payi');

    final fileName =
        'EduSmart_Full_Backup_${DateTime.now().toIso8601String().split("T").first}';
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes),
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    return outcome;
  }

  Future<List<Map<String, dynamic>>> _fetchAllRows(
    String table,
    String? institutionId,
  ) async {
    final all = <Map<String, dynamic>>[];
    int from = 0;
    while (true) {
      final to = from + _pageSize - 1;
       List data;
      try {
        var filterBuilder = _client.from(table).select();
        if (institutionId != null) {
          filterBuilder = filterBuilder.eq('institution_id', institutionId);
        }
        data = await filterBuilder.range(from, to) as List;
      } on PostgrestException catch (e) {
        // Is table me 'institution_id' column hi nahi hai — bina filter dobara try karo.
        if (institutionId != null &&
            (e.code == '42703' || e.message.contains('institution_id'))) {
          data = await _client.from(table).select().range(from, to) as List;
        } else {
          rethrow;
        }
      }
      all.addAll(data.cast<Map<String, dynamic>>());
      if (data.length < _pageSize) break;
      from += _pageSize;
    }
    return all;
  }

  void _writeDataSheet(
    xls.Excel workbook,
    String table,
    List<Map<String, dynamic>> rows,
  ) {
    final sheet = workbook[table];
    if (rows.isEmpty) {
      sheet.appendRow([xls.TextCellValue('(no data)')]);
      return;
    }
    final columns = rows.first.keys.toList();
    sheet.appendRow(columns.map((c) => xls.TextCellValue(c)).toList());
    for (final row in rows) {
      sheet.appendRow(columns.map((c) => _toCellValue(row[c])).toList());
    }
  }

  void _writeNoteSheet(xls.Excel workbook, String table, String note) {
    final sheet = workbook[table];
    sheet.appendRow([xls.TextCellValue(note)]);
  }

  xls.CellValue _toCellValue(dynamic v) {
    if (v == null) return xls.TextCellValue('');
    if (v is int) return xls.IntCellValue(v);
    if (v is double) return xls.DoubleCellValue(v);
    if (v is bool) return xls.BoolCellValue(v);
    if (v is Map || v is List) return xls.TextCellValue(jsonEncode(v));
    return xls.TextCellValue(v.toString());
  }

  // ======================= IMPORT =======================

  Future<ErpBackupOutcome> importFromExcelBytes(
    Uint8List bytes, {
    void Function(String table, int done, int total)? onProgress,
  }) async {
    final workbook = xls.Excel.decodeBytes(bytes);
    final outcome = ErpBackupOutcome();
    final institutionId = await _currentInstitutionId();

    // Sirf wahi tables jinke sheet file me maujood hain, aur humari
    // known order me (parent-first).
    var pending = <String>[
      for (final t in ErpBackupTables.all)
        if (workbook.sheets.containsKey(t)) t,
    ];

    int pass = 1;
    while (pending.isNotEmpty && pass <= 3) {
      final stillFailing = <String>[];
      for (var i = 0; i < pending.length; i++) {
        final table = pending[i];
        onProgress?.call('$table (pass $pass)', i + 1, pending.length);

        final tr = outcome.tables.firstWhere(
          (t) => t.table == table,
          orElse: () {
            final n = ErpTableResult(table);
            outcome.tables.add(n);
            return n;
          },
        );

        try {
          final sheet = workbook.sheets[table] ?? (workbook.tables.containsKey(table) ? workbook.tables[table] : null);
          if (sheet == null) {
            continue;
          }
          final parsedRows = _sheetToMaps(sheet);
          if (parsedRows.isEmpty) {
            tr
              ..rows = 0
              ..rowErrors = []
              ..error = null;
            continue;
          }

          // Check if sheet has required columns defined in ErpBackupTables
          final requiredCols = ErpBackupTables.requiredColumnsPerTable[table];
          if (requiredCols != null && requiredCols.isNotEmpty) {
            final validRows = <Map<String, dynamic>>[];
            final rowErrors = <Map<String, dynamic>>[];
            for (var idx = 0; idx < parsedRows.length; idx++) {
              final r = parsedRows[idx];
              final missing = requiredCols.where((col) => r[col] == null || r[col].toString().trim().isEmpty).toList();
              if (missing.isNotEmpty) {
                rowErrors.add({
                  'table': table,
                  'row_index_in_batch': idx + 1,
                  'error': 'Missing required column(s): ${missing.join(", ")}',
                  'sqlstate': '23502',
                });
              } else {
                validRows.add(r);
              }
            }

            if (validRows.isEmpty) {
              tr
                ..rows = 0
                ..rowErrors = rowErrors
                ..error = '${rowErrors.length} row(s) missing required columns — skipped';
              continue;
            }
            parsedRows.clear();
            parsedRows.addAll(validRows);
            tr.rowErrors.addAll(rowErrors);
          }

          if (ErpBackupTables.tablesWithoutInstitutionId.contains(table)) {
            // Standalone tables (jaise tp_syllabus_chapters) me DB side institution_id
            // column exist hi nahi karta. Agar sheet me galti se column aa gaya ho to strip karo.
            for (final r in parsedRows) {
              r.removeWhere((k, _) => k.trim().toLowerCase() == 'institution_id');
            }
          } else if (institutionId != null) {
            // SECURITY: har tenant-owned row par current institution_id
            // force karo — chahe backup file me koi aur (galat/purani)
            // institution_id kyun na ho, ya column ho hi na. Excel me
            // ye column na hone par bhi add karna zaroori hai, kyunki
            // kai tables me institution_id NOT NULL hai aur uska koi
            // DB-side default nahi hai.
            for (final r in parsedRows) {
              r['institution_id'] = institutionId;
            }
          }

          // Tables jisme 'id' GENERATED ALWAYS AS IDENTITY hai (jaise 'teachers'),
          // unme se 'id' column hatana zaroori hai warna Postgres SQLState 428C9 throw
          // karta hai. Case-insensitive aur whitespace-insensitive check lagao.
          if (ErpBackupTables.tablesWithGeneratedIdentity.contains(table)) {
            for (final r in parsedRows) {
              r.removeWhere((k, _) => k.trim().toLowerCase() == 'id');
            }
          }

          final batchResult = await _upsertInBatches(table, parsedRows);
          tr
            ..rows = (tr.rows) + batchResult.successCount
            ..rowErrors.addAll(batchResult.errors)
            ..error = (tr.rowErrors.isEmpty)
                ? null
                : '${tr.rowErrors.length} row(s) failed — see rowErrors';
          // Ab har row apna result khud carry karta hai (RPC ke andar),
          // isliye "poora table fail" retry pass ki zaroorat nahi.
        } catch (e) {
          tr.error = e.toString();
          stillFailing.add(table);
        }
        await Future.delayed(Duration.zero); // browser ko repaint ka moka do
      }

      pending = stillFailing;
      pass++;
    }

    return outcome;
  }

  List<Map<String, dynamic>> _sheetToMaps(xls.Sheet sheet) {
    final allRows = sheet.rows;
    if (allRows.length < 2) return [];
    final headerRow = allRows[0];
    final headers = headerRow
        .map((c) => c?.value?.toString().trim() ?? '')
        .toList();
    if (headers.length == 1 &&
        (headers.first == '(no data)' ||
            headers.first.startsWith('EXPORT FAILED'))) {
      return [];
    }

    final result = <Map<String, dynamic>>[];
    for (var r = 1; r < allRows.length; r++) {
      final row = allRows[r];
      final map = <String, dynamic>{};
      for (var c = 0; c < headers.length; c++) {
        if (headers[c].isEmpty) continue;
        final cell = c < row.length ? row[c] : null;
        map[headers[c]] = _fromCellValue(cell?.value);
      }
      result.add(map);
    }
    return result;
  }

  dynamic _fromCellValue(xls.CellValue? v) {
    if (v == null) return null;
    if (v is xls.IntCellValue) return v.value;
    if (v is xls.DoubleCellValue) return v.value;
    if (v is xls.BoolCellValue) return v.value;

    final s = v is xls.TextCellValue ? v.value.toString() : v.toString();
    if (s.isEmpty) return null;

    // jsonb/array columns wapas Map/List me decode karne ki koshish.
    if ((s.startsWith('{') && s.endsWith('}')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      try {
        return jsonDecode(s);
      } catch (_) {
        return s;
      }
    }
    return s;
  }

  /// [admin_import_rows] Postgres RPC (security definer) ko call karta hai —
  /// isse normal frontend RLS bypass ho jaata hai lekin server-side auth +
  /// institution-scoping + table whitelist checks lagi rehti hain. Har row
  /// apni khud ki success/failure return karta hai, isliye ek bad row poore
  /// batch/table ko fail nahi karti.
  Future<_BatchResult> _upsertInBatches(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    final result = _BatchResult();
    if (rows.isEmpty) return result;
    final conflictKey = ErpBackupTables.conflictKeyFor(table);

    for (var i = 0; i < rows.length; i += _upsertBatchSize) {
      final end = (i + _upsertBatchSize > rows.length)
          ? rows.length
          : i + _upsertBatchSize;
      final batch = rows.sublist(i, end);

      try {
        final response = await _client.rpc('admin_import_rows', params: {
          'p_table': table,
          'p_rows': batch,
          'p_conflict_key': conflictKey,
        });

        final map = response as Map<String, dynamic>;
        var batchSuccess = (map['success_count'] as num?)?.toInt() ?? 0;
        final errs = (map['errors'] as List?) ?? [];
        for (final e in errs) {
          final sqlstate = e['sqlstate']?.toString() ?? '';
          final errMsg = e['error']?.toString() ?? '';
          final rowIdx = (e['row_index'] as num?)?.toInt() ?? 1;

          // SPECIAL HANDLING: students table immutability trigger
          // Agar existing enrolled student row update ho rahi ho aur trigger P0001
          // "cannot be changed after enrollment" throw kare, to us row ko
          // direct ignore-duplicates upsert se safely preserve/insert attempt karo.
          if (table == 'students' &&
              sqlstate == 'P0001' &&
              errMsg.contains('cannot be changed after enrollment')) {
            try {
              final targetRow = (rowIdx >= 1 && rowIdx <= batch.length)
                  ? batch[rowIdx - 1]
                  : null;
              if (targetRow != null) {
                await _client.from('students').upsert(
                      [targetRow],
                      onConflict: conflictKey,
                      ignoreDuplicates: true,
                    );
                batchSuccess += 1;
                continue; // Error list me mat dalo — safely handled
              }
            } catch (_) {
              // Ignore failure, let original error be logged below
            }
          }

          result.errors.add({
            'table': table,
            'row_index_in_batch': rowIdx,
            'error': errMsg,
            'sqlstate': sqlstate,
          });
        }
        result.successCount += batchSuccess;
      } on PostgrestException catch (pe) {
        // Agar database me purana RPC version chal raha ho jisme ye table whitelist
        // me nahi tha (e.g. tp_syllabus_chapters, hr_tax_records), to seedha table
        // par standard upsert fallback attempt karo.
        if (pe.code == 'P0001' && pe.message.contains('is not allowed for import')) {
          try {
            // Agar table bina institution_id wali hai, to fallback batch me se bhi
            // institution_id hatana ensure karo taaki PostgREST schema cache PGRST204 na throw kare.
            final cleanBatch = ErpBackupTables.tablesWithoutInstitutionId.contains(table)
                ? batch.map((r) {
                    final c = Map<String, dynamic>.from(r);
                    c.removeWhere((k, _) => k.trim().toLowerCase() == 'institution_id');
                    return c;
                  }).toList()
                : batch;

            await _client.from(table).upsert(cleanBatch, onConflict: conflictKey);
            result.successCount += batch.length;
          } catch (fallbackErr) {
            result.errors.add({
              'table': table,
              'row_index_in_batch': i + 1,
              'error': fallbackErr.toString(),
              'sqlstate': 'FALLBACK_FAILED',
            });
          }
        } else {
          rethrow;
        }
      }
    }
    return result;
  }
}

class _BatchResult {
  int successCount = 0;
  final List<Map<String, dynamic>> errors = [];
}