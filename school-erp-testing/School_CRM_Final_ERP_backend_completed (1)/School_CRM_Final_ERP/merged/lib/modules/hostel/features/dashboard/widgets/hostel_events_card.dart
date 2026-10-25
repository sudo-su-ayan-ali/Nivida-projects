import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class HostelEventItem {
  final String day;
  final String month;
  final String title;
  final String subtitle;
  final String description;
  final String coordinator;

  const HostelEventItem({
    required this.day,
    required this.month,
    required this.title,
    required this.subtitle,
    this.description = "All hostel residents are required to participate or adhere to standard schedule.",
    this.coordinator = "Hostel Admin Office",
  });
}

class HostelEventsCard extends ConsumerStatefulWidget {
  const HostelEventsCard({super.key});

  @override
  ConsumerState<HostelEventsCard> createState() => _HostelEventsCardState();
}

class _HostelEventsCardState extends ConsumerState<HostelEventsCard> {
  final List<HostelEventItem> _events = [
    const HostelEventItem(
      day: "28",
      month: "MAY",
      title: "Fire Safety Drill",
      subtitle: "All Blocks · 5:00 PM",
      description: "Mandatory campus evacuation drill conducted in coordination with the city Fire Services team.",
      coordinator: "Chief Security Officer & Wardens",
    ),
    const HostelEventItem(
      day: "31",
      month: "MAY",
      title: "Hostel Inspection",
      subtitle: "Block A & B · 10:00 AM",
      description: "Quarterly hygiene, electrical fitting, and room inventory audit conducted by the administrative inspection panel.",
      coordinator: "Hostel Superintendent",
    ),
    const HostelEventItem(
      day: "02",
      month: "JUN",
      title: "Cultural Night",
      subtitle: "Common Hall · 7:00 PM",
      description: "Inter-block music, drama, and dining celebration organized by the Student Hostel Committee.",
      coordinator: "Cultural Secretary & Wardens",
    ),
  ];

  void _showAddEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              title: const Row(
                children: [
                  Icon(Icons.event_note_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text("Schedule Hostel Event", style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: "Event Title",
                        hintText: "e.g., Pest Control Drive / Townhall",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: locationCtrl,
                            decoration: InputDecoration(
                              labelText: "Location / Block",
                              hintText: "e.g. Block C / Mess",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: timeCtrl,
                            decoration: InputDecoration(
                              labelText: "Time",
                              hintText: "e.g. 04:00 PM",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDlgState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              "Date: ${selectedDate.day.toString().padLeft(2, '0')} ${months[selectedDate.month - 1]} ${selectedDate.year}",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const Spacer(),
                            const Text("Change", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
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
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;

                    final loc = locationCtrl.text.trim().isEmpty ? "All Blocks" : locationCtrl.text.trim();
                    final time = timeCtrl.text.trim().isEmpty ? "10:00 AM" : timeCtrl.text.trim();

                    setState(() {
                      _events.add(
                        HostelEventItem(
                          day: selectedDate.day.toString().padLeft(2, '0'),
                          month: months[selectedDate.month - 1],
                          title: title,
                          subtitle: "$loc · $time",
                          description: "Scheduled event for hostel community.",
                        ),
                      );
                    });
                    Navigator.of(dialogCtx).pop();
                    showAppSnackBar(context, "Event '$title' added to hostel calendar.");
                  },
                  child: const Text("Save Event"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventDetail(BuildContext context, HostelEventItem e) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.day, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1)),
                    Text(e.month, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(e.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Description / Protocol:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(e.description, style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text("Coordinator: ${e.coordinator}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader(title: "Upcoming Hostel Events")),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showAddEventDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Add Event", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._events.map(
            (e) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => _showEventDetail(context, e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.day,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1),
                            ),
                            Text(
                              e.month,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(e.subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
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
