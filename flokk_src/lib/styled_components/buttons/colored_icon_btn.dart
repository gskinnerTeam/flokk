import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ////////////////////////////////////////////////////
/// Transparent icon button that changes it's btn color on mouse-over
/// ////////////////////////////////////////////////////
class ColorShiftIconBtn extends StatelessWidget {
  final VoidCallback? onPressed;

  final AssetImage icon;
  final double size;
  final Color? color;
  final Color ?bgColor;
  final EdgeInsets padding;
  final double? minWidth;
  final double? minHeight;
  final void Function(bool)? onFocusChanged;
  final bool shrinkWrap;

  const ColorShiftIconBtn(
    this.icon, {
    Key? key,
    this.onPressed,
    this.color,
    this.size = 22,
    this.padding = const EdgeInsets.all(Insets.sm),
    this.onFocusChanged,
    this.bgColor,
    this.minWidth,
    this.minHeight,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    bool _mouseOver = false;
    return StatefulBuilder(
      builder: (_, setState) {
        Color iconColor = (color ?? theme.grey);
        if (_mouseOver) {
          iconColor = ColorUtils.shiftHsl(iconColor, theme.isDark ? .2 : -.2);
        }
        return MouseRegion(
          onEnter: (_) => setState(() => _mouseOver = true),
          onExit: (_) => setState(() => _mouseOver = false),
          child: BaseStyledBtn(
              minHeight: minHeight ?? (shrinkWrap ? 0 : 42),
              minWidth: minWidth ?? (shrinkWrap ? 0 : 42),
              bgColor: bgColor ?? Colors.transparent,
              downColor: theme.bg2.withOpacity(.35),
              hoverColor: bgColor ?? Colors.transparent,
              onFocusChanged: onFocusChanged,
              contentPadding: padding,
              child: IgnorePointer(
                child: StyledImageIcon(icon, size: size, color: iconColor),
              ),
              onPressed: onPressed),
        );
      },
    );
  }
}
