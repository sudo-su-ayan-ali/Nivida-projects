import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/attendance_donut_chart.dart';
import '../widgets/payment_modal.dart';
import '../widgets/section_card.dart';
import '../widgets/section_tabs.dart';
import '../widgets/stat_card.dart';
import 'add_child_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
 static const double kSideCardHeight = 260;
   static const double kBottomCardHeight = 280; 
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(context, state),
        const SizedBox(height: 20),
        _statRow(context, state, child, currency),
        const SizedBox(height: 20),
        isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _myChildrenCard(context, state)),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _attendanceCard(context, child)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _academicSummaryCard(context, state),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _myChildrenCard(context, state),
                  const SizedBox(height: 20),
                  _attendanceCard(context, child),
                  const SizedBox(height: 20),
                  _academicSummaryCard(context, state),
                ],
              ),
        const SizedBox(height: 20),
        isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _feeSummaryCard(context, child, currency),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _recentNoticesCard(context, state),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _upcomingEventsCard(context, state),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _feeSummaryCard(context, child, currency),
                  const SizedBox(height: 20),
                  _recentNoticesCard(context, state),
                  const SizedBox(height: 20),
                  _upcomingEventsCard(context, state),
                ],
              ),
        const SizedBox(height: 20),
isWide
    ? Row(
        crossAxisAlignment: CrossAxisAlignment.start, // wapas 'start' kar diya
        children: [
          Expanded(
            flex: 2,
            child: _teacherCommunicationCard(context, state),
          ),
          const SizedBox(width: 20),
          Expanded(flex: 1, child: _quickLinksCard(context, state)),
        ],
      )
    : Column(
        children: [
          _teacherCommunicationCard(context, state),
          const SizedBox(height: 20),
          _quickLinksCard(context, state),
        ],
      ),
        const SizedBox(height: 20),
        _navigationMenu(context, state),
      ],
    );
  }

  Widget _navigationMenu(BuildContext context, AppStateProvider state) {
    final items = kParentSectionItems
        .where((n) => n.section != AppSection.dashboard)
        .toList();
    return _AnimatedMenuBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Navigation Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 241, 239, 239),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = 4;
              double ratio = 2.4;
              if (constraints.maxWidth < 600) {
                cols = 1;
                ratio = 3.5;
              } else if (constraints.maxWidth < 900) {
                cols = 2;
                ratio = 2.5;
              } else if (constraints.maxWidth < 1200) {
                cols = 3;
                ratio = 2.4;
              }
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: ratio,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  return _ParentNavTile(
                    item: item,
                    index: i,
                    onTap: () => state.goTo(item.section),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

 Widget _pageHeader(BuildContext context, AppStateProvider state) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Parents Dashboard',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        "Welcome back! Here's an overview of your children's progress and activities.",
        style: TextStyle(color: const Color.fromARGB(255, 238, 239, 242), fontSize: 18.5),
      ),
    ],
  );
}

  Widget _statRow(
    BuildContext context,
    AppStateProvider state,
    ChildRecord child,
    NumberFormat currency,
  ) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1200
        ? 5
        : (width >= 800 ? 3 : (width >= 560 ? 2 : 1));

    final cards = [
      StatCard(
        label: 'My Children',
        value: '${state.children.length}',
        subLabel: 'Children Enrolled',
        icon: Icons.groups_2_outlined,
        color: AppColors.primary,
        onTap: () => state.goTo(AppSection.myChildren),
      ),
      StatCard(
        label: 'Attendance',
        value: '${child.attendance.presentPercent.round()}%',
        subLabel: 'Average This Month',
        icon: Icons.fact_check_outlined,
        color: AppColors.info,
        onTap: () => state.goTo(AppSection.attendance),
      ),
      StatCard(
        label: 'Academic Performance',
        value: child.academics.overallGrade,
        subLabel: 'Average Grade',
        icon: Icons.menu_book_outlined,
        color: AppColors.warning,
        onTap: () => state.goTo(AppSection.academics),
      ),
      StatCard(
        label: 'Fees Due',
        value: currency.format(child.fees.dueAmount),
        subLabel: 'Due Amount',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.success,
        onTap: () => state.goTo(AppSection.fees),
      ),
      StatCard(
        label: 'Unread Notices',
        value: '${state.unreadNoticeCount}',
        subLabel: 'New Notifications',
        icon: Icons.notifications_active_outlined,
        color: AppColors.secondary,
        onTap: () => state.goTo(AppSection.notices),
      ),
    ];

  return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: cards.length,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    mainAxisExtent: 160,
  ),
  itemBuilder: (context, index) => cards[index],
);
  }

 Widget _myChildrenCard(BuildContext context, AppStateProvider state) {
  return SectionCard(
    title: 'My Children',
    trailing: TextButton(
      onPressed: () => state.goTo(AppSection.myChildren),
      child: const Text('View All'),
    ),
    child: Column(
      children: [
        SizedBox(
          height: 260, // <-- yahi height fix karti hai, jitna chahiye utna badhao/ghatao
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _childTile(context, state, state.children[index]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showAddChildDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add / Link Another Child'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color.fromARGB(255, 6, 6, 241)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _childTile(
    BuildContext context,
    AppStateProvider state,
    ChildRecord record,
  ) {
    final selected = record.student.id == state.selectedChild.student.id;
    return Material(
      color: selected
          ? AppColors.statBg(AppColors.primary)
          : AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => state.selectChildById(record.student.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: record.student.avatarColor,
                child: Text(
                  record.student.avatarInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Class ${record.student.className} · Roll No. ${record.student.rollNo}',
                      style: TextStyle(fontSize: 11.5, color: const Color.fromARGB(255, 245, 246, 247)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          record.student.active ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: const Color.fromARGB(255, 246, 246, 248)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attendanceCard(BuildContext context, ChildRecord child) {
    final s = child.attendance;
    final state = context.read<AppStateProvider>();
    return SectionCard(
      title: 'Attendance Overview (This Month)',
      trailing: TextButton(
        onPressed: () => state.goTo(AppSection.attendance),
        child: const Text('View Details'),
      ),
      child: Column(
        children: [
          Center(child: AttendanceDonutChart(summary: s)),
          const SizedBox(height: 16),
          _legendRow(
            'Present',
            '${s.presentDays} Days (${s.presentPercent.round()}%)',
            AppColors.success,
          ),
          const SizedBox(height: 8),
          _legendRow(
            'Late',
            '${s.lateDays} Days (${s.latePercent.round()}%)',
            AppColors.warning,
          ),
          const SizedBox(height: 8),
          _legendRow(
            'Absent',
            '${s.absentDays} Days (${s.absentPercent.round()}%)',
            AppColors.danger,
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 18.5, color: const Color.fromARGB(255, 241, 242, 243))),
      ],
    );
  }

 Widget _academicSummaryCard(BuildContext context, AppStateProvider state) {
  return SectionCard(
    title: 'Academic Summary',
    
    child: SizedBox(
      height: 260, // dono card ki height same rakhna better lagega
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.children.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) =>
              _academicChildBlock(state.children[index]),
        ),
      ),
    ),
  );
}


  Widget _academicChildBlock(ChildRecord record) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: record.student.avatarColor,
                child: Text(
                  record.student.avatarInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${record.student.name} (Class ${record.student.className})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statBg(AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.academics.overallGrade,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final sub in record.academics.subjects)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        sub.subject,
                        style: TextStyle(fontSize: 10, color: const Color.fromARGB(255, 239, 240, 241)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sub.grade,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeSummaryCard(
    BuildContext context,
    ChildRecord child,
    NumberFormat currency,
  ) {
    final f = child.fees;
    return SectionCard(
      title: 'Fee Summary',
      trailing: TextButton(
        onPressed: () => context.read<AppStateProvider>().goTo(AppSection.fees),
        child: const Text('View Details'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _feeStat('Total Fees (This Year)', currency.format(f.totalFees)),
              _feeStat(
                'Paid Amount',
                currency.format(f.paidAmount),
                color: AppColors.success,
              ),
              _feeStat(
                'Due Amount',
                currency.format(f.dueAmount),
                color: AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: f.paidPercent / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${f.paidPercent.round()}% Paid',
            style: TextStyle(fontSize: 11.5, color: const Color.fromARGB(255, 238, 239, 242)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: f.dueAmount <= 0
                  ? null
                  : () => showPaymentModal(context, child: child),
              child: Text(f.dueAmount <= 0 ? 'Fully Paid' : 'Pay Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeStat(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: const Color.fromARGB(255, 241, 242, 244)),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentNoticesCard(BuildContext context, AppStateProvider state) {
    final notices = state.notices.take(3).toList();
    return SectionCard(
      title: 'Recent Notices',
      trailing: TextButton(
        onPressed: () => state.goTo(AppSection.notices),
        child: const Text('View All'),
      ),
      child: Column(
        children: [
          for (final n in notices) ...[
            _noticeTile(context, state, n),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _noticeTile(BuildContext context, AppStateProvider state, Notice n) {
    return InkWell(
      onTap: () => state.markNoticeRead(n.id),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.statBg(n.color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(n.icon, size: 17, color: n.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  n.description,
                  style: TextStyle(fontSize: 11.5, color: const Color.fromARGB(255, 246, 247, 249)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _timeAgo(n.postedAt),
            style: TextStyle(fontSize: 10.5, color: const Color.fromARGB(255, 244, 245, 247)),
          ),
        ],
      ),
    );
  }

Widget _upcomingEventsCard(BuildContext context, AppStateProvider state) {
  final events = state.events;
  return SectionCard(
    title: 'Upcoming Events',
    trailing: TextButton(
      onPressed: () => state.goTo(AppSection.events),
      child: const Text('View Calendar'),
    ),
    child: SizedBox(
      height: 260, // Fee Summary card jitni height rakhi, taaki row match ho
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _eventTile(events[index]),
        ),
      ),
    ),
  );
}

  Widget _eventTile(SchoolEvent e) {
    final month = DateFormat('MMM').format(e.date).toUpperCase();
    final day = DateFormat('dd').format(e.date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.statBg(AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                day,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                e.description,
                style: TextStyle(fontSize: 11, color: const Color.fromARGB(255, 250, 250, 251)),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _teacherCommunicationCard(
  BuildContext context,
  AppStateProvider state,
) {
  final threads = state.threads;
  return SectionCard(
    title: 'Teacher Communication',
    trailing: TextButton(
      onPressed: () => state.goTo(AppSection.teacherCommunication),
      child: const Text('View All'),
    ),
    child: SizedBox(
      height: 280, // Quick Links jitni height, dono jagah same number rakhna
      child: threads.isEmpty
          ? const Center(
              child: Text(
                'No messages yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: threads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _threadTile(context, state, threads[index]),
              ),
            ),
    ),
  );
}

  Widget _threadTile(
    BuildContext context,
    AppStateProvider state,
    TeacherThread t,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        state.openThread(t.id);
        state.goTo(AppSection.teacherCommunication);
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: t.avatarColor,
            child: Text(
              t.avatarInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.teacherName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  t.subject,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color.fromARGB(255, 56, 56, 62),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  t.lastMessagePreview,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _timeAgo(t.lastMessageTime),
                style: TextStyle(
                  fontSize: 10.5,
                  color: const Color.fromARGB(255, 23, 23, 25),
                ),
              ),
              const SizedBox(height: 6),
              if (t.unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

Widget _quickLinksCard(BuildContext context, AppStateProvider state) {
  return SectionCard(
    title: 'Quick Links',
    child: SizedBox(
      height: 280, // Teacher Communication jitni hi height — dono me same number
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width >= 1100 ? 2 : 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          for (final q in state.quickLinks) _quickLinkTile(context, state, q),
        ],
      ),
    ),
  );
}

  Widget _quickLinkTile(
    BuildContext context,
    AppStateProvider state,
    QuickLink q,
  ) {
    return Material(
      color: const Color.fromARGB(255, 229, 255, 255),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _routeForQuickLink(state, q.label),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.statBg(q.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(q.icon, size: 18, color: q.color),
              ),
              const SizedBox(height: 8),
              Text(
                q.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _routeForQuickLink(AppStateProvider state, String label) {
    switch (label) {
      case 'View Timetable':
        state.goTo(AppSection.timetable);
        break;
      case 'Homework':
        state.goTo(AppSection.homework);
        break;
      case 'Exam Schedule':
        state.goTo(AppSection.examinations);
        break;
      case 'Download Reports':
        state.goTo(AppSection.academics);
        break;
      case 'Leave Application':
        state.goTo(AppSection.settings);
        break;
      case 'Transport Info':
        state.goTo(AppSection.transport);
        break;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ParentNavTile extends StatefulWidget {
  final ParentNavItem item;
  final int index;
  final VoidCallback onTap;
  const _ParentNavTile({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ParentNavTile> createState() => _ParentNavTileState();
}

class _ParentNavTileState extends State<_ParentNavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.index * 35),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovering
              ? (Matrix4.identity()..scale(1.04))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              222,
              224,
              255,
            ).withOpacity(_hovering ? 0.22 : 0.13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(_hovering ? 0.55 : 0.25),
              width: _hovering ? 1.5 : 1,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        65,
                        62,
                        62,
                      ).withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: const Color.fromARGB(0, 0, 0, 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          8,
                          8,
                          8,
                        ).withOpacity(_hovering ? 0.3 : 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.item.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 241, 238, 238),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuBackground extends StatefulWidget {
  final Widget child;
  const _AnimatedMenuBackground({required this.child});

  @override
  State<_AnimatedMenuBackground> createState() =>
      _AnimatedMenuBackgroundState();
}

class _AnimatedMenuBackgroundState extends State<_AnimatedMenuBackground>
    with SingleTickerProviderStateMixin {
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();
  Size _lastSize = Size.zero;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _ensureParticles(Size size) {
    if (_particles.isNotEmpty && _lastSize == size) return;
    _lastSize = size;
    _particles.clear();
    for (int i = 0; i < 45; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 6 + _rng.nextDouble() * 10;
      _particles.add(
        _Particle(
          position: Offset(
            _rng.nextDouble() * size.width,
            _rng.nextDouble() * size.height,
          ),
          velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
          radius: 1.2 + _rng.nextDouble() * 1.8,
          twinklePhase: _rng.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  void _stepParticles(Size size, double dt) {
    for (final p in _particles) {
      p.position += p.velocity * dt;
      if (p.position.dx < -10)
        p.position = Offset(size.width + 10, p.position.dy);
      if (p.position.dx > size.width + 10)
        p.position = Offset(-10, p.position.dy);
      if (p.position.dy < -10)
        p.position = Offset(p.position.dx, size.height + 10);
      if (p.position.dy > size.height + 10)
        p.position = Offset(p.position.dx, -10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1224), Color.fromARGB(255, 16, 21, 40), Color(0xFF1B1440)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      if (size.width > 0 && size.height > 0) {
                        _ensureParticles(size);
                        _stepParticles(size, 1 / 60);
                      }
                      return CustomPaint(
                        painter: _ParticleNetworkPainter(
                          particles: _particles,
                          time: _controller.value,
                        ),
                        size: size,
                      );
                    },
                  );
                },
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                child: Container(color: const Color.fromARGB(14, 11, 11, 11)),
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  double twinklePhase;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.twinklePhase,
  });
}

class _ParticleNetworkPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  static const double _linkDistance = 110;
  static const Color _accent = Color(0xFF818CF8);

  _ParticleNetworkPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final a = particles[i].position;
        final b = particles[j].position;
        final dist = (a - b).distance;
        if (dist < _linkDistance) {
          final opacity = (1 - dist / _linkDistance) * 0.28;
          linePaint.color = _accent.withOpacity(opacity);
          canvas.drawLine(a, b, linePaint);
        }
      }
    }

    for (final p in particles) {
      final twinkle =
          0.55 + 0.45 * math.sin(time * 2 * math.pi * 3 + p.twinklePhase);
      dotPaint.color = _accent.withOpacity(0.75 * twinkle);
      canvas.drawCircle(p.position, p.radius, dotPaint);
      dotPaint.color = _accent.withOpacity(0.15 * twinkle);
      canvas.drawCircle(p.position, p.radius * 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleNetworkPainter oldDelegate) => true;
}
