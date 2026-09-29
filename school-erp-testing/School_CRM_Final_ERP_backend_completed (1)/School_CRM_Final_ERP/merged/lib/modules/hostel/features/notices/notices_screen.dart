import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final notices = ref.watch(noticesProvider).value ?? [];
    final df = DateFormat('d MMM yyyy');
    final columns = Responsive.gridColumns(context, max: 3);

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBreadcrumb(items: const ['Notice Management']),
                  const SizedBox(height: 10),
                  Text('Notice Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Publish and manage hostel-wide announcements.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(
                label: 'Create Notice',
                icon: Icons.add_rounded,
                onPressed: () => showAppDialog(
                  context,
                  title: 'Create Notice',
                  content: _CreateNoticeForm(outerContext: context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notices.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, i) {
              final n = notices[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Text(n.category, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                      const Spacer(),
                      StatusBadge(status: n.status),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    Text(n.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(n.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                    const Divider(color: AppColors.divider),
                    Row(children: [
                      Icon(Icons.groups_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(child: Text(n.audience, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                      Text(df.format(n.publishDate), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _CreateNoticeForm extends StatefulWidget {
  final BuildContext outerContext;
  const _CreateNoticeForm({required this.outerContext});
  @override
  State<_CreateNoticeForm> createState() => _CreateNoticeFormState();
}

class _CreateNoticeFormState extends State<_CreateNoticeForm> {
  final title = TextEditingController();
  final desc = TextEditingController();
  String audience = 'All Students';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(controller: title, decoration: const InputDecoration(hintText: 'Notice title')),
        const SizedBox(height: 14),
        const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(hintText: 'Notice details')),
        const SizedBox(height: 14),
        const Text('Audience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: audience,
          items: const ['All Students', 'Specific Block', 'Specific Room', 'Staff'].map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setState(() => audience = v!),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 8),
            PrimaryButton(
              label: 'Publish Notice',
              onPressed: () {
                Navigator.pop(context);
                showAppSnackBar(widget.outerContext, 'Notice "${title.text}" published.');
              },
            ),
          ],
        ),
      ],
    );
  }
}
