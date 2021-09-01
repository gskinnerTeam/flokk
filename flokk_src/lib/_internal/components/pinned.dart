import 'dart:math';

import 'package:flutter/material.dart';

import 'pinned_stack.dart';

class Pin {
  final double? startPx;
  final double? startPct;
  final double? endPx;
  final double? endPct;
  final double? sizePx;
  final double? centerPct;

  const Pin(
      {this.startPx,
      this.startPct,
      this.endPx,
      this.endPct,
      this.sizePx,
      this.centerPct});
}

class Pinned extends StatelessWidget {
  final Pin hzPin;
  final Pin vtPin;
  final Widget? child;

  const Pinned({Key? key, required this.hzPin, required this.vtPin, this.child})
      : super(key: key);

  _Span calculateSpanFromPin(Pin pin, double maxSize) {
    var s = _Span();

    double start = pin.startPx ?? (pin.startPct ?? 0) * maxSize;
    double end = pin.endPx ?? (pin.endPct ?? 0) * maxSize;
    double size = pin.sizePx ?? 0;
    double centerPct = pin.centerPct ?? .5;

    //Size is unknown, so we must be pinned on both sides
    if (pin.sizePx == null) {
      s.start = start;
      s.end = maxSize - end;
    }
    //We know the size, figure out which side we're pinned on, if any
    else {
      //Pinned to start
      if (pin.startPx != null || pin.startPct != null) {
        s.start = start;
        s.end = s.start + size;
      }
      //Pinned to end
      else if (pin.endPx != null || pin.endPct != null) {
        s.end = maxSize - end;
        s.start = s.end - size;
      }
      //Both sides are % pinned, use center - size/2 to position
      else {
        s.start = (centerPct * maxSize) - size * .5;
        s.end = s.start + size;
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    //Check to see if we have been provided some StackConstraints by [ PinnedStack ]
    StackConstraints? constraints =
        context.dependOnInheritedWidgetOfExactType<StackConstraints>();
    if (constraints != null) {
      return _buildContent(constraints.constraints);
    }
    //If not, we need to find our own constraints
    else {
      return LayoutBuilder(
        builder: (context, constraints) => _buildContent(constraints),
      );
    }
  }

  Widget _buildContent(BoxConstraints constraints) {
    _Span hzSpan = calculateSpanFromPin(hzPin, constraints.maxWidth);
    _Span vtSpan = calculateSpanFromPin(vtPin, constraints.maxHeight);
    //Hide child if either dimension is 0
    bool showChild = (hzSpan.size > 0 && vtSpan.size > 0);
    return Transform.translate(
      offset: Offset(hzSpan.start, vtSpan.start),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
            width: hzSpan.size,
            height: vtSpan.size,
            child: showChild ? child : null),
      ),
    );
  }
}

class _Span {
  double start = 0;
  double end = 0;

  double get size => max(0, end - start);
}

extension PinnedExtensions on Widget {
  Pinned pin({required Pin hz, required Pin vt}) =>
      Pinned(hzPin: hz, vtPin: vt, child: this);
}
