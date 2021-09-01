import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StyledCheckboxValue {
  All,
  None,
  Partial,
}

class StyledCheckbox extends StatelessWidget {
  final StyledCheckboxValue value;
  final double size;
  final void Function(StyledCheckboxValue)? onChanged;

  const StyledCheckbox(
      {Key? key,
      this.value = StyledCheckboxValue.None,
      this.size = 18,
      this.onChanged})
      : super(key: key);

  void _handleTapUp(TapUpDetails details) {
    switch (value) {
      case StyledCheckboxValue.All:
        onChanged?.call(StyledCheckboxValue.None);
        break;
      case StyledCheckboxValue.None:
        onChanged?.call(StyledCheckboxValue.Partial);
        break;
      case StyledCheckboxValue.Partial:
        onChanged?.call(StyledCheckboxValue.All);
        break;
    }
  }

  Widget _getIconForCurrentState() {
    switch (value) {
      case StyledCheckboxValue.All:
        return StyledImageIcon(StyledIcons.checkboxSelected,
            color: Colors.white, size: 15);
      case StyledCheckboxValue.None:
        return Container();
      case StyledCheckboxValue.Partial:
        return StyledImageIcon(StyledIcons.checkboxPartial,
            color: Colors.white, size: 15);
    }
  }

  Widget _wrapGestures(Widget child) {
    if (onChanged == null) return child;
    return child.gestures(
        onTapUp: _handleTapUp, behavior: HitTestBehavior.opaque);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: value == StyledCheckboxValue.None
              ? Colors.transparent
              : theme.accent1Darker,
          borderRadius: Corners.s3Border,
          border: Border.all(
              color: value == StyledCheckboxValue.None
                  ? theme.grey
                  : theme.accent1Darker,
              width: 1.5)),
      child: _wrapGestures(_getIconForCurrentState()),
    );
  }
}
