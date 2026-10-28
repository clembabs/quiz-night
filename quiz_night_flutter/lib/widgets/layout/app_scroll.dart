import 'package:flutter/material.dart';

/// How every list and page in the app scrolls.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  /// Android's stretch redraws the whole page each frame, which stutters in
  /// a phone browser; the glow costs nothing. iPhones keep their bounce.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => switch (getPlatform(context)) {
    TargetPlatform.android => GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.secondary,
      child: child,
    ),
    _ => super.buildOverscrollIndicator(context, child, details),
  };
}

/// A scrolling page or panel. With [fillViewport], [child] is at least as
/// tall as the space, so a short page can push its footer to the bottom.
class AppScroll extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool fillViewport;

  const AppScroll({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.fillViewport = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget view(Widget content) => SingleChildScrollView(
      controller: controller,
      padding: padding,
      // Dragging the page puts the keyboard away, as browsers do.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: content,
    );
    if (!fillViewport) return view(child);
    return LayoutBuilder(
      builder: (context, box) {
        final inset = padding?.resolve(Directionality.of(context)).vertical;
        return view(
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (box.maxHeight - (inset ?? 0)).clamp(0, box.maxHeight),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
