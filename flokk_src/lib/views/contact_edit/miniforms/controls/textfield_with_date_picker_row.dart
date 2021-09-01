import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/secondary_btn.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_edit/expanding_miniform_container.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextfieldWithDatePickerRow extends StatefulWidget {
  final BaseMiniForm miniform;
  final bool isSelected;
  final String hint;
  final String? initialValue;
  final void Function(String, DateTime)? onDateChanged;

  const TextfieldWithDatePickerRow(
    this.miniform, {
    Key? key,
    this.isSelected = false,
    this.hint = "",
    this.initialValue,
    this.onDateChanged,
  }) : super(key: key);

  @override
  _TextfieldWithDatePickerRowState createState() =>
      _TextfieldWithDatePickerRowState();
}

class _TextfieldWithDatePickerRowState
    extends State<TextfieldWithDatePickerRow> {
  late TextEditingController textController;

  void handleDatePicked(BuildContext context) async {
    DateTime firstDate = DateTime.now().subtract((365 * 100).days);
    DateTime lastDate = DateTime.now().add((365 * 10).days);
    DateTime startDate;

    ///Parse the current date text, we can have no idea if this is a valid date or not
    startDate = parseDate(textController.text);

    /// Manually 'clamp' these dates because material date picker likes to blow up with AssertErrors rather than fail gracefully
    if (startDate.isBefore(firstDate)) startDate = firstDate;
    if (startDate.isAfter(lastDate)) startDate = lastDate;
    DateTime? result = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null) {
      textController.text = DateFormats.google.format(result);
      widget.onDateChanged?.call(textController.text, result);
    }
  }

  DateTime parseDate(String v) {
    try {
      return DateFormats.google.parse(v);
    } on FormatException catch (_) {
      return DateTime.now();
    }
  }

  @override
  void initState() {
    textController = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  _handleFocusChanged(bool value) =>
      FocusChangedNotification(value).dispatch(context);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 80),
          child: widget.miniform.buildTextInput(
            context,
            widget.hint,
            widget.initialValue,
            (v) => widget.onDateChanged?.call(v, parseDate(v)),
            autoFocus: widget.isSelected,
            controller: textController,
          ),
        ),
        SecondaryBtn(
          onPressed: () => handleDatePicked(context),
          minHeight: 20,
          contentPadding: Insets.sm,
          onFocusChanged: _handleFocusChanged,
          child: StyledImageIcon(StyledIcons.calendar, color: theme.accent1),
        ).positioned(right: 0, bottom: 3),
      ],
    );
  }
}
