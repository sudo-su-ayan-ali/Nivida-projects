import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class SeatingScreen extends StatefulWidget {
  const SeatingScreen({super.key});

  @override
  State<SeatingScreen> createState() => _SeatingScreenState();
}

class _SeatingScreenState extends State<SeatingScreen> {
  String? _selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final canManage = store.can(Permission.manageSeating);
    final canAssign = store.can(Permission.assignInvigilators);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Expanded(
                  child: PageHeader(title: 'Seating & Invigilator Management', subtitle: 'Seat plan generation and invigilator duty roster'),
                ),
                if (canManage)
                  OutlinedButton.icon(
                    onPressed: () => _addRoom(context, store),
                    icon: const Icon(Icons.meeting_room_outlined, size: 16),
                    label: const Text('Add Room'),
                  ),
                const SizedBox(width: 8),
                if (canAssign)
                  OutlinedButton.icon(
                    onPressed: () => _addInvigilator(context, store),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label: const Text('Add Invigilator'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (store.rooms.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      canManage
                          ? 'Koi room abhi tak nahi bana. "Add Room" button dabao.'
                          : 'Koi room abhi tak nahi bana.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            )
          else
            _buildBody(context, store, canManage, canAssign),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppStore store, bool canManage, bool canAssign) {
    _selectedRoomId ??= store.rooms.first.id;
    final room = store.rooms.firstWhere((r) => r.id == _selectedRoomId, orElse: () => store.rooms.first);
    final seats = store.seats.where((s) => s.roomId == room.id).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    DropdownButton<String>(
                      value: room.id,
                      items: store.rooms
                          .map((r) => DropdownMenuItem(value: r.id, child: Text('${r.name}  •  Capacity ${r.capacity}')))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRoomId = v),
                    ),
                    const Spacer(),
                    if (canManage)
                      TextButton.icon(
                        onPressed: () => _generateSeats(context, store, room),
                        icon: const Icon(Icons.grid_view_rounded, size: 16),
                        label: const Text('Generate Seats'),
                      ),
                    const StatusBadge('Auto-arranged', color: AppColors.info),
                  ]),
                  const SizedBox(height: 14),
                  if (seats.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Is room ke liye abhi seats nahi bani — "Generate Seats" dabao.', style: const TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
                      itemCount: seats.length,
                      itemBuilder: (_, i) {
                        final s = seats[i];
                        final occupied = s.studentId != null;
                        return Container(
                          decoration: BoxDecoration(
                            color: occupied ? AppColors.primary.withOpacity(0.1) : AppColors.bg,
                            border: Border.all(color: occupied ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(s.seatCode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: occupied ? AppColors.primary : AppColors.textSecondary)),
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  Row(children: const [
                    _LegendDot(color: AppColors.primary, label: 'Occupied'),
                    SizedBox(width: 14),
                    _LegendDot(color: AppColors.border, label: 'Available'),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Invigilator Duty', style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (canAssign && store.invigilators.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _assignDuty(context, store, room),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Assign'),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  if (store.invigilators.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Pehle "Add Invigilator" se invigilator banao.', style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                  ...store.duties.where((d) => d.roomId == room.id).map((d) {
                    final invig = store.invigilators.firstWhere((i) => i.id == d.invigilatorId, orElse: () => Invigilator(userId: '', name: 'Unassigned'));
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                      title: Text(invig.name),
                      subtitle: Text('${store.subjectById(d.subjectId)?.name ?? d.subjectId}'),
                      trailing: d.substituteNeeded ? const StatusBadge('Substitute needed', color: AppColors.warning) : const StatusBadge('Assigned', color: AppColors.success),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addRoom(BuildContext context, AppStore store) {
    final nameCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Room name (e.g. Hall A)')),
          const SizedBox(height: 10),
          TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              store.upsertRoom(ExamRoom(name: nameCtrl.text.trim(), capacity: int.tryParse(capCtrl.text) ?? 30));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addInvigilator(BuildContext context, AppStore store) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Invigilator'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Invigilator name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              store.upsertInvigilator(Invigilator(userId: '', name: nameCtrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _generateSeats(BuildContext context, AppStore store, ExamRoom room) {
    final exam = store.exams.isNotEmpty ? store.exams.first : null;
    if (exam == null) return;
    final existing = store.seats.where((s) => s.roomId == room.id).length;
    for (int i = existing; i < room.capacity; i++) {
      final code = 'A${(i + 1).toString().padLeft(2, '0')}';
      store.upsertSeatAssignment(SeatAssignment(examId: exam.id, roomId: room.id, seatCode: code));
    }
  }

  void _assignDuty(BuildContext context, AppStore store, ExamRoom room) {
    final exam = store.exams.isNotEmpty ? store.exams.first : null;
    if (exam == null || store.subjects.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Invigilator'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: store.invigilators
                .map((i) => ListTile(
                      title: Text(i.name),
                      leading: const Icon(Icons.person_outline),
                      onTap: () {
                        store.upsertDuty(InvigilatorDuty(
                          examId: exam.id,
                          roomId: room.id,
                          subjectId: store.subjects.first.id,
                          invigilatorId: i.id,
                        ));
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]);
}

class ExamHallScreen extends StatelessWidget {
  const ExamHallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.first;
    final studentsInExam = store.students;
    final present = (studentsInExam.length * 0.95).round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Exam Hall Management', subtitle: 'Attendance and answer-book distribution / collection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 14, runSpacing: 14, children: [
              StatCard(label: 'Students', value: '${studentsInExam.length}', icon: Icons.groups_rounded),
              StatCard(label: 'Present', value: '$present', icon: Icons.check_circle_rounded, color: AppColors.success),
              StatCard(label: 'Absent', value: '${studentsInExam.length - present}', icon: Icons.remove_circle_rounded, color: AppColors.danger),
              StatCard(label: 'Books Distributed', value: '${store.books.where((b) => b.status.index >= BookStatus.distributed.index).length}', icon: Icons.assignment_turned_in_rounded, color: AppColors.info),
              StatCard(label: 'Books Collected', value: '${store.books.where((b) => b.status.index >= BookStatus.collected.index).length}', icon: Icons.inventory_2_rounded, color: AppColors.warning),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attendance Roll', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...studentsInExam.take(10).map((s) {
                    final book = store.books.firstWhere((b) => b.studentId == s.id, orElse: () => AnonymousBook(anonId: '-', examId: exam.id, subjectId: 'sub_math'));
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Text(s.rollNo, style: const TextStyle(fontWeight: FontWeight.w600)),
                      title: Text(s.name),
                      subtitle: Text('Book: ${book.anonId}'),
                      trailing: const StatusBadge('Present', color: AppColors.success),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
