import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'buttons/base_styled_button.dart';

class StyledLabelPill extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? color;
  final double borderRadius;
  final VoidCallback? onPressed;

  const StyledLabelPill(this.text,
      {Key? key,
      this.textStyle,
      this.color,
      this.borderRadius = Corners.s5,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    String t = (text.length > 30) ? text.substring(0, 30) : text;
    return BaseStyledBtn(
      contentPadding:
          EdgeInsets.symmetric(horizontal: Insets.m, vertical: Insets.sm),
      onPressed: onPressed,
      bgColor: color ?? ColorUtils.blend(theme.surface, theme.bg2, .35),
      hoverColor: color ?? ColorUtils.blend(theme.surface, theme.bg2, .35),
      borderRadius: borderRadius,
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          child: OneLineText(t, style: textStyle ?? TextStyles.Btn),
        ),
      ),
    );
  }
}

class ContactLabelPill extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback? onPressed;

  const ContactLabelPill(this.text, {Key? key, this.color, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    String t = (text.length > 30) ? text.substring(0, 30) : text;
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding:
              EdgeInsets.symmetric(horizontal: Insets.m, vertical: Insets.sm),
          decoration: BoxDecoration(
            color: color ?? theme.bg2.withOpacity(.35),
            borderRadius: Corners.s5Border,
          ),
          child: OneLineText(t, style: TextStyles.Footnote),
        ),
      ),
    );
  }
}
