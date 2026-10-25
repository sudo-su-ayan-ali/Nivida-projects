import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/emergency_provider.dart';
import '../../../data/hostel_service.dart';

class EmergencySosCard extends ConsumerStatefulWidget {
  const EmergencySosCard({super.key});

  @override
  ConsumerState<EmergencySosCard> createState() => _EmergencySosCardState();
}

class _EmergencySosCardState extends ConsumerState<EmergencySosCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && ref.read(emergencyAlertProvider).isActive) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'Fire Alert':
        return AppColors.danger;
      case 'Medical SOS':
        return AppColors.warning;
      case 'Security Alert':
        return AppColors.info;
      default:
        return AppColors.danger;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'Fire Alert':
        return Icons.local_fire_department_rounded;
      case 'Medical SOS':
        return Icons.medical_services_rounded;
      case 'Security Alert':
        return Icons.shield_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Future<void> _handleTrigger(BuildContext context, String label) async {
    final ok = await showConfirmDialog(
      context,
      title: "Trigger $label?",
      message:
          "This will immediately notify the warden, campus security desk, and hostel admin team.",
      confirmLabel: "Trigger Alert",
      danger: true,
    );

    if (ok && mounted) {
      ref.read(emergencyAlertProvider.notifier).triggerAlert(label);

      // Create high-priority emergency notice in database asynchronously
      try {
        await HostelService().createNotice(
          title: "EMERGENCY: $label Triggered",
          description:
              "An active $label was initiated from the Principal/Warden dashboard at ${DateTime.now().toLocal().toString().substring(11, 16)}. All resident staff and floor captains are advised to check emergency stations.",
          category: "Emergency",
          audience: "All Students",
          priority: "High",
        );
        ref.read(noticesProvider.notifier).reload();
      } catch (e) {
        debugPrint("Notice auto-broadcast notice error: $e");
      }

      if (context.mounted) {
        showAppSnackBar(
          context,
          "🚨 $label triggered! Warden, security desk, and staff notified.",
          isError: true,
        );
      }
    }
  }

  Future<void> _handleResolve(BuildContext context) async {
    final notesController = TextEditingController(text: "Situation verified and resolved on-site.");
    final shouldResolve = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              SizedBox(width: 8),
              Text("Resolve Emergency Alert", style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Provide brief resolution notes before clearing the active alert. This will restore normal status across all hostel dashboards.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Resolution / Action Taken",
                  hintText: "e.g., False alarm / Medical team dispatched / All clear",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text("Mark Resolved"),
            ),
          ],
        );
      },
    );

    if (shouldResolve == true && mounted) {
      ref.read(emergencyAlertProvider.notifier).resolveAlert(notes: notesController.text.trim());
      if (context.mounted) {
        showAppSnackBar(context, "Emergency alert cleared and marked resolved.");
      }
    }
  }

  void _showEmergencyContactsDialog(BuildContext context) {
    final staff = ref.read(staffProvider);
    final settings = ref.read(hostelSettingsProvider);

    // Find wardens
    final wardens = staff
        .where((s) => s.role.toLowerCase().contains("warden"))
        .toList();

    final chiefWardenName = settings.chiefWarden.isNotEmpty
        ? settings.chiefWarden
        : (wardens.isNotEmpty ? wardens.first.name : "Mr. R. Sharma (Chief Warden)");

    final chiefWardenPhone = settings.emergencyPhone.isNotEmpty
        ? settings.emergencyPhone
        : (wardens.isNotEmpty ? wardens.first.phone : "+91 98290 11234");

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: const Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Text("Emergency Contacts & Helplines", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _contactTile(
                    title: chiefWardenName,
                    subtitle: "Chief Warden / On-Duty Incharge",
                    phone: chiefWardenPhone,
                    icon: Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                  const Divider(height: 16),
                  _contactTile(
                    title: "Campus Security Desk",
                    subtitle: "Main Gate Security Room (24x7)",
                    phone: "+91 98290 11200",
                    icon: Icons.shield_rounded,
                    color: AppColors.info,
                  ),
                  const Divider(height: 16),
                  _contactTile(
                    title: "Campus Health Center / Ambulance",
                    subtitle: "Resident Medical Officer",
                    phone: "+91 98290 10800",
                    icon: Icons.medical_services_rounded,
                    color: AppColors.warning,
                  ),
                  const Divider(height: 16),
                  _contactTile(
                    title: "Local Fire Control Station",
                    subtitle: "Municipal Fire Services",
                    phone: "101 / +91 141 2740101",
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.danger,
                  ),
                  const Divider(height: 16),
                  _contactTile(
                    title: "Police Control Room",
                    subtitle: "Area Police Station",
                    phone: "112 / 100",
                    icon: Icons.local_police_rounded,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _contactTile({
    required String title,
    required String subtitle,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.call, size: 13, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                phone,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(emergencyAlertProvider);
    final settings = ref.watch(hostelSettingsProvider);
    final staff = ref.watch(staffProvider);

    // Determine warden on call
    final wardenName = settings.chiefWarden.isNotEmpty
        ? settings.chiefWarden
        : (staff.any((s) => s.role.toLowerCase().contains("warden"))
            ? staff.firstWhere((s) => s.role.toLowerCase().contains("warden")).name
            : "Mr. R. Sharma");
    final wardenPhone = settings.emergencyPhone.isNotEmpty
        ? settings.emergencyPhone
        : (staff.any((s) => s.role.toLowerCase().contains("warden"))
            ? staff.firstWhere((s) => s.role.toLowerCase().contains("warden")).phone
            : "+91 98290 11234");

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader(title: "Emergency & Safety")),
              if (alertState.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeColor(alertState.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: _typeColor(alertState.type)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _typeColor(alertState.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "ACTIVE ALERT",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: _typeColor(alertState.type),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // If active emergency, show persistent incident response banner
          if (alertState.isActive) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _typeColor(alertState.type).withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: _typeColor(alertState.type).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_typeIcon(alertState.type), color: _typeColor(alertState.type), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${alertState.type} is IN PROGRESS",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _typeColor(alertState.type),
                          ),
                        ),
                      ),
                      if (alertState.triggeredAt != null)
                        Text(
                          "Active for: ${_formatDuration(DateTime.now().difference(alertState.triggeredAt!))}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _typeColor(alertState.type),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Initiated by ${alertState.triggeredBy ?? 'Admin'}. All wardens and security staff alerted.",
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                        onPressed: () => _handleResolve(context),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text("Resolve / Clear Alert", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                        onPressed: () => context.push('/notices'),
                        icon: const Icon(Icons.campaign_rounded, size: 16),
                        label: const Text("View Notice Feed", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 3 Quick SOS Action Buttons
          Row(
            children: [
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: "Fire Alert",
                  color: AppColors.danger,
                  isCurrentActive: alertState.isActive && alertState.type == "Fire Alert",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.medical_services_rounded,
                  label: "Medical SOS",
                  color: AppColors.warning,
                  isCurrentActive: alertState.isActive && alertState.type == "Medical SOS",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.shield_rounded,
                  label: "Security Alert",
                  color: AppColors.info,
                  isCurrentActive: alertState.isActive && alertState.type == "Security Alert",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Warden on call banner - clickable to open Contacts modal
          Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => _showEmergencyContactsDialog(context),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.call_rounded, size: 16, color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Warden on-call: $wardenName · $wardenPhone",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Text(
                      "Helplines",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sosButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool isCurrentActive = false,
  }) {
    return Material(
      color: isCurrentActive ? color.withOpacity(0.2) : color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _handleTrigger(context, label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isCurrentActive ? color : color.withOpacity(0.3),
              width: isCurrentActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
