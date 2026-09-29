import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';

/// Opens a real, working detail dialog for a "Teaching Tools & Important
/// Links" card instead of leaving the tap a dead end. Content is scoped
/// mock data, but every dialog is fully interactive (scrollable, has a
/// working close button, and — for Leave Management — a working form).
void showQuickActionDialog(BuildContext context, QuickAction action) {
  showDialog(
    context: context,
    builder: (_) => _ActionDialogShell(action: action),
  );
}

class _ActionDialogShell extends StatelessWidget {
  final QuickAction action;
  const _ActionDialogShell({required this.action});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: action.bg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(action.icon, color: action.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(action.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                        Text(action.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(child: _bodyFor(action.title)),
          ],
        ),
      ),
    );
  }

  Widget _bodyFor(String title) {
    switch (title) {
      case 'My Timetable':
        return const _TimetableBody();
      case 'Leave Management':
        return const _LeaveManagementBody();
      case 'Class Allocation':
        return const _SimpleListBody(rows: _classAllocationRows);
      case 'Performance Report':
        return const _ProgressListBody(rows: _performanceRows);
      case 'Subject Allocation':
        return const _SimpleListBody(rows: _subjectAllocationRows);
      case 'Attendance Report':
        return const _ProgressListBody(rows: _attendanceRows);
      case 'Exam Schedule':
        return const _SimpleListBody(rows: _examScheduleRows);
      case 'Syllabus Coverage':
        return const _ProgressListBody(rows: _syllabusRows);
      default:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Text('No details available.', style: TextStyle(color: AppColors.textSecondary)),
        );
    }
  }
}

/// ---- My Timetable --------------------------------------------------
class _TimetableBody extends StatefulWidget {
  const _TimetableBody();
  @override
  State<_TimetableBody> createState() => _TimetableBodyState();
}

class _TimetableBodyState extends State<_TimetableBody> {
  int _day = 0;
  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const Map<int, List<_Period>> _schedule = {
    0: [
      _Period('8:00 – 8:45', 'Class 9A', 'Mathematics'),
      _Period('8:45 – 9:30', 'Class 10B', 'Mathematics'),
      _Period('10:15 – 11:00', 'Class 8C', 'Algebra'),
      _Period('12:30 – 1:15', 'Class 9A', 'Geometry'),
    ],
    1: [
      _Period('9:30 – 10:15', 'Class 10A', 'Mathematics'),
      _Period('11:00 – 11:45', 'Class 9B', 'Algebra'),
      _Period('1:15 – 2:00', 'Class 8A', 'Mathematics'),
    ],
    2: [
      _Period('8:00 – 8:45', 'Class 9A', 'Mathematics'),
      _Period('8:45 – 9:30', 'Class 10B', 'Mathematics'),
      _Period('2:00 – 2:45', 'Staff Room', 'Free Period'),
    ],
    3: [
      _Period('10:15 – 11:00', 'Class 8C', 'Algebra'),
      _Period('11:45 – 12:30', 'Class 10A', 'Geometry'),
      _Period('12:30 – 1:15', 'Class 9A', 'Mathematics'),
    ],
    4: [
      _Period('8:45 – 9:30', 'Class 10B', 'Mathematics'),
      _Period('9:30 – 10:15', 'Class 9B', 'Algebra'),
      _Period('1:15 – 2:00', 'Class 8A', 'Mathematics'),
    ],
    5: [
      _Period('8:00 – 8:45', 'Class 9A', 'Doubt Clearing'),
      _Period('8:45 – 9:30', 'Staff Room', 'Free Period'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final periods = _schedule[_day] ?? const [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < days.length; i++)
                _DayChip(label: days[i], selected: _day == i, onTap: () => setState(() => _day = i)),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final p = periods[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(p.time, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                          Text(p.room, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Period {
  final String time, room, subject;
  const _Period(this.time, this.room, this.subject);
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DayChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF4B5563))),
      ),
    );
  }
}

/// ---- Leave Management (genuinely interactive: apply + approve) -----
class _LeaveRequest {
  final String name;
  final String range;
  final String reason;
  String status;
  _LeaveRequest(this.name, this.range, this.reason, this.status);
}

class _LeaveManagementBody extends StatefulWidget {
  const _LeaveManagementBody();
  @override
  State<_LeaveManagementBody> createState() => _LeaveManagementBodyState();
}

class _LeaveManagementBodyState extends State<_LeaveManagementBody> {
  final List<_LeaveRequest> _requests = [
    _LeaveRequest('Mr. Sandeep Yadav', 'Aug 12 – Aug 14', 'Family function', 'Pending'),
    _LeaveRequest('Ms. Priya Verma', 'Aug 20', 'Medical appointment', 'Pending'),
    _LeaveRequest('Mr. Amit Kumar', 'Jul 28 – Jul 29', 'Personal', 'Approved'),
  ];

  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    if (_reasonCtrl.text.trim().isEmpty) return;
    setState(() {
      _requests.insert(0, _LeaveRequest('You (Admin User)', 'Selected dates', _reasonCtrl.text.trim(), 'Pending'));
      _reasonCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted.'), behavior: SnackBarBehavior.floating),
    );
  }

