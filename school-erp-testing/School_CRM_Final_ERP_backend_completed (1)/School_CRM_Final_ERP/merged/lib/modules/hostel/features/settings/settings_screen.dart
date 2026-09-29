import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int selected = 0;
  final sections = const [
    ('General Settings', Icons.settings_rounded),
    ('Hostel Information', Icons.apartment_rounded),
    ('Academic Year', Icons.calendar_month_rounded),
    ('Room Settings', Icons.bed_rounded),
    ('Fee Settings', Icons.account_balance_wallet_rounded),
    ('Mess Settings', Icons.restaurant_rounded),
    ('Notification Settings', Icons.notifications_rounded),
    ('User Management', Icons.manage_accounts_rounded),
    ('Roles & Permissions', Icons.admin_panel_settings_rounded),
    ('Appearance', Icons.palette_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Settings']),
          const SizedBox(height: 10),
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Configure hostel-wide settings and preferences.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          _sidebarAndPanel(isDesktop),
        ],
      ),
      ),
    );
  }

  Widget _sidebarAndPanel(bool isDesktop) {
    final sidebar = SizedBox(
      width: isDesktop ? 260 : double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: List.generate(sections.length, (i) {
            final active = i == selected;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => setState(() => selected = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(children: [
                    Icon(sections[i].$2, size: 18, color: active ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(sections[i].$1, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.primary : AppColors.textPrimary)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );

    final panel = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(sections[selected].$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          _settingField('Hostel Name', 'Greenfield International Hostel'),
          _settingField('Contact Email', 'admin@hostelhub.edu.in'),
          _settingField('Contact Phone', '+91 98290 11234'),
          _settingField('Address', 'MG Road, Jaipur, Rajasthan'),
          const SizedBox(height: AppSpacing.lg),
          Align(alignment: Alignment.centerRight, child: PrimaryButton(label: 'Save Changes', icon: Icons.check_rounded, onPressed: () {})),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sidebar,
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: panel),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sidebar,
        const SizedBox(height: AppSpacing.xl),
        panel,
      ],
    );
  }

  Widget _settingField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(initialValue: value, decoration: const InputDecoration()),
        ],
      ),
    );
  }
}
