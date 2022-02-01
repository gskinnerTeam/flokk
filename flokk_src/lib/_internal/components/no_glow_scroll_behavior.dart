import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
