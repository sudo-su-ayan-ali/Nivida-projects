import 'package:flutter/material.dart';
import '../theme.dart';

/// A card container matching the app's card design tokens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Top summary stat card used on the dashboard.
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? trend;
  final bool trendUp;
  final String actionLabel;
  final VoidCallback onAction;

  const StatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.actionLabel,
    required this.onAction,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: trendUp ? AppColors.success : AppColors.danger),
                const SizedBox(width: 2),
                Text(trend!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendUp ? AppColors.success : AppColors.danger)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          InkWell(
            onTap: onAction,
            child: Text(actionLabel,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

/// A card that wraps a chart/section with a title and a "View" action.
class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: title,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      if (subtitle != null)
                        TextSpan(
                            text: '  $subtitle',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              if (actionLabel != null)
                InkWell(
                  onTap: onAction,
                  child: Text(actionLabel!,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Colored status/badge chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.forStatus(String status) {
    final s = status.toLowerCase();
    Color c;
    if (['approved', 'active', 'present', 'paid', 'completed', 'open', 'processed']
        .contains(s)) {
      c = AppColors.success;
    } else if (['pending', 'draft', 'scheduled', 'in review', 'applied']
        .contains(s)) {
      c = AppColors.warning;
    } else if (['rejected', 'inactive', 'absent', 'closed', 'cancelled']
        .contains(s)) {
      c = AppColors.danger;
    } else if (['on leave', 'half day', 'late', 'shortlisted'].contains(s)) {
      c = AppColors.purple;
    } else {
      c = AppColors.primary;
    }
    return StatusBadge(label: status, color: c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Page header with title, subtitle and trailing action button(s).
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const PageHeader(
      {super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        Wrap(spacing: 10, runSpacing: 10, children: actions),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const PrimaryButton(
      {super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.add, size: 18),
      label: Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const SecondaryButton(
      {super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.download, size: 18),
      label: Text(label),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState(
      {super.key, this.message = 'No records found', this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
        ],
      ),
    );
  }
}

/// Standard confirmation dialog for delete / process actions.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: danger ? AppColors.danger : AppColors.primary),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showAppToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? AppColors.danger : AppColors.textPrimary,
    ),
  );
}

/// Reusable search text field.
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
        ),
      ),
    );
  }
}

/// Reusable dropdown filter.
class FilterDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  const FilterDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: value,
        hint: Text(hint, style: const TextStyle(fontSize: 13.5)),
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(labelBuilder(e),
                    style: const TextStyle(fontSize: 13.5),
                    overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// Small circular avatar with initials.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  const InitialsAvatar({super.key, required this.name, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = (parts.isNotEmpty ? parts[0][0] : '') +
        (parts.length > 1 ? parts[1][0] : '');
    final colors = [
      AppColors.primary,
      AppColors.purple,
      AppColors.teal,
      AppColors.warning,
    ];
    final color = colors[name.hashCode.abs() % colors.length];
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withOpacity(0.15),
      child: Text(initials.toUpperCase(),
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: size * 0.36)),
    );
  }
}

/// Section header used for module group blocks (Employee Management, etc).
class ModuleGroupHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  const ModuleGroupHeader(
      {super.key, required this.icon, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

/// Clickable module tile used inside module group sections.
class ModuleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const ModuleTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

/// Simple horizontal progress bar (used for department headcount).
class LabeledProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  const LabeledProgressBar(
      {super.key,
      required this.label,
      required this.value,
      required this.max,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = max == 0 ? 0.0 : value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('$value (${(pct * 100).toStringAsFixed(2)}%)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.pageBg,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
