import 'package:flutter/material.dart';

/// タップ可能なTooltipウィジェット
/// ホバーでもタップでもTooltipを表示する
class TappableTooltip extends StatefulWidget {
  const TappableTooltip({
    required this.message,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.decoration,
    super.key,
  });

  final String message;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final BoxDecoration? decoration;

  @override
  State<TappableTooltip> createState() => _TappableTooltipState();
}

class _TappableTooltipState extends State<TappableTooltip> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // タップ時にTooltipを表示
        _tooltipKey.currentState?.ensureTooltipVisible();
      },
      child: Tooltip(
        key: _tooltipKey,
        message: widget.message,
        padding: widget.padding,
        textStyle: widget.textStyle,
        decoration:
            widget.decoration ??
            BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
        child: widget.child,
      ),
    );
  }
}
