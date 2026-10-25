import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class GateLogEntry {
  final String studentName;
  final String room;
  final String direction; // 'In' or 'Out'
  final String time;
  final String purpose;
  final String gateNumber;

  const GateLogEntry({
    required this.studentName,
    required this.room,
    required this.direction,
    required this.time,
    required this.purpose,
    this.gateNumber = "Gate #1",
  });
}

class CheckinCheckoutCard extends ConsumerStatefulWidget {
  const CheckinCheckoutCard({super.key});

  @override
  ConsumerState<CheckinCheckoutCard> createState() => _CheckinCheckoutCardState();
}

class _CheckinCheckoutCardState extends ConsumerState<CheckinCheckoutCard> {
  final List<GateLogEntry> _entries = [
    const GateLogEntry(
      studentName: "Rohan Kumar",
      room: "B-205",
      direction: "Out",
      time: "06:40 PM",
      purpose: "Evening walk & library reference",
    ),
    const GateLogEntry(
      studentName: "Aarav Sharma",
      room: "A-103",
      direction: "In",
      time: "07:05 PM",
      purpose: "Returned from remedial class",
    ),
    const GateLogEntry(
      studentName: "Vivek Patel",
      room: "C-302",
      direction: "Out",
      time: "05:50 PM",
      purpose: "Sports ground practice",
    ),
    const GateLogEntry(
      studentName: "Aditya Singh",
      room: "A-101",
      direction: "In",
      time: "07:20 PM",
      purpose: "Returned from library",
    ),
  ];

  void _showNewGateEntryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    String direction = "Out";

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              title: const Row(
                children: [
                  Icon(Icons.door_sliding_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text("Quick Gate Pass Entry", style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("Exit / Check-Out")),
                            selected: direction == "Out",
                            selectedColor: AppColors.warning.withOpacity(0.2),
                            onSelected: (val) {
                              if (val) setDlgState(() => direction = "Out");
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("Entry / Check-In")),
                            selected: direction == "In",
                            selectedColor: AppColors.success.withOpacity(0.2),
                            onSelected: (val) {
                              if (val) setDlgState(() => direction = "In");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Student Name",
                        hintText: "e.g. Rahul Verma",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomCtrl,
                      decoration: InputDecoration(
                        labelText: "Room Number",
                        hintText: "e.g. B-104",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: purposeCtrl,
                      decoration: InputDecoration(
                        labelText: "Purpose / Destination",
                        hintText: "e.g. Market visit / Coaching / Medical",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final now = DateTime.now();
                    final timeStr =
                        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

                    setState(() {
                      _entries.insert(
                        0,
                        GateLogEntry(
                          studentName: name,
                          room: roomCtrl.text.trim().isEmpty ? "Unassigned" : roomCtrl.text.trim(),
                          direction: direction,
                          time: timeStr,
                          purpose: purposeCtrl.text.trim().isEmpty ? "General exit/entry" : purposeCtrl.text.trim(),
                        ),
                      );
                    });
                    Navigator.of(dialogCtx).pop();
                    showAppSnackBar(context, "Gate pass logged successfully for $name.");
                  },
                  child: const Text("Save Entry"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEntryDetailDialog(BuildContext context, GateLogEntry entry) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(entry.studentName, style: const TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Room Assigned", entry.room),
              const SizedBox(height: 8),
              _detailRow("Movement", entry.direction == "In" ? "Check-In (Returned)" : "Check-Out (Exited)"),
              const SizedBox(height: 8),
              _detailRow("Timestamp", entry.time),
              const SizedBox(height: 8),
              _detailRow("Gate Location", entry.gateNumber),
              const SizedBox(height: 8),
              _detailRow("Purpose / Note", entry.purpose),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader(title: "Live Gate Check-In / Check-Out")),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showNewGateEntryDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Log Pass", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: "Open Full Visitors Screen",
                icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textSecondary),
                onPressed: () => context.push('/visitors'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._entries.map(
            (e) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => _showEntryDetailDialog(context, e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      StatusBadge(status: e.direction == "In" ? "Present" : "Late"),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${e.studentName} · ${e.room}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              e.purpose,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(e.time, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
