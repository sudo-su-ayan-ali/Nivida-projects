import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/app_header.dart';
import '../dashboard_screen.dart';
import '../my_children_screen.dart';
import '../attendance_screen.dart';
import '../academics_screen.dart';
import '../fees_screen.dart';
import '../examinations_screen.dart';
import '../homework_screen.dart';
import '../timetable_screen.dart';
import '../transport_screen.dart';
import '../library_screen.dart';
import '../notices_screen.dart';
import '../events_screen.dart';
import '../teacher_communication_screen.dart';
import '../settings_screen.dart';
import '../add_child_dialog.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Widget _buildSection(AppSection section) {
    switch (section) {
      case AppSection.dashboard:
        return const DashboardScreen();
      case AppSection.myChildren:
        return const MyChildrenScreen();
      case AppSection.attendance:
        return const AttendanceScreen();
      case AppSection.academics:
        return const AcademicsScreen();
      case AppSection.fees:
        return const FeesScreen();
      case AppSection.examinations:
        return const ExaminationsScreen();
      case AppSection.homework:
        return const HomeworkScreen();
      case AppSection.timetable:
        return const TimetableScreen();
      case AppSection.transport:
        return const TransportScreen();
      case AppSection.library:
        return const LibraryScreen();
      case AppSection.notices:
        return const NoticesScreen();
      case AppSection.events:
        return const EventsScreen();
      case AppSection.teacherCommunication:
        return const TeacherCommunicationScreen();
      case AppSection.settings:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.children.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  size: 48,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Students Linked',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'There are no students linked to this account yet.\nLink a child using their enrollment / admission number.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => showAddChildDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add / Link Child'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(state.section),
        padding: const EdgeInsets.all(20),
        child: _buildSection(state.section),
      ),
    );

    return Column(
      children: [
        const AppHeader(),
        if (state.section != AppSection.dashboard)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => state.goTo(AppSection.dashboard),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back to Dashboard'),
              ),
            ),
          ),
        Expanded(child: SingleChildScrollView(child: content)),
      ],
    );
  }
}