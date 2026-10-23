import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../data/providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/app_avatar.dart';

/// Extra #5: Student ID / Hostel Card generator preview — schools regularly
/// need to (re)issue physical/digital hostel ID cards; a quick preview +
/// bulk-generate action saves a genuinely common manual task.
class IdCardGeneratorCard extends ConsumerWidget {
  const IdCardGeneratorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final students = ref.watch(studentsProvider).value ?? [];
final sample = students.isNotEmpty ? students.first : null;
    final isMobile = Responsive.isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Hostel ID Card Generator'),
          const SizedBox(height: 16),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              if (sample != null) _idCardPreview(sample.name, sample.photoInitials, sample.room, sample.block, sample.id),
              SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 20 : 0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate print-ready or digital hostel ID cards for individual students or the entire block — includes photo, room, block, and QR check-in code.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PrimaryButton(
                          label: 'Generate for This Student',
                          icon: Icons.badge_rounded,
                          onPressed: () {
                            if (sample != null) {
                              showAppSnackBar(context, 'Hostel ID card generated for ${sample.name}.');
                            } else {
                              showAppSnackBar(context, 'No student selected for ID card.', isError: true);
                            }
                          },
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (sample != null) {
                              showAppSnackBar(context, 'Bulk ID card generation initiated for ${sample.block}.');
                            } else {
                              showAppSnackBar(context, 'No blocks available for bulk generation.', isError: true);
                            }
                          },
                          icon: const Icon(Icons.groups_rounded, size: 18),
                          label: const Text('Bulk Generate for Block'),
                        ),
                      ],
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

  Widget _idCardPreview(String name, String initials, String room, String block, String id) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.home_rounded, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('HostelHub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              AppAvatar(initials: initials, size: 48, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(id, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BLOCK', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w700)),
                    Text(block.split(' ').take(2).join(' '), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ROOM', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w700)),
                  Text(room, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.qr_code_rounded, size: 20, color: AppColors.navy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
