import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactSocialMiniForm extends BaseMiniForm {
  final SocialActivityType type;

  ContactSocialMiniForm(ContactEditFormState form, this.type, {Key? key})
      : super(
            form,
            type == SocialActivityType.Git
                ? ContactSectionType.github
                : ContactSectionType.twitter,
            key: key);

  bool get isGit => type == SocialActivityType.Git;

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      isGit ? StyledIcons.githubActive : StyledIcons.twitterActive,
      hasContent: isGit ? () => c.hasGit : () => c.hasTwitter,
      formBuilder: () {
        // Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(builder: (context) {
          if (type == SocialActivityType.Git) {
            return buildPrefixedTextInput(context, "github.com/", c.gitUsername,
                (v) => c.gitUsername = v);
          } else {
            return buildPrefixedTextInput(
                context, "@", c.twitterHandle, (v) => c.twitterHandle = v);
          }
        }).padding(right: rightPadding);
      },
    );
  }

  /// Builds prefixed TextInput used for git/twitter
  Widget buildPrefixedTextInput(BuildContext context, String hint,
      String initial, Function(String) onChanged,
      [bool autoFocus = false]) {
    double prefixSize = StringUtils.measure(hint, TextStyles.Body1).width;
    EdgeInsets padding = StyledFormTextInput.kDefaultTextInputPadding
        .copyWith(left: prefixSize + .5);
    return FocusTraversalGroup(
      child: Stack(
        children: <Widget>[
          /// Prefix text, non-interactive
          IgnorePointer(
            child: FocusScope(
                canRequestFocus: false,
                child: buildTextInput(context, hint, "", (v) {})),
          ),

          /// Value text
          buildTextInput(context, "", initial, onChanged,
              autoFocus: isSelected, padding: padding),
        ],
      ),
    );
  }
}
