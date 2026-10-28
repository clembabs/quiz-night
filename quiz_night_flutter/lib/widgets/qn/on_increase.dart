import 'package:flutter/widgets.dart';

/// Calls [onIncrease] each time [value] goes up between builds (a lockout,
/// a name dropping), for a sound or a buzz. Not on the first build.
class OnIncrease extends StatefulWidget {
  final int value;
  final VoidCallback onIncrease;
  final Widget child;

  const OnIncrease({
    super.key,
    required this.value,
    required this.onIncrease,
    required this.child,
  });

  @override
  State<OnIncrease> createState() => _OnIncreaseState();
}

class _OnIncreaseState extends State<OnIncrease> {
  @override
  void didUpdateWidget(OnIncrease old) {
    super.didUpdateWidget(old);
    if (widget.value > old.value) widget.onIncrease();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
