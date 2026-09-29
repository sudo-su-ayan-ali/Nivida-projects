import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class FilterBarState {
  DateTime date;
  String selectedClass;
  String selectedSection;
  FilterBarState({required this.date, this.selectedClass = 'All Classes', this.selectedSection = 'All Sections'});
}

class FilterBar extends StatefulWidget {
  final FilterBarState state;
  final ValueChanged<FilterBarState> onChanged;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final List<String> classOptions;
  final List<String> sectionOptions;

  const FilterBar({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onRefresh,
    this.isRefreshing = false,
    this.classOptions = const [],
    this.sectionOptions = const [],
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.state.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      widget.state.date = picked;
      widget.onChanged(widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, yyyy').format(widget.state.date);

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 720;
      final children = <Widget>[
        _FilterControl(
          icon: Icons.calendar_today_outlined,
          label: dateLabel,
          onTap: _pickDate,
        ),
        _DropdownControl(
          icon: Icons.grid_view_rounded,
          value: widget.state.selectedClass,
          options: ['All Classes', ...widget.classOptions],
          onChanged: (v) {
            widget.state.selectedClass = v;
            widget.onChanged(widget.state);
          },
        ),
        _DropdownControl(
          icon: Icons.dashboard_customize_outlined,
          value: widget.state.selectedSection,
          options: ['All Sections', ...widget.sectionOptions],
          onChanged: (v) {
            widget.state.selectedSection = v;
            widget.onChanged(widget.state);
          },
        ),
      ];

      final refreshBtn = _RefreshButton(onTap: widget.onRefresh, isBusy: widget.isRefreshing);

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(spacing: 12, runSpacing: 12, children: children),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: refreshBtn),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: Wrap(spacing: 12, runSpacing: 12, children: children),
          ),
          const SizedBox(width: 12),
          refreshBtn,
        ],
      );
    });
  }
}

class _FilterControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FilterControl({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: AppText.tableCell),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DropdownControl extends StatelessWidget {
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _DropdownControl({
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
              style: AppText.tableCell,
              borderRadius: BorderRadius.circular(12),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isBusy;
  const _RefreshButton({required this.onTap, required this.isBusy});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton> with SingleTickerProviderStateMixin {
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void didUpdateWidget(covariant _RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBusy && !oldWidget.isBusy) {
      _spin.repeat();
    } else if (!widget.isBusy) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isBusy ? null : widget.onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _spin,
              child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            const Text('Refresh', style: AppText.button),
          ],
        ),
      ),
    );
  }
}