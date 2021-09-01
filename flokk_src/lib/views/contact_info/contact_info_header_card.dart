import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/toggle_favorite_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/styled_group_label.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactInfoHeaderCard extends StatefulWidget {
  const ContactInfoHeaderCard({Key? key}) : super(key: key);

  @override
  _ContactInfoHeaderCardState createState() => _ContactInfoHeaderCardState();
}

class _ContactInfoHeaderCardState extends State<ContactInfoHeaderCard> {
  void handleStarPressed(ContactData c) {
    ToggleFavoriteCommand(context).execute(c);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /// ///////////////////////////////////////////////
    /// Bind to provided contact
    ContactData contact = context.watch();

    AppTheme theme = context.watch();

    List<Widget> labels = contact.groupList
        .map((e) =>
            StyledGroupLabel(icon: null, text: e.name.toUpperCase()).padding(
              horizontal: Insets.sm * .5,
            ))
        .toList();

    return SeparatedColumn(
      separatorBuilder: () => SizedBox(height: Insets.m * .5),
      children: <Widget>[
        VSpace(Insets.sm - 1),

        /// PROFILE PIC
        StyledUserAvatar(
            key: ValueKey(contact.id + contact.profilePic),
            size: 110,
            contact: contact),

        /// TITLE
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            OneLineText(contact.nameFull, style: TextStyles.H1).flexible(),
            HSpace(Insets.sm * .5),
            ColorShiftIconBtn(
              contact.isStarred
                  ? StyledIcons.starFilled
                  : StyledIcons.starEmpty,
              color: contact.isStarred ? theme.accent1 : theme.grey,
              onPressed: () => handleStarPressed(contact),
            ),
          ],
        ),

        /// LABELS
        if (contact.groupList.isNotEmpty) Wrap(children: labels),

        /// Social Icons
        //SocialIconStrip(contact: contact),
      ],
    ).translate(offset: Offset(0, -Insets.m));
  }
}

class SocialIconStrip extends StatelessWidget {
  final ContactData contact;
  final bool vtMode;

  const SocialIconStrip({Key? key, required this.contact, this.vtMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      ColorShiftIconBtn(StyledIcons.githubActive),
      ColorShiftIconBtn(StyledIcons.twitterActive),
      //StyledIconButton(child: Icon(Icons.contacts)),
    ];
    return vtMode
        ? widgets.toColumn(mainAxisSize: MainAxisSize.min)
        : widgets.toRow(mainAxisSize: MainAxisSize.min);
  }
}
