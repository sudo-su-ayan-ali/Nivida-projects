import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class AppTableColumn {
  final String label;
  final double? width;
  final bool numeric;
  const AppTableColumn(this.label, {this.width, this.numeric = false});
}

/// A professional ERP-style data table: header row, hover rows, horizontal
/// scroll on overflow (mobile-friendly), and a builder per row for full
/// flexibility (badges, avatars, action menus, etc.)
class AppDataTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final int rowCount;
  final List<Widget> Function(int index) rowBuilder;
  final double minWidth;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.minWidth = 900,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Give the table a concrete (bounded) width: either the space
        // available on screen, or `minWidth` if the screen is narrower —
        // in which case the SingleChildScrollView lets it scroll sideways.
        // Leaving width unbounded (the old `minWidth`-only ConstrainedBox)
        // made every child Row/Expanded try to lay out in infinite width,
        // which is what was throwing "BoxConstraints forces an infinite
        // width" and blanking out the whole page.
        final tableWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableWidth, maxWidth: tableWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: columns
                        .map((c) => Expanded(
                              flex: (c.width ?? 140).round(),
                              child: Text(
                                c.label,
                                textAlign: c.numeric ? TextAlign.right : TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                if (rowCount == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(child: Text('No records found', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  ...List.generate(rowCount, (i) => _AppTableRow(cells: rowBuilder(i), columns: columns)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppTableRow extends StatefulWidget {
  final List<Widget> cells;
  final List<AppTableColumn> columns;
  const _AppTableRow({required this.cells, required this.columns});

  @override
  State<_AppTableRow> createState() => _AppTableRowState();
}

class _AppTableRowState extends State<_AppTableRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: hovering ? AppColors.background : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: List.generate(widget.cells.length, (i) {
            final col = i < widget.columns.length ? widget.columns[i] : const AppTableColumn('');
            return Expanded(
              flex: (col.width ?? 140).round(),
              child: Align(
                alignment: col.numeric ? Alignment.centerRight : Alignment.centerLeft,
                child: widget.cells[i],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Standard cell text style helper
class CellText extends StatelessWidget {
  final String text;
  final bool strong;
  final Color? color;
  const CellText(this.text, {super.key, this.strong = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
        color: color ?? (strong ? AppColors.textPrimary : AppColors.textSecondary),
      ),
    );
  }
}

/// Row action icon buttons (view / edit / delete / more)
class RowActions extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<PopupMenuEntry>? moreItems;

  const RowActions({super.key, this.onView, this.onEdit, this.onDelete, this.moreItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: onView,
            tooltip: 'View',
            splashRadius: 18,
          ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: onEdit,
            tooltip: 'Edit',
            splashRadius: 18,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
            onPressed: onDelete,
            tooltip: 'Delete',
            splashRadius: 18,
          ),
        if (moreItems != null)
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
            itemBuilder: (_) => moreItems!.cast(),
          ),
      ],
    );
  }
}
