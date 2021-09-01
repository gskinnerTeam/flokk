import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSocial(BuildContext context, String type) {
  context.read<MainScaffoldState>().editSelectedContact(type);
}

void showContactPage(BuildContext context) {
  context.read<MainScaffoldState>().trySetCurrentPage(PageType.ContactsList);
}

/// //////////////////////////////////////////////////
/// INTERNAL HELPER WIDGETS
class EmptyStateTitleAndClickableText extends StatelessWidget {
  final String title;
  final String startText;
  final String endText;
  final String linkText;
  final CrossAxisAlignment crossAxisAlign;
  final VoidCallback? onPressed;

  const EmptyStateTitleAndClickableText({
    Key? key,
    this.title = "",
    this.startText = "",
    this.endText = "",
    this.linkText = "",
    this.onPressed,
    this.crossAxisAlign = CrossAxisAlignment.center,
  }) : super(key: key);

  TextSpan _buildTapSpan(String text, TextStyle style, VoidCallback? handler) {
    return TextSpan(
        text: text,
        style: style,
        recognizer: TapGestureRecognizer()..onTap = handler);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    TextStyle style = TextStyles.Body2.textColor(theme.grey).textHeight(1.4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlign,
      children: [
        VSpace(Insets.l),
        Text(
          title,
          style: TextStyles.T1.textColor(theme.grey),
        ),
        VSpace(Insets.m),
        RichText(
          text: TextSpan(
            style: style,
            children: [
              if (StringUtils.isNotEmpty(startText)) TextSpan(text: startText),
              if (StringUtils.isNotEmpty(linkText))
                _buildTapSpan(
                    linkText, style.textColor(theme.accent1), onPressed),
              if (StringUtils.isNotEmpty(endText)) TextSpan(text: endText),
            ],
          ),
        ),
        VSpace(Insets.m * 1.5),
      ],
    );
  }
}

class PlaceholderImageAndBgStack extends StatelessWidget {
  final String path;
  final Widget? bgWidget;
  final double? height;
  final double? top;
  final double? left;

  const PlaceholderImageAndBgStack(this.path,
      {Key? key, this.height, this.top, this.left, this.bgWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        bgWidget ?? _BgCircle(),
        Positioned(
          left: left,
          top: top,
          child:
              Image.asset("assets/images/empty-$path@2x.png", height: height),
        )
      ],
    );
  }
}

class _BgCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return StyledContainer(theme.bg2,
        width: 157, height: 157, borderRadius: BorderRadius.circular(999));
  }
}
