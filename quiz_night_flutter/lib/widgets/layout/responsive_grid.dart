import 'package:flutter/widgets.dart';

/// Fits as many [minItemWidth] columns as allowed, like CSS auto-fit.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double gap;

  /// Cells in a row share the tallest one's height.
  final bool equalHeights;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    this.gap = 14,
    this.equalHeights = true,
  });

  /// Columns that fit in [width]; never more than there are children.
  static int columnsFor(double width, double minItemWidth, double gap, int n) {
    if (n == 0) return 1;
    final cols = ((width + gap) / (minItemWidth + gap)).floor();
    return cols.clamp(1, n);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = columnsFor(c.maxWidth, minItemWidth, gap, children.length);
      final rows = <Widget>[];
      for (var start = 0; start < children.length; start += cols) {
        if (start > 0) rows.add(SizedBox(height: gap));
        // One column: no row to share, and stretching would need a height.
        if (cols == 1) {
          rows.add(children[start]);
          continue;
        }
        final row = Row(
          crossAxisAlignment: equalHeights
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cols; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(
                child: start + i < children.length
                    ? children[start + i]
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        );
        rows.add(equalHeights ? IntrinsicHeight(child: row) : row);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );
}
