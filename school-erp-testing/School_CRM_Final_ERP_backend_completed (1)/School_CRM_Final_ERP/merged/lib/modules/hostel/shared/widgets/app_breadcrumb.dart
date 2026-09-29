import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../../core/theme/app_colors.dart";

/// Breadcrumb trail. Always starts with a clickable Home icon that takes
/// you back to the Dashboard — this is the only way back since there's
/// no sidebar or top bar on inner pages.
class AppBreadcrumb extends StatelessWidget {
  final List<String> items;
  const AppBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => context.go('/dashboard'),
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Icon(Icons.home_rounded, size: 16, color: AppColors.primary),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
        ),
        ...List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
            );
          }
          final idx = i ~/ 2;
          final isLast = idx == items.length - 1;
          return Text(
            items[idx],
            style: TextStyle(
              fontSize: 13,
              color: isLast ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        }),
      ],
    );
  }
}
