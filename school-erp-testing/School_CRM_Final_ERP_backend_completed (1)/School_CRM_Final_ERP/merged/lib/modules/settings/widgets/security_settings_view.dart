import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class SecuritySettingsView extends StatefulWidget {
  final SettingsController controller;
  const SecuritySettingsView({super.key, required this.controller});

  @override
  State<SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<SecuritySettingsView> {
  String _minPasswordLength = '10 characters';
  String _passwordExpiry = '90 Days';
  bool _requireSpecialChars = true;
  bool _enforceIpLock = false;

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
        // Security Banner
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
                  color: AppColors.iconBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.iconBlueFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & Access Governance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Multi-Tenant Row-Level Security (RLS) active. Governs session timeouts, 2FA, and password policies.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F7EA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF22B573).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF22B573), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'RLS Enforced',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22B573),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2-column or responsive layout for Security controls
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Card 1: Core Security Toggles
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
                          'Authentication & Session Controls',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSwitchTile(
                          title: 'Two-Factor Authentication (2FA)',
                          subtitle: 'Mandatory verification for Principal and Administrative personnel',
                          value: controller.toggles['Two Factor Authentication'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('Two Factor Authentication'),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Session Inactivity Timeout',
                          subtitle: 'Automatically invalidate unattended sessions after 30 minutes',
                          value: controller.toggles['Session Timeout'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('Session Timeout'),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Comprehensive Activity Logging',
                          subtitle: 'Record audit logs for all data mutations and security events',
                          value: controller.toggles['Activity Logging'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('Activity Logging'),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Institution Maintenance Mode',
                          subtitle: 'Temporarily pause non-administrative access during maintenance',
                          value: controller.toggles['Maintenance Mode'] ?? false,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('Maintenance Mode'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card 2: Password Policy
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
                          'Password Policy & Network Protection',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownRow(
                          label: 'Minimum Password Length',
                          value: _minPasswordLength,
                          options: ['8 characters', '10 characters', '12 characters', '16 characters'],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _minPasswordLength = v);
                            controller.emitToast('Password length policy updated', ToastType.info);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow(
                          label: 'Password Expiry Period',
                          value: _passwordExpiry,
                          options: ['Never', '30 Days', '60 Days', '90 Days', '180 Days'],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _passwordExpiry = v);
                            controller.emitToast('Password expiry cycle set to $v', ToastType.info);
                          },
                        ),
                        const Divider(height: 24),
                        _buildSwitchTile(
                          title: 'Require Numbers & Special Characters',
                          subtitle: 'Force passwords to contain letters, digits, and symbols',
                          value: _requireSpecialChars,
                          dark: dark,
                          onChanged: (v) => setState(() => _requireSpecialChars = v),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Enforce Campus IP Geofence',
                          subtitle: 'Restrict privileged staff logins to verified campus network IPs',
                          value: _enforceIpLock,
                          dark: dark,
                          onChanged: (v) => setState(() => _enforceIpLock = v),
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

        // Active Session Card
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Principal Sessions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.emitToast('All other remote sessions have been revoked', ToastType.success);
                    },
                    icon: const Icon(Icons.phonelink_erase_rounded, size: 16, color: Colors.redAccent),
                    label: const Text(
                      'Revoke Other Sessions',
                      style: TextStyle(fontSize: 12.5, color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF141A28) : const Color(0xFFF6F8FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.iconBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.computer_rounded, color: AppColors.iconBlueFg, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Principal Terminal — Web Browser (Current)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F7EA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF22B573),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'User: Dr. Robert Jenkins (prc001@edusmart.local) • IP: 127.0.0.1 • Tenant Alpha',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool dark,
    required ValueChanged<bool> onChanged,
  }) {
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              style: TextStyle(fontSize: 13, color: textPrimary),
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
