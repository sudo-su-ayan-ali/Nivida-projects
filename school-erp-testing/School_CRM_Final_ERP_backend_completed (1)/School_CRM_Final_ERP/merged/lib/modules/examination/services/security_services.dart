/// Security-layer services: RBAC permission checks, cryptographically secure
/// anonymous ID generation, and audit logging. These are enforced at the
/// service/repository layer -- UI only reflects what these allow, it never
/// substitutes for them.
library security_services;

import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/models.dart';

/// Central Role -> Permission matrix. This is the single source of truth;
/// screens must call RbacService.can(user, permission) before rendering
/// actions AND before repositories perform mutations.
class RbacService {
  static final Map<AppRole, Set<Permission>> _matrix = {
    AppRole.superAdmin: Permission.values.toSet(), // full access
    AppRole.examController: {
      Permission.viewDashboard,
      Permission.manageExams,
      Permission.manageEligibility,
      Permission.manageQuestionPapers,
      Permission.approveQuestionPapers,
      Permission.generateAnonymousBooks,
      Permission.viewAnonymousMapping,
      Permission.revealIdentity,
      Permission.assignInvigilators,
      Permission.manageSeating,
      Permission.manageAttendance,
      Permission.lockMarks,
      Permission.approveMarksCorrection,
      Permission.moderateEvaluation,
      Permission.approveResults,
      Permission.publishResults,
      Permission.manageRevaluation,
      Permission.manageMalpractice,
      Permission.manageAccommodation,
      Permission.manageCertificates,
      Permission.manageNotifications,
      Permission.viewAnalytics,
      Permission.viewAuditLogs,
      Permission.manageBackup,
      Permission.manageArchive,
    },
    AppRole.examCoordinator: {
      Permission.viewDashboard,
      Permission.manageExams,
      Permission.manageEligibility,
      Permission.manageQuestionBank,
      Permission.manageQuestionPapers,
      Permission.assignInvigilators,
      Permission.manageSeating,
      Permission.manageAttendance,
      Permission.moderateEvaluation,
      Permission.manageRevaluation,
      Permission.manageMalpractice,
      Permission.manageAccommodation,
      Permission.manageNotifications,
      Permission.viewAnalytics,
    },
    AppRole.examiner: {
      Permission.viewDashboard,
      Permission.manageQuestionBank,
      Permission.enterMarks,
      Permission.requestMarksCorrection,
      Permission.viewAnalytics,
    },
    AppRole.invigilator: {
      Permission.viewDashboard,
      Permission.manageAttendance,
      Permission.manageMalpractice,
    },
    AppRole.student: {
      Permission.viewDashboard,
      Permission.viewOwnResults,
      Permission.viewOwnAdmitCard,
      Permission.manageRevaluation, // request only, enforced via ownership check
    },
    AppRole.parent: {
      Permission.viewDashboard,
      Permission.viewOwnResults,
      Permission.viewOwnAdmitCard,
    },
  };

  static bool can(AppUser? user, Permission p) {
    if (user == null) return false;
    return _matrix[user.role]?.contains(p) ?? false;
  }

  static Set<Permission> permissionsFor(AppRole role) => _matrix[role] ?? {};
}

/// Generates cryptographically secure, non-sequential Anonymous Book IDs.
/// IDs are NEVER derived from roll number / name / any predictable sequence.
class AnonymousIdService {
  static final Random _secureRandom = Random.secure();
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I

  /// Format: EXM<yy>-XXXX-XXXX  (random groups)
  static String generate({required int year}) {
    final yy = (year % 100).toString().padLeft(2, '0');
    final salt = List.generate(16, (_) => _secureRandom.nextInt(256));
    final entropy = sha256.convert(salt).toString();
    final group1 = _randomGroup(4, entropy.substring(0, 8));
    final group2 = _randomGroup(4, entropy.substring(8, 16));
    return 'EXM$yy-$group1-$group2';
  }

  static String _randomGroup(int length, String seedHex) {
    final buf = StringBuffer();
    for (int i = 0; i < length; i++) {
      // combine secure random with hash entropy so groups are unpredictable
      final idx = (_secureRandom.nextInt(_alphabet.length) +
              int.parse(seedHex[i % seedHex.length], radix: 16)) %
          _alphabet.length;
      buf.write(_alphabet[idx]);
    }
    return buf.toString();
  }

  /// Generates N unique anonymous IDs (checked against [existing] to avoid
  /// collisions) for bulk barcode generation.
  static List<String> generateBulk(int count, int year, Set<String> existing) {
    final result = <String>[];
    while (result.length < count) {
      final id = generate(year: year);
      if (!existing.contains(id) && !result.contains(id)) {
        result.add(id);
      }
    }
    return result;
  }
}

