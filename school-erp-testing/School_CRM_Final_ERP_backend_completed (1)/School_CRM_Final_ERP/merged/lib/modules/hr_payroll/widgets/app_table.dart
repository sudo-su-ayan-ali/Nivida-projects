import 'package:flutter/material.dart';
import '../theme.dart';
import 'common.dart';

/// A styled, horizontally-scrollable data table with consistent look.
/// Falls back to an EmptyState when [rows] is empty.
class AppTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;
  final String emptyMessage;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No records found',
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return EmptyState(message: emptyMessage);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.pageBg),
          headingTextStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary),
          dataTextStyle:
              const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          dividerThickness: 1,
          columnSpacing: 28,
          columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows: rows,
        ),
      ),
    );
  }
}

/// Simple pagination footer.
class TablePagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  const TablePagination(
      {super.key,
      required this.page,
      required this.totalPages,
      required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: page > 0 ? () => onPageChange(page - 1) : null,
          ),
          Text('Page ${page + 1} of $totalPages',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: page < totalPages - 1 ? () => onPageChange(page + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// Row action icon button set (view/edit/delete).
class RowActions extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const RowActions({super.key, this.onView, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          IconButton(
            tooltip: 'View',
            icon: const Icon(Icons.visibility_outlined, size: 18),
            onPressed: onView,
          ),
        if (onEdit != null)
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.primary,
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.danger,
            onPressed: onDelete,
          ),
      ],
    );
  }
}
