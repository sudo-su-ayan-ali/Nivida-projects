/// Security-layer services: RBAC permission checks, cryptographically secure
/// anonymous ID generation, and audit logging. These are enforced at the
/// service/repository layer -- UI only reflects what these allow, it never
/// substitutes for them.
library security_services;

import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
  final List<AuditLogEntry> _entries = [];
  final SupabaseClient? _clientInstance;
  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }
  String? institutionId;

  AuditService({SupabaseClient? client}) : _clientInstance = client;

  List<AuditLogEntry> get entries => List.unmodifiable(_entries.reversed);

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
    try {
      _client.from('exam_audit_log').insert({
        'id': entry.id,
        'institution_id': institutionId,
        'actor_user_id': entry.actorUserId,
        'actor_role': entry.actorRole,
        'action': entry.action,
        'module': entry.module,
        'reference_id': entry.referenceId,
        'previous_value': entry.previousValue,
        'new_value': entry.newValue,
        'session_info': entry.sessionInfo,
        'created_at': entry.timestamp.toIso8601String(),
      }).catchError((e) => debugPrint('❌ Audit log insert error: $e'));
    } catch (e) {
      debugPrint('❌ Audit log client error: $e');
    }
  }

  /// Loads persisted audit history from Supabase so the trail survives
  /// app restarts / refreshes instead of living only in memory.
  Future<void> loadFromSupabase() async {
    final client = _client;
    if (client == null) return;
    try {
      final rows = await client.from('exam_audit_log').select();
      _entries
        ..clear()
        ..addAll((rows as List).map((r) => AuditLogEntry(
              id: r['id'],
              actorUserId: r['actor_user_id'],
              actorRole: r['actor_role'],
              action: r['action'],
              module: r['module'],
              referenceId: r['reference_id'],
              previousValue: r['previous_value'],
              newValue: r['new_value'],
              timestamp: r['created_at'] != null ? DateTime.parse(r['created_at']) : null,
              sessionInfo: r['session_info'] ?? 'web-session',
            )))
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
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