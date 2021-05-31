import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LightDarkToggleSwitch extends StatefulWidget {
  @override
  _LightDarkToggleSwitchState createState() => _LightDarkToggleSwitchState();
}

class _LightDarkToggleSwitchState extends State<LightDarkToggleSwitch> {
  int lastSwitchTime = 0;

  void _handleTogglePressed(BuildContext context) {
    if (DateTime.now().millisecondsSinceEpoch - lastSwitchTime < Durations.medium.inMilliseconds) {
      return;
    }
    lastSwitchTime = DateTime.now().millisecondsSinceEpoch;
    context.read<AppModel>().nextTheme();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double iconSize = 18;
    double innerWidth = 54;
    // Use a stateful builder so we can rebuild ourselves on click without going to a StatefulWidget
    return Row(
      children: [
        StyledImageIcon(StyledIcons.lightMode, size: iconSize, color: Colors.white),
        HSpace(Insets.sm),
        Stack(children: [
          StyledContainer(
            theme.accent1Darker,
            borderRadius: BorderRadius.circular(19),
            width: innerWidth,
            height: 24,
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: theme.isDark ? 1 : 0),
            duration: Durations.fastest,
            builder: (_, value, __) => StyledContainer(
              theme.surface,
              duration: Durations.medium,
              margin: EdgeInsets.only(
                  top: 2, left: 2 + (innerWidth - 20 - 4) * (value as double? ?? 1), right: 2),
              borderRadius: BorderRadius.circular(99),
              width: 20,
              height: 20,
            ),
          ),
        ]),
        HSpace(Insets.sm),
        StyledImageIcon(StyledIcons.darkMode, size: iconSize - 2, color: ColorUtils.shiftHsl(theme.accent1, -.1)),
      ],
    ).clickable(() => _handleTogglePressed(context), opaque: true);
  }
}

class _AnimatedMenuIndicator extends StatefulWidget {
  final double indicatorY;
  final double width;
  final double height;

  _AnimatedMenuIndicator(this.indicatorY, {this.width = 6, this.height = 24});

  @override
  _AnimatedMenuIndicatorState createState() => _AnimatedMenuIndicatorState();
}

class _AnimatedMenuIndicatorState extends State<_AnimatedMenuIndicator> {
  final double _duration = .5;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return AnimatedContainer(
        duration: _duration.seconds,
        curve: Curves.easeOutBack,
        width: widget.width,
        height: widget.height,
        child: Container(color: theme.surface),
        margin: EdgeInsets.only(top: widget.indicatorY));
  }
}
