import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/strings.dart';
import 'package:flokk/styled_components/buttons/primary_btn.dart';
import 'package:flokk/styled_components/buttons/secondary_btn.dart';
import 'package:flokk/styles.dart';
import 'package:flutter/material.dart';

class OkCancelBtnRow extends StatelessWidget {
  final VoidCallback? onOkPressed;
  final VoidCallback? onCancelPressed;
  final String? okLabel;
  final String? cancelLabel;

  const OkCancelBtnRow(
      {Key? key,
      this.onOkPressed,
      this.onCancelPressed,
      this.okLabel,
      this.cancelLabel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (onOkPressed != null)
          PrimaryTextBtn(okLabel ?? S.BTN_OK.toUpperCase(),
              onPressed: onOkPressed),
        HSpace(Insets.m),
        if (onCancelPressed != null)
          SecondaryTextBtn(cancelLabel ?? S.BTN_CANCEL.toUpperCase(),
              onPressed: onCancelPressed),
      ],
    );
  }
}
