import 'package:flokk/styled_components/scrolling/styled_scrollview.dart';
import 'package:flutter/material.dart';

class ConstrainedFlexView extends StatelessWidget {
  final Widget child;
  final double minSize;
  final Axis axis;
  final EdgeInsets scrollPadding;

  const ConstrainedFlexView(this.minSize,
      {Key? key,
      required this.child,
      this.axis = Axis.vertical,
      this.scrollPadding = const EdgeInsets.all(0)})
      : super(key: key);

  bool get isHz => axis == Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        double viewSize = isHz ? constraints.maxWidth : constraints.maxHeight;
        if (viewSize > minSize) return child;
        return Padding(
          padding: scrollPadding,
          child: StyledScrollView(
            axis: axis,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: isHz ? double.infinity : minSize,
                  maxWidth: isHz ? minSize : double.infinity),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
