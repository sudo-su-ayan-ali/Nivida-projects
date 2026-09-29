import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = ref.watch(studentsProvider);
    final transactions = ref.watch(transactionsProvider);

    final q = _query.toLowerCase().trim();
    final studentResults = q.isEmpty
        ? <dynamic>[]
        : students.where((s) => s.name.toLowerCase().contains(q) || s.admissionNo.toLowerCase().contains(q)).take(5).toList();
    final receiptResults = q.isEmpty
        ? <dynamic>[]
        : transactions.where((t) => t.receiptNo.toLowerCase().contains(q) || t.studentName.toLowerCase().contains(q)).take(5).toList();

    const quickActions = [
      ('Go to Dashboard', Icons.dashboard_rounded, '/dashboard'),
      ('Collect Fee', Icons.point_of_sale_rounded, '/collect'),
      ('View Defaulters', Icons.warning_amber_rounded, '/defaulters'),
      ('Open Reports', Icons.bar_chart_rounded, '/reports'),
      ('Finance', Icons.account_balance_rounded, '/finance'),
      ('Day Closing', Icons.point_of_sale_outlined, '/day-closing'),
    ];
    final actionResults = q.isEmpty
        ? quickActions
        : quickActions.where((a) => a.$1.toLowerCase().contains(q)).toList();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ref.read(commandPaletteOpenProvider.notifier).state = false,
        child: Container(
          color: Colors.black.withOpacity(0.55),
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 110),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 560,
                constraints: const BoxConstraints(maxHeight: 480),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search students, receipts, or jump to a page…',
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (actionResults.isNotEmpty) _sectionLabel('Quick actions'),
                          for (final a in actionResults)
                            ListTile(
                              dense: true,
                              leading: Icon(a.$2, size: 18),
                              title: Text(a.$1),
                              onTap: () {
                                ref.read(commandPaletteOpenProvider.notifier).state = false;
                                context.go(a.$3);
                              },
                            ),
                          if (studentResults.isNotEmpty) _sectionLabel('Students'),
                          for (final s in studentResults)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.person_outline_rounded, size: 18),
                              title: Text(s.name),
                              subtitle: Text('${s.admissionNo} · Class ${s.className}-${s.section}'),
                              trailing: Text(Fmt.inr(s.totalDue), style: const TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () {
                                ref.read(commandPaletteOpenProvider.notifier).state = false;
                                context.go('/students/${s.id}');
                              },
                            ),
                          if (receiptResults.isNotEmpty) _sectionLabel('Receipts'),
                          for (final t in receiptResults)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.receipt_long_rounded, size: 18),
                              title: Text(t.receiptNo),
                              subtitle: Text(t.studentName),
                              trailing: Text(Fmt.inr(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () {
                                ref.read(commandPaletteOpenProvider.notifier).state = false;
                                context.go('/receipt/${t.receiptNo}');
                              },
                            ),
                          if (q.isNotEmpty && studentResults.isEmpty && receiptResults.isEmpty && actionResults.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: Text('No results found')),
                            ),
                        ],
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

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: Colors.grey)),
      );
}
