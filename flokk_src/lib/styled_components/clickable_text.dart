import 'package:flokk/app_extensions.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClickableText extends StatelessWidget {
  final void Function(String)? onPressed;
  final String text;
  final TextStyle? style;
  final Color? linkColor;
  final bool underline;

  const ClickableText(this.text, {Key? key, this.onPressed, this.style, this.underline = false, this.linkColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    final ts = (style ?? TextStyles.Body1.textHeight(1.5));
    Widget t = Text(
      text,
      style: style ?? (underline ? ts.underline : ts),
      overflow: TextOverflow.clip,
    );
    if (onPressed != null) {
      /// Add tap handlers and style text
      t = (t as Text).textColor(linkColor ?? theme.accent1).clickable(
            () => onPressed?.call(text),
          );
    }
    return t.translate(offset: Offset(0, 0));
  }
}
