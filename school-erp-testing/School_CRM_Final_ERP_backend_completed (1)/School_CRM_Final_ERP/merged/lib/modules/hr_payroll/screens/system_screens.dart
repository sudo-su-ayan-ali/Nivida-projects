import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ---------------- Notifications ----------------

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final df = DateFormat('dd MMM, hh:mm a');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Notifications',
          subtitle: '${state.unreadNotifications} unread notifications',
          actions: [
            SecondaryButton(
                label: 'Mark all read',
                icon: Icons.done_all,
                onPressed: () => context.read<AppState>().markAllNotificationsRead()),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final n in state.notifications)
                Column(
                  children: [
                    ListTile(
                      onTap: () => context.read<AppState>().markNotificationRead(n.id),
                      leading: Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: n.read ? Colors.transparent : AppColors.primary,
                          shape: BoxShape.circle,
                          border: n.read ? Border.all(color: AppColors.border) : null,
                        ),
                      ),
                      title: Text(n.title,
                          style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700, fontSize: 13.5)),
                      subtitle: Text(n.message, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      trailing: Text(df.format(n.time), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ),
                    if (n != state.notifications.last) const Divider(height: 1),
                  ],
                ),
              if (state.notifications.isEmpty) const EmptyState(message: 'No notifications'),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Settings ----------------

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Settings', subtitle: 'Configure system-wide preferences'),
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TabBar(
                controller: _tab,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Company Settings'),
                  Tab(text: 'General'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Leave'),
                  Tab(text: 'Payroll'),
                  Tab(text: 'Security'),
                ],
              ),
              const Divider(height: 1),
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _SettingsPane(fields: const [
                      _SettingField.text('School / Company Name', 'Bright Future School'),
                      _SettingField.text('Address', 'Civil Lines, Jodhpur, Rajasthan'),
                      _SettingField.text('Contact Email', 'admin@brightfuture.edu.in'),
                      _SettingField.text('Contact Phone', '+91 98290 00000'),
                    ]),
                    _SettingsPane(fields: const [
                      _SettingField.dropdown('Timezone', 'Asia/Kolkata (IST)', ['Asia/Kolkata (IST)', 'UTC']),
                      _SettingField.dropdown('Date Format', 'DD/MM/YYYY', ['DD/MM/YYYY', 'MM/DD/YYYY']),
                      _SettingField.dropdown('Currency', 'INR (₹)', ['INR (₹)', 'USD (\$)']),
                      _SettingField.toggle('Enable Dark Mode', false),
                    ]),
                    _SettingsPane(fields: const [
                      _SettingField.text('Working Hours Start', '09:00 AM'),
                      _SettingField.text('Working Hours End', '05:00 PM'),
                      _SettingField.text('Late Grace Period (minutes)', '10'),
                      _SettingField.toggle('Enable Biometric Attendance', true),
                    ]),
                    _SettingsPane(fields: const [
                      _SettingField.text('Casual Leave / Year', '12'),
                      _SettingField.text('Medical Leave / Year', '10'),
                      _SettingField.text('Earned Leave / Year', '15'),
                      _SettingField.toggle('Require Manager Approval', true),
                    ]),
                    _SettingsPane(fields: const [
                      _SettingField.text('Payroll Processing Date', '28th of every month'),
                      _SettingField.text('Default PF Rate (%)', '12'),
                      _SettingField.text('Default Professional Tax', '200'),
                      _SettingField.toggle('Auto-generate Payslips', true),
                    ]),
                    _SettingsPane(fields: const [
                      _SettingField.toggle('Two-Factor Authentication', false),
                      _SettingField.toggle('Email Login Alerts', true),
                      _SettingField.text('Session Timeout (minutes)', '30'),
                      _SettingField.text('Password Policy', 'Minimum 8 characters, 1 number'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingField {
  final String label;
  final String type; // text / dropdown / toggle
  final String? textValue;
  final bool? boolValue;
  final List<String>? options;
  const _SettingField.text(this.label, this.textValue)
      : type = 'text',
        boolValue = null,
        options = null;
  const _SettingField.dropdown(this.label, this.textValue, this.options) : type = 'dropdown', boolValue = null;
  const _SettingField.toggle(this.label, this.boolValue)
      : type = 'toggle',
        textValue = null,
        options = null;
}

class _SettingsPane extends StatefulWidget {
  final List<_SettingField> fields;
  const _SettingsPane({required this.fields});

  @override
  State<_SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<_SettingsPane> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = {for (final f in widget.fields) f.label: f.type == 'toggle' ? f.boolValue : f.textValue};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final f in widget.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: f.type == 'toggle'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(f.label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        Switch(
                            value: _values[f.label] as bool,
                            onChanged: (v) => setState(() => _values[f.label] = v)),
                      ],
                    )
                  : f.type == 'dropdown'
                      ? SizedBox(
                          width: 320,
                          child: DropdownButtonFormField<String>(
                            value: _values[f.label] as String,
                            decoration: InputDecoration(labelText: f.label),
                            items: f.options!.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                            onChanged: (v) => setState(() => _values[f.label] = v),
                          ),
                        )
                      : SizedBox(
                          width: 320,
                          child: TextFormField(
                            initialValue: _values[f.label] as String,
                            decoration: InputDecoration(labelText: f.label),
                            onChanged: (v) => _values[f.label] = v,
                          ),
                        ),
            ),
          PrimaryButton(
              label: 'Save Changes',
              icon: Icons.save_outlined,
              onPressed: () => showAppToast(context, 'Settings saved successfully')),
        ],
      ),
    );
  }
}

// ---------------- Profile ----------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'My Profile', subtitle: 'Manage your account information'),
        const SizedBox(height: 18),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary, size: 42),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priya Singh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('HR Administrator · HR Department',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 32,
                      runSpacing: 12,
                      children: const [
                        _ProfileField(label: 'Email', value: 'priya.singh@brightfuture.edu.in'),
                        _ProfileField(label: 'Phone', value: '+91 98290 12345'),
                        _ProfileField(label: 'Employee ID', value: 'EMP1005'),
                        _ProfileField(label: 'Joined', value: '15 Jun 2021'),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                  onPressed: () => showAppToast(context, 'Profile updated successfully'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile')),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 14),
              Wrap(spacing: 14, runSpacing: 14, children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                      obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
                ),
              ]),
              const SizedBox(height: 16),
              PrimaryButton(
                  label: 'Update Password',
                  icon: Icons.lock_outline,
                  onPressed: () => showAppToast(context, 'Password updated successfully')),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
