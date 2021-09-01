import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flutter/material.dart';

class TextInputIconRow extends StatelessWidget {
  final IconData icon;
  final bool autoFocus;
  final String initialValue;
  final String hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final void Function(bool)? onFocusChanged;

  const TextInputIconRow(this.icon, this.hintText,
      {Key? key,
      this.autoFocus = false,
      this.initialValue = "",
      this.onChanged,
      this.onEditingComplete,
      this.onFocusChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 24, color: Colors.grey),
        HSpace(Insets.l),
        StyledFormTextInput(
          autoFocus: autoFocus,
          initialValue: initialValue,
          onChanged: onChanged,
          onFocusChanged: onFocusChanged,
          onEditingComplete: onEditingComplete,
          hintText: hintText,
        ).flexible()
      ],
    );
  }
}
