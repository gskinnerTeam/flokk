import 'package:flutter/material.dart';

class TranslateAndAlign extends StatelessWidget {
  final Offset offset;
  final Alignment align;
  final Widget? child;

  const TranslateAndAlign({this.child, this.offset = Offset.zero, this.align = Alignment.topLeft, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Transform.translate(
        offset: offset,
        child: child,
      ),
    );
  }
}
