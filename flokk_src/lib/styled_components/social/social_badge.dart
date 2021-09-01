import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocialBadge extends StatelessWidget {
  final AssetImage icon;
  final AssetImage iconPlaceholder;
  final int newMessageCount;
  final bool hasAccount;
  final VoidCallback? onPressed;

  const SocialBadge(
      {required this.icon,
      required this.iconPlaceholder,
      this.newMessageCount = 0,
      Key? key,
      this.hasAccount = false,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double size = 35;
    String msgText = newMessageCount > 9 ? "9+" : "$newMessageCount";
    return TransparentBtn(
      onPressed: onPressed,
      child: Stack(
        children: [
          /// PLACEHOLDER
          if (!hasAccount)
            StyledImageIcon(iconPlaceholder,
                    size: 32, color: theme.greyWeak.withOpacity(.7))
                .center(),

          /// VALID ACCOUNT
          if (hasAccount)
            StyledImageIcon(icon,
                size: 28,
                color: newMessageCount > 0 ? theme.accent1 : theme.grey),
          if (hasAccount)
            StyledContainer(
              theme.bg1,
              align: Alignment.center,
              borderRadius: BorderRadius.circular(99),
              child: Text(
                "$msgText",
                textAlign: TextAlign.center,
                style: TextStyles.Footnote.textColor(theme.txt).letterSpace(1),
              ).translate(offset: Offset(0, -1)),
            )
                .constrained(width: 19, height: 19)
                .alignment(Alignment.bottomRight),
        ],
      ).width(size).height(size),
    );
  }
}
