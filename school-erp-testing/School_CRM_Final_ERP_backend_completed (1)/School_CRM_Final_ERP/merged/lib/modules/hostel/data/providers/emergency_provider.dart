import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmergencyAlertState {
  final bool isActive;
  final String? type; // 'Fire Alert', 'Medical SOS', 'Security Alert'
  final DateTime? triggeredAt;
  final String? triggeredBy;
  final String? resolutionNotes;

  const EmergencyAlertState({
    this.isActive = false,
    this.type,
    this.triggeredAt,
    this.triggeredBy,
    this.resolutionNotes,
  });

  EmergencyAlertState copyWith({
    bool? isActive,
    String? type,
    DateTime? triggeredAt,
    String? triggeredBy,
    String? resolutionNotes,
  }) {
    return EmergencyAlertState(
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

class EmergencyAlertController extends StateNotifier<EmergencyAlertState> {
  EmergencyAlertController() : super(const EmergencyAlertState());

  void triggerAlert(String type, {String triggeredBy = 'Principal / Admin'}) {
    state = EmergencyAlertState(
      isActive: true,
      type: type,
      triggeredAt: DateTime.now(),
      triggeredBy: triggeredBy,
    );
  }

  void resolveAlert({String notes = 'Incident verified and resolved by administration.'}) {
    state = EmergencyAlertState(
      isActive: false,
      type: null,
      triggeredAt: null,
      triggeredBy: null,
      resolutionNotes: notes,
    );
  }
}

final emergencyAlertProvider =
    StateNotifierProvider<EmergencyAlertController, EmergencyAlertState>((ref) {
  return EmergencyAlertController();
});
