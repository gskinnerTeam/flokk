import 'package:flutter/material.dart';

class TranslateAndAlign extends StatelessWidget {
  final Offset offset;
  final Alignment align;
  final Widget child;

  TranslateAndAlign({this.child, this.offset, this.align});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align ?? Alignment.topLeft,
      child: Transform.translate(
        offset: offset ?? Offset.zero,
        child: child,
      ),
    );
  }
}
