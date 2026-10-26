import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class AppearanceSettingsView extends StatefulWidget {
  final SettingsController controller;
  const AppearanceSettingsView({super.key, required this.controller});

  @override
  State<AppearanceSettingsView> createState() => _AppearanceSettingsViewState();
}

class _AppearanceSettingsViewState extends State<AppearanceSettingsView> {
  String _fontScale = 'Standard (100%)';
  String _density = 'Standard (40px)';
  Color _accentColor = AppColors.primaryBlue;

  final List<Map<String, dynamic>> _accentPalettes = [
    {'name': 'EduSmart Blue', 'color': const Color(0xFF2F6FED)},
    {'name': 'Emerald Green', 'color': const Color(0xFF10B981)},
    {'name': 'Royal Violet', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Sunset Amber', 'color': const Color(0xFFF59E0B)},
    {'name': 'Ocean Cyan', 'color': const Color(0xFF06B6D4)},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final dark = controller.isDarkMode;

    final cardBg = dark ? AppColors.cardWhiteDark : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.iconPurpleBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette_rounded, color: AppColors.iconPurpleFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visual Theme & Layout Customization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tailor your ERP visual experience: switch light/dark themes, accent palettes, and display densities.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Light / Dark Mode selector cards
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setDarkMode(false),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: !dark ? const Color(0xFFEEF4FF) : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: !dark ? AppColors.primaryBlue : borderColor,
                      width: !dark ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daylight Light Theme',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'High readability daylight canvas with soft blue gradients',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (!dark)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setDarkMode(true),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF1E283F) : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: dark ? AppColors.primaryBlue : borderColor,
                      width: dark ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.nightlight_round, color: Colors.indigoAccent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Midnight Dark Theme',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'OLED deep dark styling with reduced eyestrain',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (dark)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Brand Accents & Density
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Accent Colors
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brand Accent Palette',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Changes the prominent interactive color of buttons, badges, and active tabs',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _accentPalettes.map((p) {
                            final Color color = p['color'];
                            final String name = p['name'];
                            final isSelected = _accentColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _accentColor = color);
                                controller.emitToast('Accent palette set to $name', ToastType.info);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? color : borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Density & Scaling
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Density & Typography Scale',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow(
                          label: 'Interface Font Scale',
                          value: _fontScale,
                          options: ['Compact (90%)', 'Standard (100%)', 'Large (110%)'],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _fontScale = v);
                            controller.emitToast('Font scale set to $v', ToastType.info);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow(
                          label: 'Table Row Density',
                          value: _density,
                          options: ['Comfortable (48px)', 'Standard (40px)', 'Dense (32px)'],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _density = v);
                            controller.emitToast('Table density set to $v', ToastType.info);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // Live Preview Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Appearance Preview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(backgroundColor: _accentColor),
                    child: const Text('Primary Action Button'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary Outlined'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: const Text('Tenant Alpha Verified'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Preview Badge',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _accentColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> options,
    required bool dark,
    required ValueChanged<String> onChanged,
  }) {
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final fieldBg = dark ? const Color(0xFF11172A) : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              style: TextStyle(fontSize: 12.5, color: textPrimary),
              dropdownColor: dark ? AppColors.cardWhiteDark : Colors.white,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
