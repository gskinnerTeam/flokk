import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/update_contact_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:flokk/styled_components/buttons/primary_btn.dart';
import 'package:flokk/styled_components/buttons/secondary_btn.dart';
import 'package:flokk/styled_components/styled_card.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styled_icons.dart';

class SocialPopupForm extends StatefulWidget {
  static const double kWidth = 270;
  static const double kHeight = 190;

  final VoidCallback? onClosePressed;
  final ContactData contact;
  final SocialActivityType socialActivityType;

  const SocialPopupForm(this.contact, {Key? key, this.onClosePressed, required this.socialActivityType})
      : super(key: key);

  @override
  _SocialPopupFormState createState() => _SocialPopupFormState();
}

class _SocialPopupFormState extends State<SocialPopupForm> {
  late ContactData _tmpContact;

  void _handleGitChanged(String value) => _tmpContact.gitUsername = value;

  void _handleTwitterChanged(String value) => _tmpContact.twitterHandle = value;

  void _handleBtnPressed(bool doSave) {
    if (doSave && !_tmpContact.hasSameSocial(widget.contact)) {
      UpdateContactCommand(context).execute(_tmpContact, updateSocial: true);
    }
    widget.onClosePressed?.call();
  }

  @override
  void initState() {
    _tmpContact = widget.contact.copy();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          type: MaterialType.transparency,
          child: StyledCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// GIT ICON + TEXT
                _SocialTextInput(
                  icon: StyledIcons.githubActive,
                  hint: "github.com/",
                  initial: widget.contact.gitUsername,
                  onChanged: _handleGitChanged,
                  autoFocus: widget.socialActivityType == SocialActivityType.Git,
                ),
                VSpace(Insets.sm),

                /// TWITTER ICON + TEXT
                _SocialTextInput(
                  icon: StyledIcons.twitterActive,
                  hint: "@",
                  initial: widget.contact.twitterHandle,
                  onChanged: _handleTwitterChanged,
                  autoFocus: widget.socialActivityType == SocialActivityType.Twitter,
                ),
                VSpace(Insets.l),

                /// SUBMIT BUTTONS
                Row(
                  children: [
                    PrimaryTextBtn("SAVE", onPressed: () => _handleBtnPressed(true)),
                    HSpace(Insets.m),
                    SecondaryTextBtn("CANCEL", onPressed: () => _handleBtnPressed(false)),
                  ],
                ),
              ],
            ).padding(all: Insets.l).constrained(width: SocialPopupForm.kWidth),
          ),
        )
      ],
    );
  }
}

class _SocialTextInput extends StatelessWidget {
  final String hint;
  final String initial;
  final AssetImage icon;
  final bool autoFocus;
  final void Function(String) onChanged;

  const _SocialTextInput(
      {Key? key, this.hint = "", required this.onChanged, this.initial = "", required this.icon, this.autoFocus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double prefixSize = StringUtils.measure(hint, TextStyles.Body1).width;
    EdgeInsets padding = StyledFormTextInput.kDefaultTextInputPadding.copyWith(left: prefixSize + .5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StyledImageIcon(icon, color: ColorUtils.shiftHsl(theme.accent1, theme.isDark ? .2 : -.2), size: 30),
        HSpace(Insets.m),
        Stack(
          children: <Widget>[
            /// Prefix text, non-interactive
            FocusScope(
                canRequestFocus: false,
                child: IgnorePointer(child: buildTextInput(context, hint: hint, onChanged: (v) {}))),

            /// Value text
            buildTextInput(context,
                hint: "", initial: initial, onChanged: onChanged, autoFocus: autoFocus, padding: padding),
          ],
        ).flexible()
      ],
    );
  }

  buildTextInput(BuildContext context,
      {String hint = "", String initial = "", bool autoFocus = false, void Function(String)? onChanged, EdgeInsets padding = StyledFormTextInput.kDefaultTextInputPadding}) {
    return StyledFormTextInput(
        contentPadding: padding,
        hintText: hint,
        autoFocus: autoFocus,
        initialValue: initial,
        maxLines: 1,
        onChanged: onChanged);
  }
}
