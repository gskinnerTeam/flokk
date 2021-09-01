import 'dart:math';

import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/scrolling/styled_horizontal_scroll_view.dart';
import 'package:flokk/styled_components/styled_group_label.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class StyledFormLabelInput extends StatefulWidget {
  //TODO SB@CE - Is this necessary, can't we just pass null and let the default inside StyledSearchTextInput handle it?
  static const EdgeInsets kDefaultTextInputPadding =
      EdgeInsets.only(bottom: Insets.sm, top: 4);

  final String hintText;
  final bool autoFocus;
  final EdgeInsets contentPadding;
  final List<String> labels;
  final void Function(String) onAddLabel;
  final void Function(String) onRemoveLabel;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingCancel;
  final void Function(bool)? onFocusChanged;

  const StyledFormLabelInput({
    this.hintText = "",
    this.autoFocus = false,
    this.contentPadding = kDefaultTextInputPadding,
    this.labels = const <String>[],
    required this.onAddLabel,
    required this.onRemoveLabel,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingCancel,
    this.onFocusChanged,
    Key? key,
  }) : super(key: key);

  @override
  _StyledFormLabelInputState createState() => _StyledFormLabelInputState();
}

class _StyledFormLabelInputState extends State<StyledFormLabelInput> {
  final GlobalKey<StyledSearchTextInputState> _textKey = GlobalKey();
  FocusNode? _textFocusNode;
  bool _focused = false;

  @override
  void initState() {
    RawKeyboard.instance.addListener(_handleRawKeyPressed);
    super.initState();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKeyPressed);
    super.dispose();
  }

  @override
  void didUpdateWidget(StyledFormLabelInput oldWidget) {
    // Detect when a new label was added from the parent and run the same logic as when we add a label from inside this widget
    if (widget.labels.length > oldWidget.labels.length) {
      _textKey.currentState?.text = "";
      // At a later time, make sure this field is focused
      Future.microtask(() => _textFocusNode?.requestFocus());
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleAddLabel(String label) {
    widget.onAddLabel(label);
    _textKey.currentState?.text = "";
    // At a later time, make sure this field is focused
    Future.microtask(() => _textFocusNode?.requestFocus());
  }

//TODO SB@CE - Consider using expression-body for these types of one-liners
  void _handleRemoveLabel(String label) {
    widget.onRemoveLabel(label);
  }

  void _handleFocusCreated(FocusNode focus) {
    _textFocusNode = focus;
  }

  void _handleFocusChanged(bool value) {
    widget.onFocusChanged?.call(value);
    setState(() => _focused = value);
  }

  void _handleRawKeyPressed(RawKeyEvent evt) {
    if (evt is RawKeyDownEvent) {
      if ((_textFocusNode?.hasFocus ?? false) &&
          evt.logicalKey == LogicalKeyboardKey.backspace) {
        if (_textKey.currentState != null &&
            (_textKey.currentState?.text.isEmpty ?? false)) {
          final tl = widget.labels;
          if (tl.isNotEmpty) {
            _handleRemoveLabel(tl.last);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double formWidth = 200;
    double inputWidth = formWidth;
    //TODO SB@CE - This could be  more readable
    final labelWidth = (String label) {
      return Insets.m +
          StringUtils.measure(
                  label.toUpperCase(), TextStyles.Footnote.letterSpace(0))
              .width +
          Insets.sm +
          Insets.sm +
          16 +
          Insets.sm +
          Insets.sm;
    };
    //TODO SB@CE - Not a big fan of ommitting type here, reduces scanability
    for (final label in widget.labels) {
      //TODO SB@CE - This should be called something like measureLabel, or calculateLabelWidth
      inputWidth -= labelWidth(label);
    }

    return Container(
      margin: EdgeInsets.only(bottom: Insets.m),
      child: Stack(
        children: [
          StyledHorizontalScrollView(
            autoScrollDuration: .200.seconds,
            autoScrollCurve: Curves.easeIn,
            child: Row(
              children: <Widget>[
                for (var label in widget.labels) ...{
                  StyledGroupLabel(
                    text: label,
                    onClose: () => _handleRemoveLabel(label),
                  ).padding(right: Insets.sm),
                },
                Container(
                  constraints: BoxConstraints(maxWidth: max(100, inputWidth)),
                  child: StyledSearchTextInput(
                    contentPadding: widget.contentPadding,
                    autoFocus: widget.autoFocus,
                    hintText: "Add label",
                    maxLines: 1,
                    key: _textKey,
                    style: TextStyles.Body1,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: _handleAddLabel,
                    onEditingCancel: widget.onEditingCancel,
                    onFocusChanged: _handleFocusChanged,
                    onFocusCreated: _handleFocusCreated,
                  ),
                ),
              ],
            ),
          ),
          //TODO SB@CE - This should respect focus color like other form underlines.
          Container(
            margin: EdgeInsets.only(top: 38),
            height: _focused ? 1.8 : 1.2,
            color: _focused
                ? (theme.isDark ? theme.accent2 : theme.accent1Dark)
                : theme.greyWeak.withOpacity(.35),
          )
        ],
      ),
    );
  }
}
