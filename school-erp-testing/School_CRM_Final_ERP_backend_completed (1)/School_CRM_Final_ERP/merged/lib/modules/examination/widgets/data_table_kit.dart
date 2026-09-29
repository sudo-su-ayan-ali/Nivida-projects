import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class AppColumn<T> {
  final String label;
  final Widget Function(T row) cellBuilder;
  final double width;
  AppColumn({required this.label, required this.cellBuilder, this.width = 160});
}

/// A lightweight, real (non-decorative) data table: search box, column
/// headers, and rows built from live data. Used across every module list
/// screen so behaviour (search/sort/empty-state) is consistent.
class AppDataTable<T> extends StatefulWidget {
  final List<T> rows;
  final List<AppColumn<T>> columns;
  final bool Function(T row, String query)? searchMatcher;
  final String searchHint;
  const AppDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.searchMatcher,
    this.searchHint = 'Search...',
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty || widget.searchMatcher == null
        ? widget.rows
        : widget.rows.where((r) => widget.searchMatcher!(r, query.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.searchMatcher != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(isDense: true, hintText: widget.searchHint, prefixIcon: const Icon(Icons.search, size: 18)),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
          ),
        if (filtered.isEmpty)
          const EmptyState(message: 'No records match your search/filter.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bg),
              columns: widget.columns.map((c) => DataColumn(label: SizedBox(width: c.width, child: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))))).toList(),
              rows: filtered
                  .map((r) => DataRow(cells: widget.columns.map((c) => DataCell(SizedBox(width: c.width, child: c.cellBuilder(r)))).toList()))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const FilterDropdown({super.key, required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(isDense: true, labelText: label),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => onChanged(v ?? value),
      ),
    );
  }
}
