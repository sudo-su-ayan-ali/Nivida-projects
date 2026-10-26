import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class SaveSettingsBar extends StatelessWidget {
  final SettingsController controller;
  const SaveSettingsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = controller.isDarkMode;
    final isNarrow = MediaQuery.of(context).size.width < 780;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: dark ? AppColors.saveBarBgDark : AppColors.saveBarBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? AppColors.cardBorderDark : const Color(0xFFD7E3FB),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        children: [
          SizedBox(
            width: isNarrow ? double.infinity : MediaQuery.of(context).size.width * 0.45,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save your configuration, keep Tenant Alpha secure',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Changes made here are saved directly to school settings and isolated to your tenant.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: controller.discardChanges,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Discard Changes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  side: BorderSide(
                    color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
                  ),
                  backgroundColor: dark ? AppColors.cardWhiteDark : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => controller.runFullBackup(),
                icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primaryBlue),
                label: const Text('Export Backup (.xlsx)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  backgroundColor: dark ? AppColors.cardWhiteDark : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.saveSettings(),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
