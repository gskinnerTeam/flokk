import 'package:flokk/app_extensions.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpeningDivider extends StatelessWidget {
  final bool isOpen;
  final Color? openColor;
  final Color? closeColor;

  const OpeningDivider(
      {Key? key, this.isOpen = false, this.openColor, this.closeColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isOpen ? 1 : 0),
      duration: isOpen ? .45.seconds : .15.seconds,
      curve: isOpen ? Curves.easeIn : Curves.easeOut,
      builder: (_, value, __) {
        Color oColor = openColor ?? theme.accent1.withOpacity(.3);
        Color cColor = closeColor ?? theme.greyWeak.withOpacity(.3);
        return FractionallySizedBox(
          alignment: Alignment.topLeft,
          widthFactor: value,
          child: Container(color: Color.lerp(cColor, oColor, value), height: 1),
        );
      },
    );
  }
}
