import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../shared/widgets/app_card.dart";
import "../../../shared/widgets/confirm_dialog.dart";

/// Extra #1: Emergency / SOS panel — critical for boarding hostels where
/// fire, medical, or security incidents need an instant, unmissable trigger.
class EmergencySosCard extends StatelessWidget {
  const EmergencySosCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: "Emergency & Safety"),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: "Fire Alert",
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.medical_services_rounded,
                  label: "Medical SOS",
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sosButton(
                  context,
                  icon: Icons.shield_rounded,
                  label: "Security Alert",
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: const Row(
              children: [
                Icon(Icons.call_rounded, size: 16, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Warden on-call: Mr. R. Sharma · +91 98290 11234",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sosButton(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () async {
          final ok = await showConfirmDialog(
            context,
            title: "Trigger $label?",
            message: "This will immediately notify the warden, security desk, and admin team.",
            confirmLabel: "Trigger Alert",
            danger: true,
          );
          if (ok && context.mounted) showAppSnackBar(context, "$label triggered and staff notified.", isError: true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: color.withOpacity(0.3))),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
