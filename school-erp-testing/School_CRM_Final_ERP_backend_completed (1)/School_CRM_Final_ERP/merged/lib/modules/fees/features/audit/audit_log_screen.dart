import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/theme/app_colors.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditLogProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Log', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Every collection, cancellation, and administrative action is tracked here.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fact_check_outlined, size: 42, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('No activity yet — actions you perform will appear here.', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : Material(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                      itemBuilder: (context, i) {
                        final l = logs[i];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.14), child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 18)),
                          title: Text('${l.action} — ${l.detail}'),
                          subtitle: Text('${l.user} · IP ${l.ip}'),
                          trailing: Text(Fmt.dateTime(l.timestamp), style: theme.textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