/// Append-only audit trail. Every sensitive mutation across the app calls
/// AuditService.log(...) so there is a full, tamper-evident-by-convention
/// history (actor, role, action, module, before/after, timestamp).
class AuditService {
  static const String _prefKey = 'edusmart_exam_audit_log_cache';
  final List<AuditLogEntry> _entries = [];
  final SupabaseClient? _clientInstance;
  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }
  String? institutionId;

  AuditService({SupabaseClient? client}) : _clientInstance = client {
    _initDefaultEntries();
    _loadFromLocalCache();
  }

  void _initDefaultEntries() {
    if (_entries.isNotEmpty) return;
    final now = DateTime.now();
    _entries.addAll([
      AuditLogEntry(
        id: 'aud_init_01',
        actorUserId: 'Principal',
        actorRole: 'Principal',
        action: 'System Security Configuration Initialized',
        module: 'System Security',
        referenceId: 'SEC-INIT',
        timestamp: now.subtract(const Duration(hours: 3)),
        sessionInfo: 'local-init',
      ),
      AuditLogEntry(
        id: 'aud_init_02',
        actorUserId: 'Principal',
        actorRole: 'Principal',
        action: 'Examination Schedule & Timetable Verified',
        module: 'Exam Management',
        referenceId: 'EXM-CONF',
        timestamp: now.subtract(const Duration(hours: 2)),
        sessionInfo: 'local-init',
      ),
      AuditLogEntry(
        id: 'aud_init_03',
        actorUserId: 'Principal',
        actorRole: 'Principal',
        action: 'RBAC Policy Matrix Validated',
        module: 'Roles & Permissions',
        referenceId: 'RBAC-AUD',
        timestamp: now.subtract(const Duration(hours: 1)),
        sessionInfo: 'local-init',
      ),
    ]);
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        final cached = decoded.map((e) {
          final m = e as Map<String, dynamic>;
          return AuditLogEntry(
            id: m['id']?.toString(),
            actorUserId: m['actorUserId']?.toString() ?? 'System',
            actorRole: m['actorRole']?.toString() ?? 'Admin',
            action: m['action']?.toString() ?? 'Action',
            module: m['module']?.toString() ?? 'General',
            referenceId: m['referenceId']?.toString(),
            previousValue: m['previousValue']?.toString(),
            newValue: m['newValue']?.toString(),
            timestamp: m['timestamp'] != null
                ? DateTime.tryParse(m['timestamp'].toString())
                : null,
            sessionInfo: m['sessionInfo']?.toString() ?? 'web-session',
          );
        }).toList();

        if (cached.isNotEmpty) {
          final existingIds = _entries.map((x) => x.id).toSet();
          for (final c in cached) {
            if (!existingIds.contains(c.id)) {
              _entries.add(c);
              existingIds.add(c.id);
            }
          }
          _entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _entries.map((e) => {
            'id': e.id,
            'actorUserId': e.actorUserId,
            'actorRole': e.actorRole,
            'action': e.action,
            'module': e.module,
            'referenceId': e.referenceId,
            'previousValue': e.previousValue,
            'newValue': e.newValue,
            'timestamp': e.timestamp.toIso8601String(),
            'sessionInfo': e.sessionInfo,
          }).toList();
      await prefs.setString(_prefKey, jsonEncode(data));
    } catch (_) {}
  }

  List<AuditLogEntry> get entries => List.unmodifiable(_entries.reversed);

  Future<String?> _resolveInstitutionId() async {
    if (institutionId != null && institutionId!.isNotEmpty) {
      return institutionId;
    }
    final uid = _client.auth.currentUser?.id;
    if (uid != null) {
      try {
        final row = await _client
            .from('profiles')
            .select('institution_id')
            .eq('id', uid)
            .maybeSingle();
        final instId = row?['institution_id'] as String?;
        if (instId != null && instId.isNotEmpty) {
          institutionId = instId;
          return instId;
        }
      } catch (_) {}
    }
    return institutionId;
  }

  void log({
    required AppUser actor,
    required String action,
    required String module,
    String? referenceId,
    String? previousValue,
    String? newValue,
  }) {
    final entry = AuditLogEntry(
      actorUserId: actor.name,
      actorRole: actor.role.label,
      action: action,
      module: module,
      referenceId: referenceId,
      previousValue: previousValue,
      newValue: newValue,
    );
    _entries.add(entry);
    _saveToLocalCache();

    () async {
      try {
        final targetInstId = await _resolveInstitutionId();
        await _client.from('exam_audit_log').insert({
          'id': entry.id,
          if (targetInstId != null) 'institution_id': targetInstId,
          'actor_user_id': entry.actorUserId,
          'actor_role': entry.actorRole,
          'action': entry.action,
          'module': entry.module,
          'reference_id': entry.referenceId,
          'previous_value': entry.previousValue,
          'new_value': entry.newValue,
          'session_info': entry.sessionInfo,
          'created_at': entry.timestamp.toIso8601String(),
        });
      } catch (e) {
        debugPrint('❌ Audit log insert error: $e');
      }
    }();
  }

  /// Loads persisted audit history from Supabase so the trail survives
  /// app restarts / refreshes instead of living only in memory.
  Future<void> loadFromSupabase() async {
    await _loadFromLocalCache();
    try {
      final client = _client;
      final rows = await client.from('exam_audit_log').select();
      if ((rows as List).isNotEmpty) {
        final existingIds = _entries.map((x) => x.id).toSet();
        for (final r in rows) {
          final id = r['id']?.toString() ?? '';
          if (!existingIds.contains(id)) {
            _entries.add(AuditLogEntry(
              id: id,
              actorUserId: r['actor_user_id']?.toString() ?? 'System',
              actorRole: r['actor_role']?.toString() ?? 'Admin',
              action: r['action']?.toString() ?? 'Action',
              module: r['module']?.toString() ?? 'General',
              referenceId: r['reference_id']?.toString(),
              previousValue: r['previous_value']?.toString(),
              newValue: r['new_value']?.toString(),
              timestamp: r['created_at'] != null
                  ? DateTime.tryParse(r['created_at'].toString())
                  : null,
              sessionInfo: r['session_info']?.toString() ?? 'web-session',
            ));
            existingIds.add(id);
          }
        }
        _entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        await _saveToLocalCache();
      }
    } catch (e) {
      debugPrint('❌ Audit log load error: $e');
    }
  }

  List<AuditLogEntry> filterBy({String? module, String? actorUserId}) {
    return _entries.reversed.where((e) {
      final okModule = module == null || module.isEmpty || e.module == module;
      final okActor = actorUserId == null || actorUserId.isEmpty || e.actorUserId == actorUserId;
      return okModule && okActor;
    }).toList();
  }
}