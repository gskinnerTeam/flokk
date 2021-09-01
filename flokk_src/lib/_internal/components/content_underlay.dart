import 'package:flutter/material.dart';

class ContentUnderlay extends StatelessWidget {
  final Color color;
  final bool isActive;
  final Duration duration;

  const ContentUnderlay(
      {Key? key,
      this.color = Colors.black87,
      this.isActive = true,
      this.duration = const Duration(milliseconds: 350)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: isActive ? 1 : 0, end: isActive ? 1 : 0),
      duration: duration,
      builder: (_, double opacity, __) {
        return opacity == 0
            // Don't return anything if we're totally invisible
            ? SizedBox.shrink()
            // Use a RawMaterialButton to stop hover events to passing to buttons below
            : RawMaterialButton(
                padding: EdgeInsets.zero,
                onPressed: null,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    color: color,
                  ),
                ),
              );
      },
    );
  }
}
