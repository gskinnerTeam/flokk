import 'package:flutter/material.dart';

class BuildUtils {

  static void getFutureSizeFromGlobalKey(GlobalKey key, Function(Size size) callback) {
    Future.microtask(() {
      BuildContext? ctx = key.currentContext;
      if (ctx != null) {
        Size? size = getSizeFromContext(ctx);
        if (size != null)
          callback(size);
      }
    });
  }

  static Size? getSizeFromContext(BuildContext context) {
    RenderBox? rb = context.findRenderObject() as RenderBox?;
    return rb?.size;
  }

  static Offset? getOffsetFromContext(BuildContext context, [Offset offset = Offset.zero]) {
    RenderBox? rb = context.findRenderObject() as RenderBox?;
    return rb?.localToGlobal(offset);
  }


}
