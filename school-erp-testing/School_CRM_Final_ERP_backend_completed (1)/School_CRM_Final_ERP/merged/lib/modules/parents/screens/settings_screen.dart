import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Manage your account preferences.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Profile',
          child: Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: AppColors.primary, child: Text('PU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parent User', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('parent.user@email.com', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  ],
                ),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Edit Profile')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Preferences',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Switch between light and dark theme', style: TextStyle(fontSize: 12)),
                value: state.isDark,
                onChanged: (_) => state.toggleTheme(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Receive alerts for notices and messages', style: TextStyle(fontSize: 12)),
                value: true,
                onChanged: (_) {},
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Email Updates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Weekly summary of your children\'s activity', style: TextStyle(fontSize: 12)),
                value: false,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Quick Actions',
          child: Column(
            children: [
              _actionTile(context, Icons.event_note_outlined, 'Leave Application', 'Submit a leave request for your child'),
              _actionTile(context, Icons.download_outlined, 'Downloads Center', 'Access all your downloaded documents'),
              _actionTile(context, Icons.feedback_outlined, 'Complaint / Feedback', 'Share your feedback with the school'),
              _actionTile(context, Icons.support_agent_outlined, 'Support', 'Get help from the EduSmart support team'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title opened.'))),
    );
  }
}
