import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class NotificationsSettingsView extends StatefulWidget {
  final SettingsController controller;
  const NotificationsSettingsView({super.key, required this.controller});

  @override
  State<NotificationsSettingsView> createState() => _NotificationsSettingsViewState();
}

class _NotificationsSettingsViewState extends State<NotificationsSettingsView> {
  bool _studentAbsenceAlert = true;
  bool _feeReceiptAlert = true;
  bool _examResultAlert = true;
  bool _staffPayrollAlert = true;
  bool _lowStockAlert = true;

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
                  color: AppColors.iconPinkBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_rounded, color: AppColors.iconPinkFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Channel Notification Center',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure transactional alerts, parent messaging, SMS gateways, and WhatsApp dispatch.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _sendTestNotification(context, controller),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Test Notification'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2-column layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Delivery Channels
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
                          'Primary Delivery Channels',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSwitchTile(
                          title: 'Email Notifications (SMTP)',
                          subtitle: 'Send official invoices, report cards, and notices via email',
                          value: controller.toggles['Email Notifications'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('Email Notifications'),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'SMS Gateway Broadcasts',
                          subtitle: 'Dispatch urgent absence notices and OTPs to parent mobiles',
                          value: controller.toggles['SMS Notifications'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('SMS Notifications'),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'WhatsApp Business Messaging',
                          subtitle: 'Interactive timetable, fee receipts, and school bus alerts',
                          value: controller.toggles['WhatsApp Notifications'] ?? true,
                          dark: dark,
                          onChanged: (_) => controller.toggleSetting('WhatsApp Notifications'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Event Trigger Subscriptions
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
                          'Event Trigger Rules',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSwitchTile(
                          title: 'Daily Student Absence Alert',
                          subtitle: 'Instantly notify parents when student is marked absent',
                          value: _studentAbsenceAlert,
                          dark: dark,
                          onChanged: (v) => setState(() => _studentAbsenceAlert = v),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Fee Payment & Due Date Reminders',
                          subtitle: 'Notify parents 3 days before installment due dates',
                          value: _feeReceiptAlert,
                          dark: dark,
                          onChanged: (v) => setState(() => _feeReceiptAlert = v),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Exam Marks & Publication Alerts',
                          subtitle: 'Broadcast alerts when term exam results are verified',
                          value: _examResultAlert,
                          dark: dark,
                          onChanged: (v) => setState(() => _examResultAlert = v),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Staff Payroll & Payslip Dispatch',
                          subtitle: 'Email salary slips directly upon payroll approval',
                          value: _staffPayrollAlert,
                          dark: dark,
                          onChanged: (v) => setState(() => _staffPayrollAlert = v),
                        ),
                        const Divider(height: 20),
                        _buildSwitchTile(
                          title: 'Low Stock Inventory Warnings',
                          subtitle: 'Alert Principal and store managers on critical stock levels',
                          value: _lowStockAlert,
                          dark: dark,
                          onChanged: (v) => setState(() => _lowStockAlert = v),
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

        // Gateway Status & Sender Info
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
                'Gateway Status & Sender Identities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildGatewayStatusTile(
                      icon: Icons.email_rounded,
                      name: 'Email SMTP',
                      sender: 'notifications@alpha.edusmart.local',
                      status: 'Connected',
                      statusColor: const Color(0xFF22B573),
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildGatewayStatusTile(
                      icon: Icons.sms_rounded,
                      name: 'SMS Header ID',
                      sender: 'EDUSMART (14,850 SMS credits)',
                      status: 'Active',
                      statusColor: const Color(0xFF22B573),
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildGatewayStatusTile(
                      icon: Icons.chat_rounded,
                      name: 'WhatsApp Business API',
                      sender: '+91 98765 43210 (Verified)',
                      status: 'Verified',
                      statusColor: const Color(0xFF22B573),
                      dark: dark,
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

  Widget _buildGatewayStatusTile({
    required IconData icon,
    required String name,
    required String sender,
    required String status,
    required Color statusColor,
    required bool dark,
  }) {
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF141A28) : const Color(0xFFF6F8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(sender, style: TextStyle(fontSize: 12, color: textSecondary)),
        ],
      ),
    );
  }

  void _sendTestNotification(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Test Notification'),
        content: const Text(
          'A test message will be dispatched via Email and SMS to verify delivery pipelines for Principal (prc001@edusmart.local).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              controller.emitToast('Test notification delivered to prc001@edusmart.local', ToastType.success);
            },
            child: const Text('Send Now'),
          ),
        ],
      ),
    );
  }
}
