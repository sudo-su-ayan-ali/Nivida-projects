import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class ParentCommLog {
  final String title;
  final String audience;
  final Color color;
  final IconData icon;
  final String channel;
  final String timestamp;
  final String content;

  const ParentCommLog({
    required this.title,
    required this.audience,
    required this.color,
    required this.icon,
    required this.channel,
    required this.timestamp,
    required this.content,
  });
}

class ParentCommunicationCard extends ConsumerStatefulWidget {
  const ParentCommunicationCard({super.key});

  @override
  ConsumerState<ParentCommunicationCard> createState() => _ParentCommunicationCardState();
}

class _ParentCommunicationCardState extends ConsumerState<ParentCommunicationCard> {
  final List<ParentCommLog> _logs = [
    const ParentCommLog(
      title: "Fee reminder sent",
      audience: "156 guardians · SMS + Email",
      color: AppColors.info,
      icon: Icons.mail_rounded,
      channel: "SMS & Email",
      timestamp: "Today, 11:30 AM",
      content:
          "Dear Parents, Monthly hostel mess and accommodation fees for the upcoming month are due by 5th. Kindly pay online or at the accounts desk.",
    ),
    const ParentCommLog(
      title: "Leave approved notice",
      audience: "Rohan Kumar's guardian · SMS",
      color: AppColors.success,
      icon: Icons.check_circle_rounded,
      channel: "SMS",
      timestamp: "Yesterday, 04:15 PM",
      content:
          "Dear Guardian, Weekend leave for Rohan Kumar (Room B-205) from Friday 6 PM to Sunday 8 PM has been authorized by the Chief Warden.",
    ),
    const ParentCommLog(
      title: "Health advisory sent",
      audience: "All guardians · Email",
      color: AppColors.warning,
      icon: Icons.health_and_safety_rounded,
      channel: "Email",
      timestamp: "2 days ago",
      content:
          "Advisory regarding seasonal flu precautions in the hostel premises. The medical center is conducting complimentary health checks.",
    ),
  ];

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String channel = "SMS + Email";
    String target = "All Guardians";

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              title: const Row(
                children: [
                  Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text("Send Alert to Parents", style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: target,
                            decoration: InputDecoration(
                              labelText: "Target Audience",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            items: const [
                              DropdownMenuItem(value: "All Guardians", child: Text("All Guardians (340)")),
                              DropdownMenuItem(value: "Hostel Block A Parents", child: Text("Block A Parents")),
                              DropdownMenuItem(value: "Hostel Block B Parents", child: Text("Block B Parents")),
                              DropdownMenuItem(value: "Hostel Block C Parents", child: Text("Block C Parents")),
                            ],
                            onChanged: (val) {
                              if (val != null) setDlgState(() => target = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: channel,
                            decoration: InputDecoration(
                              labelText: "Delivery Channel",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            items: const [
                              DropdownMenuItem(value: "SMS + Email", child: Text("SMS + Email")),
                              DropdownMenuItem(value: "SMS Only", child: Text("SMS Only")),
                              DropdownMenuItem(value: "Email Only", child: Text("Email Only")),
                            ],
                            onChanged: (val) {
                              if (val != null) setDlgState(() => channel = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: "Message Subject / Title",
                        hintText: "e.g., Extended Curfew Notice / Meeting",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Message Content",
                        hintText: "Enter the notification message to parents...",
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
                    final title = titleCtrl.text.trim();
                    final msg = messageCtrl.text.trim();
                    if (title.isEmpty || msg.isEmpty) return;

                    setState(() {
                      _logs.insert(
                        0,
                        ParentCommLog(
                          title: title,
                          audience: "$target · $channel",
                          color: AppColors.primary,
                          icon: Icons.campaign_rounded,
                          channel: channel,
                          timestamp: "Just now",
                          content: msg,
                        ),
                      );
                    });
                    Navigator.of(dialogCtx).pop();
                    showAppSnackBar(context, "Parent broadcast dispatched via $channel.");
                  },
                  child: const Text("Broadcast"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogDetail(BuildContext context, ParentCommLog log) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Row(
            children: [
              Icon(log.icon, color: log.color, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(log.title, style: const TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.audience, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 4),
              Text("Sent: ${log.timestamp} via ${log.channel}", style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              const Divider(height: 20),
              const Text("Broadcast Message Body:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(log.content, style: const TextStyle(fontSize: 13, height: 1.4)),
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
              const Expanded(child: SectionHeader(title: "Parent / Guardian Communication")),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showBroadcastDialog(context),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text("Broadcast", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._logs.map(
            (l) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => _showLogDetail(context, l),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: l.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(l.icon, size: 17, color: l.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(l.audience, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
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
