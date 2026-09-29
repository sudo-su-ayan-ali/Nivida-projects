import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';

class ParentNavItem {
  final AppSection section;
  final String label;
  final IconData icon;
  const ParentNavItem(this.section, this.label, this.icon);
}

const kParentSectionItems = [
  ParentNavItem(AppSection.dashboard, 'Dashboard', Icons.grid_view_rounded),
  ParentNavItem(AppSection.myChildren, 'My Children', Icons.family_restroom_outlined),
  ParentNavItem(AppSection.attendance, 'Attendance', Icons.fact_check_outlined),
  ParentNavItem(AppSection.academics, 'Academics', Icons.school_outlined),
  ParentNavItem(AppSection.fees, 'Fees & Payments', Icons.account_balance_wallet_outlined),
  ParentNavItem(AppSection.examinations, 'Examinations', Icons.edit_note_outlined),
  ParentNavItem(AppSection.homework, 'Homework', Icons.menu_book_outlined),
  ParentNavItem(AppSection.timetable, 'Timetable', Icons.calendar_view_week_outlined),
  ParentNavItem(AppSection.transport, 'Transport', Icons.directions_bus_outlined),
  ParentNavItem(AppSection.library, 'Library', Icons.local_library_outlined),
  ParentNavItem(AppSection.notices, 'Notices', Icons.campaign_outlined),
  ParentNavItem(AppSection.events, 'Events', Icons.event_outlined),
  ParentNavItem(AppSection.teacherCommunication, 'Teacher Communication', Icons.chat_bubble_outline),
  ParentNavItem(AppSection.settings, 'Settings', Icons.settings_outlined),
];
/// Compact horizontal replacement for the Parents module's own vertical
/// sidebar. The outer EduSmart shell already has a Sidebar with a
/// "Parents" entry, so this pane only needs a lightweight way to switch
/// between the Parent-specific sections (Dashboard, My Children, Fees,
/// etc.) without stacking a second full-height sidebar next to the main
/// one.
class ParentSectionTabs extends StatelessWidget {
  const ParentSectionTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: kParentSectionItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = kParentSectionItems[i];
          final selected = state.section == item.section;
          return Material(
            color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => state.goTo(item.section),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon,
                        size: 16,
                        color: selected ? AppColors.primary : const Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.primary : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
