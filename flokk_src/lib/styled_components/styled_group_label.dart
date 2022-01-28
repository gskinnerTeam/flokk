import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StyledGroupLabel extends StatelessWidget {
  final AssetImage? icon;
  final String text;
  final void Function(bool)? onFocusChanged;
  final VoidCallback? onClose;
  final VoidCallback? onPressed;

  StyledGroupLabel({this.icon, this.text = "", this.onFocusChanged, this.onClose, this.onPressed});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...{
          StyledImageIcon(
            icon!,
            size: 12,
            color: theme.surface,
          ).center().constrained(width: 30, height: 30).decorated(
                borderRadius: Corners.s5Border,
                color: theme.accent1Darker,
              ),
        },
        Text(text.toUpperCase(), style: TextStyles.Footnote.letterSpace(0).textColor(theme.grey))
            .padding(left: Insets.m),
        if (onClose != null) ...{
          ColorShiftIconBtn(
            StyledIcons.closeLarge,
            minWidth: 0,
            minHeight: 0,
           // 8 padding on either side + 8 icon size = design dimensions, minWidth doesn't seem to work for this so I'm using padding instead
            padding: EdgeInsets.all(8),
            size: 8,
            color: theme.grey,
            bgColor: ColorUtils.blend(theme.surface, theme.bg2, .35),
            onFocusChanged: onFocusChanged,
            onPressed: onClose,
          ),
        } else ... {
          HSpace(Insets.m),
        },
      ],
    );
    return onPressed != null
        ? BaseStyledBtn(
            minWidth: 1,
            minHeight: 1,
            bgColor: ColorUtils.blend(theme.surface, theme.bg2, .35),
            onPressed: onPressed,
            onFocusChanged: onFocusChanged,
            borderRadius: Corners.s5,
            contentPadding: EdgeInsets.all(Insets.sm),
            child: content,
          )
        : Container(
            height: 30,
            decoration: BoxDecoration(borderRadius: Corners.s5Border, color: theme.bg2.withOpacity(.35)),
            child: content,
          );
  }
}
