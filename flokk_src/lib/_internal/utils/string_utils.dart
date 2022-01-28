import 'package:flutter/material.dart';

class StringUtils {
  static bool isEmpty(String? s) {
    if (s == null) return true;
    return s.trim().isEmpty;
  }

  static bool isNotEmpty(String s) => !isEmpty(s);

  static bool isEmailValid(String value) {
    if (StringUtils.isEmpty(value)) return false;
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
  }

  // Here it is!
  static Size measure(String text, TextStyle style, {int maxLines: 1, TextDirection direction = TextDirection.ltr}) {
    final TextPainter textPainter =
        TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: direction)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static double measureLongest(List<String> items, TextStyle style, [maxItems = null]) {
    double l = 0;
    if (maxItems != null && maxItems < items.length) {
      items.length = maxItems;
    }
    for (var item in items) {
      double m = StringUtils.measure(item, style).width;
      if (m > l) l = m;
    }
    return l;
  }

  /// Gracefully handles null values, and skips the suffix when null
  static String safeGet(String value, [String? suffix]) {
    return value + (!StringUtils.isEmpty(value) ? suffix ?? "" : "");
  }
}
