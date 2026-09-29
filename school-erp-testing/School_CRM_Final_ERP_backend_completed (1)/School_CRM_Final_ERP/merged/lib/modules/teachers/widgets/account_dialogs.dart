import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small reusable preference row used inside the settings dialog.
class _PrefRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PrefRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

/// Opens a working preferences dialog (local-only state, but genuinely
/// toggle-able and closes cleanly) — shared by the header gear icon and
/// the sidebar's admin "Settings" menu entry.
void showAccountSettingsDialog(BuildContext context) {
  bool emailAlerts = true;
  bool smsAlerts = false;
  bool autoSync = true;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Preferences', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text)),
                    ),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, size: 20)),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                _PrefRow(
                  title: 'Email Notifications',
                  subtitle: 'Leave approvals, exam reminders',
                  value: emailAlerts,
                  onChanged: (v) => setSheet(() => emailAlerts = v),
                ),
                _PrefRow(
                  title: 'SMS Alerts',
                  subtitle: 'Urgent announcements only',
                  value: smsAlerts,
                  onChanged: (v) => setSheet(() => smsAlerts = v),
                ),
                _PrefRow(
                  title: 'Auto-Sync Timetable',
                  subtitle: 'Keep My Timetable up to date',
                  value: autoSync,
                  onChanged: (v) => setSheet(() => autoSync = v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preferences saved.'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Working "My Profile" dialog for the admin account.
void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 34, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white, size: 32)),
              const SizedBox(height: 14),
              const Text('Admin User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 2),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                child: const Text('Super Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
              const SizedBox(height: 16),
              const _ProfileInfoLine(icon: Icons.email_outlined, text: 'admin@greenfield.edu.in'),
              const SizedBox(height: 8),
              const _ProfileInfoLine(icon: Icons.school_outlined, text: 'Greenfield Public School'),
              const SizedBox(height: 8),
              const _ProfileInfoLine(icon: Icons.calendar_today_outlined, text: 'Session 2024–25'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProfileInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProfileInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)))),
      ],
    );
  }
}

/// Confirmation dialog for the sidebar Logout entry.
Future<void> showLogoutConfirm(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to access the dashboard.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  if (confirm == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have been logged out.'), behavior: SnackBarBehavior.floating),
    );
  }
}
