import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';
import 'setting_field.dart';

const _academicYears = [
  '2023 - 2024',
  '2024 - 2025',
  '2025 - 2026',
  '2026 - 2027',
  '2027 - 2028',
];

const _timeZones = [
  '(GMT+05:30) Asia/Kolkata',
  '(GMT+00:00) UTC',
  '(GMT-05:00) America/New_York',
  '(GMT+01:00) Europe/London',
];

const _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'];
const _languages = ['English', 'Hindi', 'Spanish', 'French'];
const _currencies = [
  'INR - Indian Rupee (₹)',
  'USD - US Dollar (\$)',
  'EUR - Euro (€)',
  'GBP - British Pound (£)',
];
const _themes = ['Light Theme', 'Dark Theme', 'System Default'];
const _itemsPerPage = ['10', '20', '50', '100'];

class GeneralSettingsForm extends StatelessWidget {
  final SettingsController controller;
  const GeneralSettingsForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = controller.isDarkMode;
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1000 ? 4 : (width >= 680 ? 2 : 1);

    final draft = controller.draft;

    final fields = <Widget>[
      SettingField(
        key: ValueKey('orgName-${controller.formGeneration}'),
        icon: Icons.apartment_rounded,
        label: 'Organization / Institute Name',
        value: draft.orgName,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('orgName', v),
      ),
      SettingField(
        key: ValueKey('academicYear-${controller.formGeneration}'),
        icon: Icons.calendar_today_rounded,
        label: 'Academic Year / Session',
        value: draft.academicYear,
        options: _academicYears,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('academicYear', v),
      ),
      SettingField(
        key: ValueKey('timeZone-${controller.formGeneration}'),
        icon: Icons.public_rounded,
        label: 'Time Zone',
        value: draft.timeZone,
        options: _timeZones,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('timeZone', v),
      ),
      SettingField(
        key: ValueKey('dateFormat-${controller.formGeneration}'),
        icon: Icons.event_note_rounded,
        label: 'Date Format',
        value: draft.dateFormat,
        options: _dateFormats,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('dateFormat', v),
      ),
      SettingField(
        key: ValueKey('language-${controller.formGeneration}'),
        icon: Icons.translate_rounded,
        label: 'Language',
        value: draft.language,
        options: _languages,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('language', v),
      ),
      SettingField(
        key: ValueKey('currency-${controller.formGeneration}'),
        icon: Icons.currency_rupee_rounded,
        label: 'Currency',
        value: draft.currency,
        options: _currencies,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('currency', v),
      ),
      SettingField(
        key: ValueKey('theme-${controller.formGeneration}'),
        icon: Icons.contrast_rounded,
        label: 'Theme',
        value: draft.theme,
        options: _themes,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('theme', v),
      ),
      SettingField(
        key: ValueKey('itemsPerPage-${controller.formGeneration}'),
        icon: Icons.view_list_rounded,
        label: 'Items Per Page',
        value: draft.itemsPerPage,
        options: _itemsPerPage,
        dark: dark,
        onChanged: (v) => controller.updateDraftField('itemsPerPage', v),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardWhiteDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.settings_rounded,
                    color: AppColors.iconBlueFg, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General System Settings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: dark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Configure common settings for your entire platform',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.topRight,
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              icon: Icon(Icons.refresh_rounded,
                  size: 16,
                  color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              label: Text(
                'Reset to Default',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final itemWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 18,
                children: fields
                    .map((f) => SizedBox(width: itemWidth, child: f))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text(
            'This will restore all General System Settings fields to Tenant Alpha default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              controller.resetToDefault();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
