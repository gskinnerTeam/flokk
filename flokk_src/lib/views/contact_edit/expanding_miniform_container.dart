import 'dart:async';

import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

/// [FocusChangedNotification] Dispatched from a mini-form up into the ExpandingFormContainer,
/// allowing the Container to track focus state
class FocusChangedNotification extends Notification {
  final bool isFocused;

  FocusChangedNotification(this.isFocused);
}

/// [FocusChangedNotification] Dispatched from a mini-form up indicating we should close the container
class CloseFormNotification extends Notification {}

typedef Widget FormBuilder<T>();
typedef bool BoolCallback();

/// /////////////////////////////////////////////////////
/// [ExpandingMiniformContainer] - Holds a textfield prompt that opens into a form, listens for focus [FocusChangedNotification]
/// and auto-closes the container after a certain amt of time un-focused
class ExpandingMiniformContainer<T> extends StatefulWidget {
  final AssetImage icon;
  final String sectionType;
  final String activeSectionType;
  final BoolCallback hasContent;
  final FormBuilder<T> formBuilder;
  final void Function(String)? onOpened;
  final bool autoFocus;

  const ExpandingMiniformContainer(this.sectionType, this.icon,
      {Key? key,
      this.activeSectionType = "",
      required this.hasContent,
      required this.formBuilder,
      this.onOpened,
      this.autoFocus = false})
      : super(key: key);

  @override
  _ExpandingMiniformContainerState createState() => _ExpandingMiniformContainerState();
}

class _ExpandingMiniformContainerState extends State<ExpandingMiniformContainer> with TickerProviderStateMixin {
  bool? _isOpen;
  String _hint = "";
  Timer? timer;

  set isOpen(bool value) => setState(() => _isOpen = value);

  void _handlePromptFocusChanged(v) {
    if (v == false) return;
    // FIX: Unfocus any current textfields otherwise Flutter seems to randomly miss the new autofocus when its added to the tree
    Utils.unFocus();
    // Show the form widget
    Future.delayed(1.milliseconds, () => isOpen = true);
    widget.onOpened?.call(widget.sectionType);
  }

  bool _handleFormFocusChanged(bool value) {
    if (value == false) {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: 750), () {
        if (widget.hasContent()) return;
        isOpen = false;
      });
    } else {
      timer?.cancel();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1; //
    _isOpen ??= widget.hasContent() || widget.autoFocus;
    switch (widget.sectionType) {
      case "github":
        _hint = "Add GitHub ID";
        break;
      case "twitter":
        _hint = "Add Twitter ID";
        break;
      default:
        _hint = "Add ${widget.sectionType}";
        break;
    }
    AppTheme theme = context.watch();

    return NotificationListener<FocusChangedNotification>(
      // Listen for FocusNotifications from the child mini-form,
      // This way we can track our focus state without coupling directly to the mini-form
      onNotification: (n) => _handleFormFocusChanged(n.isFocused),
      child: NotificationListener<CloseFormNotification>(
        onNotification: (n) => isOpen = false,
        child: AnimatedSize(
          alignment: Alignment.topLeft,
          curve: Curves.easeOut,
          duration: Durations.fast,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Left Icon
              StyledImageIcon(widget.icon, size: 20, color: theme.grey).translate(offset: Offset(0, 8)),
              HSpace(Insets.l),

              /// Content - Either the miniform, or the StyledText
              (_isOpen!
                      // Mini-Form
                      ? widget.formBuilder()
                      // Empty Prompt Text
                      : StyledFormTextInput(hintText: _hint, onFocusChanged: _handlePromptFocusChanged)
                          .padding(right: Insets.l * 1.5 - 2))
                  .padding(right: Insets.m)
                  .flexible(),
            ],
          ),
        ),
      ),
    );
  }
}
