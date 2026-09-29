import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/student_repository.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'add_edit_student_screen.dart';

/// Student Profile with tabs: Overview | Academic | Attendance | Fees |
/// Documents | Parents | Transport | Hostel | Examinations | Communication
class StudentProfileScreen extends StatelessWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentRepository>(
      builder: (context, repo, _) {
        final s = repo.byId(studentId);
        if (s == null) {
          return const Scaffold(body: Center(child: Text('Student not found')));
        }
        return DefaultTabController(
          length: 10,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              title: Text(s.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: repo,
                        child: AddEditStudentScreen(student: s),
                      ),
                    ),
                  ),
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Academic'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Fees'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Parents'),
                  Tab(text: 'Transport'),
                  Tab(text: 'Hostel'),
                  Tab(text: 'Examinations'),
                  Tab(text: 'Communication'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _overviewTab(s),
                _academicTab(s),
                _attendanceTab(s),
                _feesTab(s),
                _documentsTab(s),
                _parentsTab(s),
                _transportTab(s),
                _hostelTab(s),
                _placeholderTab(
                  'Examinations',
                  'Exam schedule & results will appear here once wired to your exams module.',
                ),
                _placeholderTab(
                  'Communication',
                  'SMS/Email/Notice history with parents will appear here.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _overviewTab(Student s) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card(
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.purpleBg,
                child: Text(
                  s.name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 26,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.admissionNo} · Class ${s.classNum}${s.section}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(status: s.status),
                  ],
                ),
              ),
            ],
          ),
        ),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _row('Email', s.email),
              _row('Mobile', s.mobile),
              _row('Gender', s.gender),
              _row('Blood Group', s.bloodGroup),
              _row('Category', s.category),
              _row('Address', s.address),
            ],
          ),
        ),
      ],
    );
  }

  Widget _academicTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Details',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row('Class', '${s.classNum}'),
            _row('Section', s.section),
            _row(
              'Admission Date',
              '${s.admissionDate.day}/${s.admissionDate.month}/${s.admissionDate.year}',
            ),
            _row('Exam Average', '${s.examAveragePercent.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    ],
  );

  Widget _attendanceTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row(
              'Overall Attendance',
              '${s.attendancePercent.toStringAsFixed(0)}%',
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: s.attendancePercent / 100,
                minHeight: 8,
                backgroundColor: AppColors.border,
                color: s.attendancePercent < 75
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _feesTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fees & Payments',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row(
              'Fee Due',
              s.feeDue > 0 ? '₹${s.feeDue.toStringAsFixed(0)}' : 'No dues',
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Record Payment (wire to payment gateway/API)'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _documentsTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Verification',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row('Status', s.documentsVerified ? 'Verified' : 'Pending'),
            _row('ID Card', s.idCardGenerated ? 'Generated' : 'Not generated'),
          ],
        ),
      ),
    ],
  );

  Widget _parentsTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parent/Guardian',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row('Name', s.parentName),
            _row('Mobile', s.parentMobile),
          ],
        ),
      ),
    ],
  );

  Widget _transportTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transport',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row('Uses Transport', s.usesTransport ? 'Yes' : 'No'),
            if (s.usesTransport) _row('Route', s.transportRoute ?? '-'),
          ],
        ),
      ),
    ],
  );

  Widget _hostelTab(Student s) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hostel',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _row('Lives in Hostel', s.livesInHostel ? 'Yes' : 'No'),
            if (s.livesInHostel) _row('Hostel', s.hostelName ?? '-'),
          ],
        ),
      ),
    ],
  );

  Widget _placeholderTab(String title, String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}
