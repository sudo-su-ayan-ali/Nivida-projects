import "package:flutter/material.dart";
import "app_card.dart";

/// Wrapper that gives any chart widget a consistent card + header treatment.
class ChartCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  const ChartCard({super.key, required this.title, this.actionLabel, this.onAction, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title, actionLabel: actionLabel, onAction: onAction),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
