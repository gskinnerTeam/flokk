import 'package:flutter/material.dart';

class StackConstraints extends InheritedWidget {
  final BoxConstraints constraints;

  StackConstraints({this.constraints, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    var old = (oldWidget as StackConstraints).constraints;
    return old.maxWidth != constraints.maxWidth || old.maxHeight != constraints.maxHeight;
  }
}

class PinnedStack extends StatelessWidget {
  final List<Widget> children;
  final StackFit fit;
  final AlignmentGeometry alignment;
  final TextDirection textDirection;
  final Overflow overflow;

  const PinnedStack(
      {Key key,
      this.children,
      this.fit = StackFit.expand,
      this.alignment = Alignment.topLeft,
      this.textDirection = TextDirection.ltr,
      this.overflow = Overflow.visible})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return StackConstraints(
        constraints: constraints,
        child: Stack(
          fit: fit,
          alignment: alignment,
          overflow: overflow,
          textDirection: textDirection,
          children: children,
        ),
      );
    });
  }
}
