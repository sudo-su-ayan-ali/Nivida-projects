import 'package:flutter/material.dart';

/// A grid that adapts its column count to the available width instead of
/// forcing a fixed number of columns (which is what caused cards to
/// overflow horizontally). Cards simply drop to the next row once they no
/// longer fit — exactly like a responsive CSS grid.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final int maxColumns;
  final bool equalizeRowHeight;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 320,
    this.spacing = 18,
    this.runSpacing = 18,
    this.maxColumns = 4,
    this.equalizeRowHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = ((width + spacing) / (minItemWidth + spacing)).floor();
        columns = columns.clamp(1, maxColumns).toInt();
        final itemWidth = (width - spacing * (columns - 1)) / columns;

        if (!equalizeRowHeight) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: [
              for (final child in children) SizedBox(width: itemWidth, child: child),
            ],
          );
        }

        // Group children into rows of `columns` items, then stretch every
        // card in that row to match the tallest card in the same row.
        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columns) {
          final end = (i + columns > children.length) ? children.length : i + columns;
          rows.add(children.sublist(i, end));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int r = 0; r < rows.length; r++) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int c = 0; c < rows[r].length; c++) ...[
                      SizedBox(width: itemWidth, child: rows[r][c]),
                      if (c != rows[r].length - 1) SizedBox(width: spacing),
                    ],
                  ],
                ),
              ),
              if (r != rows.length - 1) SizedBox(height: runSpacing),
            ],
          ],
        );
      },
    );
  }
}