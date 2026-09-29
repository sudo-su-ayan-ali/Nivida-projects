import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/top_header.dart';
import 'nav_indices.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _qualCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _nameCtrl = TextEditingController(text: app.teacherName);
    _roleCtrl = TextEditingController(text: app.teacherRole);
    _emailCtrl = TextEditingController(text: app.teacherEmail);
    _phoneCtrl = TextEditingController(text: app.teacherPhone);
    _qualCtrl = TextEditingController(text: app.teacherQualification);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _qualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final initials = app.teacherName.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile & Settings', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('Manage your account and preferences', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),

            ResponsiveGrid(
              minItemWidth: 380,
              maxColumns: 2,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InitialsAvatarSmall(initials: initials.isEmpty ? 'PS' : initials),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.teacherName, style: AppTextStyles.itemTitle.copyWith(fontSize: 16)),
                                Text(app.teacherRole, style: AppTextStyles.itemSub),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AppTextField(label: 'Full Name', controller: _nameCtrl),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Role / Subject', controller: _roleCtrl),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Qualification', controller: _qualCtrl),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Phone', controller: _phoneCtrl, keyboardType: TextInputType.phone),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: AppPrimaryButton(
                          label: 'Save Changes',
                          icon: Icons.save_rounded,
                          onPressed: () {
                            context.read<AppState>().updateProfile(
                                  name: _nameCtrl.text.trim().isEmpty ? app.teacherName : _nameCtrl.text.trim(),
                                  role: _roleCtrl.text.trim().isEmpty ? app.teacherRole : _roleCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  qualification: _qualCtrl.text.trim(),
                                );
                            showAppSnack(context, 'Profile updated successfully');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notification Preferences', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 6),
                          _prefSwitch('Email notifications', app.notifyEmail, (v) => app.updateNotificationPrefs(email: v)),
                          _prefSwitch('Push notifications', app.notifyPush, (v) => app.updateNotificationPrefs(push: v)),
                          _prefSwitch('SMS alerts', app.notifySms, (v) => app.updateNotificationPrefs(sms: v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Leave Requests', style: AppTextStyles.sectionTitle),
                              InkWell(
                                onTap: () => app.setNavIndex(kLeavePayrollNavIndex),
                                child: Text('View Leave & Payroll →', style: AppTextStyles.viewAll),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (app.myLeaveRequests.isEmpty)
                            Text('No leave requests submitted yet.', style: AppTextStyles.itemSub)
                          else
                            for (final lv in app.myLeaveRequests)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(lv.reason, style: AppTextStyles.itemTitle.copyWith(fontSize: 13)),
                                          Text(lv.date, style: AppTextStyles.itemSub),
                                        ],
                                      ),
                                    ),
                                    StatusPill(label: lv.status, color: AppColors.orange, bgColor: AppColors.orangeBg),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget _prefSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      title: Text(label, style: AppTextStyles.itemSub.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    );
  }
}
