import 'package:dotted_border/dotted_border.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

export 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';

typedef HasContentCallback = bool Function();

/// [PlaceholderContentSwitcher] Takes content and a placeholder, and swaps between them depending on the results of the hasContent delegate.
class PlaceholderContentSwitcher extends StatelessWidget {
  final bool showOutline;
  final Widget placeholder;
  final Widget content;
  final HasContentCallback hasContent;
  final EdgeInsets placeholderPadding;

  const PlaceholderContentSwitcher(
      {Key? key,
      this.showOutline = true,
      required this.placeholder,
      required this.content,
      required this.hasContent,
      this.placeholderPadding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        hasContent() ? content : _buildPlaceholder(context),
      ],
    );
  }

  _buildPlaceholder(BuildContext context) {
    AppTheme theme = context.watch();
    return Container(
        alignment: Alignment.center,
        margin: placeholderPadding,
        child: showOutline
            ? DottedBorder(
                // ignore: prefer_const_literals_to_create_immutables
                dashPattern: [2, 4],
                color: theme.greyWeak.withOpacity(.7),
                borderType: BorderType.RRect,
                radius: Corners.s8Radius,
                child: Center(child: placeholder))
            : placeholder);
  }
}
