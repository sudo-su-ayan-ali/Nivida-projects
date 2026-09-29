import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TableColumnDef {
  final String label;
  final int flex;
  final TextAlign align;
  const TableColumnDef({required this.label, this.flex = 1, this.align = TextAlign.left});
}

class DataTableCard extends StatelessWidget {
  final List<TableColumnDef> columns;
  final List<List<Widget>> rows;
  final double minWidth;

  const DataTableCard({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final tableWidth = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            children: [
              _HeaderRow(columns: columns),
                        for (int i = 0; i < rows.length; i++)
                _BodyRow(cells: rows[i], columns: columns, isLast: i == rows.length - 1, index: i),
            ],
          ),
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final List<TableColumnDef> columns;
  const _HeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft, width: 1.4)),
      ),
      child: Row(
        children: [
          for (final col in columns)
            Expanded(
              flex: col.flex,
              child: Text(
                col.label,
                textAlign: col.align,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.3),
              ),
            ),
        ],
      ),
    );
  }
}

class _BodyRow extends StatelessWidget {
  final List<Widget> cells;
  final List<TableColumnDef> columns;
  final bool isLast;
  final int index;
  const _BodyRow({required this.cells, required this.columns, required this.isLast, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.transparent : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderSoft, width: 1)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: Align(
                alignment: columns[i].align == TextAlign.right ? Alignment.centerRight : Alignment.centerLeft,
                child: cells[i],
              ),
            ),
        ],
      ),
    );
  }
}

class TableCellText extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;
  const TableCellText(this.text, {super.key, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}

class TableCellSubText extends StatelessWidget {
  final String title;
  final String subtitle;
  const TableCellSubText({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
      ],
    );
  }
}

class DriverAvatarCell extends StatelessWidget {
  final String name;
  final Color color;
  const DriverAvatarCell({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(9)),
          child: Text(initials.toUpperCase(), style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
        ),
        const SizedBox(width: 10),
        Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}

class MiniProgressCell extends StatelessWidget {
  final int value;
  final int total;
  const MiniProgressCell({super.key, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;
    final color = ratio >= 0.95 ? AppColors.success : (ratio >= 0.9 ? AppColors.warning : AppColors.danger);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value/$total', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        SizedBox(
          width: 46,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.borderSoft,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}
