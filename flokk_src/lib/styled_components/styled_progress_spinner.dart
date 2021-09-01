import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StyledProgressSpinner extends StatelessWidget {
  final Color color;

  const StyledProgressSpinner({Key? key, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accent1Darker),
            backgroundColor: color),
      ),
    );
  }
}
