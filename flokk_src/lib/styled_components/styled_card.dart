import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A card that defaults to theme.surface1, and has a built in shadow and rounded corners.
class StyledCard extends StatelessWidget {
  final Color? bgColor;
  final bool enableShadow;
  final Widget? child;
  final VoidCallback? onPressed;
  final Alignment? align;

  const StyledCard(
      {Key? key,
      this.bgColor,
      this.enableShadow = true,
      this.child,
      this.onPressed,
      this.align})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    Color c = bgColor ?? theme.surface;

    Widget content = StyledContainer(c,
        align: align,
        child: child,
        borderRadius: Corners.s8Border,
        shadows: enableShadow ? Shadows.m(theme.accent1Darker) : null);

    if (onPressed != null)
      return TransparentBtn(child: content, onPressed: onPressed);
    return content;
  }
}
