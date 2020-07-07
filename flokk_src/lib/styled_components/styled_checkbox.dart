import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StyledCheckbox extends StatelessWidget {
  final bool value;
  final double size;
  final Function(bool) onChanged;

  const StyledCheckbox({Key key, this.value, this.size = 18, this.onChanged}) : super(key: key);

  void _handleTapUp(TapUpDetails details) {
    if (value == true) {
      onChanged(false);
    } else if (value == false) {
      onChanged(null);
    } else if (value == null) {
      onChanged(true);
    }
  }

  Widget _getIconForCurrentState() {
    if (value == true) return StyledImageIcon(StyledIcons.checkboxSelected, color: Colors.white, size: 15);
    if (value == null) return StyledImageIcon(StyledIcons.checkboxPartial, color: Colors.white, size: 15);
    return Container();
  }

  Widget _wrapGestures(Widget child) {
    if (onChanged == null) return child;
    return child.gestures(onTapUp: _handleTapUp, behavior: HitTestBehavior.opaque);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: value == false ? Colors.transparent : theme.accent1Darker,
          borderRadius: Corners.s3Border,
          border: Border.all(color: value == false ? theme.grey : theme.accent1Darker, width: 1.5)),
      child: _wrapGestures(_getIconForCurrentState()),
    );
  }
}