  void _setStatus(int i, String status) => setState(() => _requests[i].status = status);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _reasonCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Reason for leave...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: AppColors.background,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
            ],
          ),
        ),
        const Divider(height: 20, color: AppColors.border),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            itemCount: _requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = _requests[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(r.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                          Text('${r.range} · ${r.reason}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (r.status == 'Pending') ...[
                      _MiniActionButton(
                        label: 'Approve',
                        color: AppColors.success,
                        onTap: () => _setStatus(i, 'Approved'),
                      ),
                      const SizedBox(width: 6),
                      _MiniActionButton(
                        label: 'Reject',
                        color: AppColors.danger,
                        onTap: () => _setStatus(i, 'Rejected'),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: r.status == 'Approved' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(r.status,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: r.status == 'Approved' ? const Color(0xFF15803D) : const Color(0xFFB91C1C))),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MiniActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
      ),
    );
  }
}

/// ---- Generic simple list (Class Allocation / Subject Allocation / Exam Schedule)
class _SimpleRow {
  final String title;
  final String subtitle;
  final String trailing;
  const _SimpleRow(this.title, this.subtitle, this.trailing);
}

class _SimpleListBody extends StatelessWidget {
  final List<_SimpleRow> rows;
  const _SimpleListBody({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = rows[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                    Text(r.subtitle, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(r.trailing, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }
}

/// ---- Generic progress list (Performance / Attendance / Syllabus) ----
class _ProgressRow {
  final String title;
  final String subtitle;
  final double value; // 0..1
  const _ProgressRow(this.title, this.subtitle, this.value);
}

class _ProgressListBody extends StatelessWidget {
  final List<_ProgressRow> rows;
  const _ProgressListBody({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final r = rows[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                ),
                Text('${(r.value * 100).round()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(r.subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: r.value,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _classAllocationRows = [
  _SimpleRow('Class 9A', 'Mathematics · 38 students', 'Room 12'),
  _SimpleRow('Class 9B', 'Mathematics · 35 students', 'Room 14'),
  _SimpleRow('Class 10A', 'Mathematics · 40 students', 'Room 08'),
  _SimpleRow('Class 10B', 'Mathematics · 37 students', 'Room 09'),
  _SimpleRow('Class 8C', 'Algebra · 33 students', 'Room 05'),
];

const _subjectAllocationRows = [
  _SimpleRow('Mathematics', 'Classes 9A, 9B, 10A, 10B', '4 classes'),
  _SimpleRow('Algebra', 'Classes 8A, 8C', '2 classes'),
  _SimpleRow('Geometry', 'Class 9A, 10A', '2 classes'),
  _SimpleRow('Calculus', 'Class 12 Science', '1 class'),
];

const _examScheduleRows = [
  _SimpleRow('Unit Test — Algebra', 'Class 9A · Room 12', 'Aug 18'),
  _SimpleRow('Mid-Term — Mathematics', 'Class 10A · Room 08', 'Aug 25'),
  _SimpleRow('Unit Test — Geometry', 'Class 9B · Room 14', 'Sep 02'),
  _SimpleRow('Mid-Term — Mathematics', 'Class 10B · Room 09', 'Sep 05'),
];

const _performanceRows = [
  _ProgressRow('Class 9A average score', 'Last unit test', 0.82),
  _ProgressRow('Class 9B average score', 'Last unit test', 0.74),
  _ProgressRow('Class 10A average score', 'Mid-term', 0.88),
  _ProgressRow('Class 10B average score', 'Mid-term', 0.69),
];

const _attendanceRows = [
  _ProgressRow('Class 9A', 'This month', 0.96),
  _ProgressRow('Class 9B', 'This month', 0.91),
  _ProgressRow('Class 10A', 'This month', 0.94),
  _ProgressRow('Class 10B', 'This month', 0.88),
];

const _syllabusRows = [
  _ProgressRow('Mathematics — Class 9', 'Chapters 1–14', 0.71),
  _ProgressRow('Mathematics — Class 10', 'Chapters 1–15', 0.63),
  _ProgressRow('Algebra — Class 8', 'Chapters 1–10', 0.80),
];
