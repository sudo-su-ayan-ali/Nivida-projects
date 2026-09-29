import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ToggleData {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  const ToggleData({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });
}

const List<ToggleData> kToggles = [
  ToggleData(
    title: 'Email Notifications',
    description: 'Send important updates via email',
    icon: Icons.mail_outline_rounded,
    iconBg: AppColors.iconBlueBg,
    iconFg: AppColors.iconBlueFg,
  ),
  ToggleData(
    title: 'SMS Notifications',
    description: 'Send alerts via SMS',
    icon: Icons.sms_outlined,
    iconBg: AppColors.iconGreenBg,
    iconFg: AppColors.iconGreenFg,
  ),
  ToggleData(
    title: 'WhatsApp Notifications',
    description: 'Send updates via WhatsApp',
    icon: Icons.chat_outlined,
    iconBg: AppColors.iconGreenBg,
    iconFg: AppColors.iconGreenFg,
  ),
  ToggleData(
    title: 'Two Factor Authentication',
    description: 'Extra layer of account security',
    icon: Icons.shield_outlined,
    iconBg: AppColors.iconPurpleBg,
    iconFg: AppColors.iconPurpleFg,
  ),
  ToggleData(
    title: 'Auto Backup',
    description: 'Automatic data backup',
    icon: Icons.cloud_upload_outlined,
    iconBg: AppColors.iconOrangeBg,
    iconFg: AppColors.iconOrangeFg,
  ),
  ToggleData(
    title: 'Activity Logging',
    description: 'Track system activities',
    icon: Icons.description_outlined,
    iconBg: AppColors.iconRoseBg,
    iconFg: AppColors.iconRoseFg,
  ),
  ToggleData(
    title: 'Session Timeout',
    description: 'Auto logout for inactive users',
    icon: Icons.access_time_rounded,
    iconBg: AppColors.iconCyanBg,
    iconFg: AppColors.iconCyanFg,
  ),
  ToggleData(
    title: 'Maintenance Mode',
    description: 'Temporarily close system access',
    icon: Icons.build_outlined,
    iconBg: AppColors.iconIndigoBg,
    iconFg: AppColors.iconIndigoFg,
  ),
];

class SettingToggleCard extends StatelessWidget {
  final ToggleData data;
  final bool value;
  final bool dark;
  final double width;
  final ValueChanged<bool> onChanged;

  const SettingToggleCard({
    super.key,
    required this.data,
    required this.value,
    required this.dark,
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardWhiteDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconFg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.toggleOn,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.toggleOff,
              trackOutlineColor:
                  MaterialStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
