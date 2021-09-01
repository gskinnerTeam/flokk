import 'package:flokk/_internal/url_launcher/url_launcher.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/clickable_icon_row.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ContactInfoDetailsCard extends StatelessWidget {
  const ContactInfoDetailsCard({Key? key}) : super(key: key);

  void _handlePhonePressed(String value) => UrlLauncher.openPhoneNumber(value);

  void _handleEmailPressed(String value) => UrlLauncher.openEmail(value);

  void _handleLocationPressed(String value) =>
      UrlLauncher.openGoogleMaps(value);

  void _handleGitPressed(String value) => UrlLauncher.openGitUser(value);

  void _handleTwitterPressed(String value) =>
      UrlLauncher.openTwitterUser(value);

  void _handleLinkPressed(String value) => UrlLauncher.openHttp(value);

  @override
  Widget build(BuildContext context) {
    /// ///////////////////////////////////////////////
    /// Bind to provided contact
    ContactData contact = context.watch();

    return Column(
      children: <Widget>[
        /// EMAIL
        if (contact.hasEmail)
          MultilineClickableIconRow(
            icon: StyledIcons.mail,
            onPressed: _handleEmailPressed,
            editType: ContactSectionType.email,
            rows:
                contact.emailList.map((e) => Tuple2(e.value, e.type)).toList(),
          ),

        /// PHONE
        if (contact.hasPhone)
          MultilineClickableIconRow(
            icon: StyledIcons.phone,
            onPressed: _handlePhonePressed,
            editType: ContactSectionType.phone,
            rows:
                contact.phoneList.map((e) => Tuple2(e.number, e.type)).toList(),
          ),

        /// SOCIAL
        if (contact.hasGit)
          ClickableIconRow(
            icon: StyledIcons.githubActive,
            onPressed: _handleGitPressed,
            value: "github.com/${contact.gitUsername}",
            editType: ContactSectionType.github,
          ),
        if (contact.hasTwitter)
          ClickableIconRow(
            icon: StyledIcons.twitterActive,
            onPressed: _handleTwitterPressed,
            value: "@${contact.twitterHandle}",
            editType: ContactSectionType.twitter,
          ),

        /// ADDRESS
        if (contact.hasAddress)
          MultilineClickableIconRow(
            icon: StyledIcons.address,
            onPressed: _handleLocationPressed,
            rows: contact.addressList
                .map((a) => Tuple2(a.getFullAddress(), a.type))
                .toList(),
            editType: ContactSectionType.address,
          ),

        /// Job
        if (contact.hasJob)
          ClickableIconRow(
              icon: StyledIcons.work,
              value: contact.formattedJob,
              editType: ContactSectionType.job),

        /// BIRTHDAY
        if (contact.hasBirthday)
          ClickableIconRow(
              icon: StyledIcons.birthday,
              value: contact.birthday.text,
              editType: ContactSectionType.birthday),

        /// Events
        MultilineClickableIconRow(
          icon: StyledIcons.calendar,
          rows: contact.eventList
              .map((d) => Tuple2(DateFormats.google.format(d.date), d.type))
              .toList(),
          editType: ContactSectionType.events,
        ),

        /// LINKS
        if (contact.hasLink)
          MultilineClickableIconRow(
              icon: StyledIcons.link,
              onPressed: _handleLinkPressed,
              rows: contact.websiteList
                  .map((a) => Tuple2(a.href, a.type))
                  .toList(),
              editType: ContactSectionType.websites),

        /// NOTES
        if (contact.hasNotes)
          ClickableIconRow(
              icon: StyledIcons.note,
              value: contact.notes,
              editType: ContactSectionType.notes),

        /// RELATIONSHIP
        if (contact.hasRelationship)
          MultilineClickableIconRow(
            icon: StyledIcons.relationship,
            rows: contact.relationList
                .map((a) => Tuple2(a.person, a.type))
                .toList(),
            editType: ContactSectionType.relationship,
          ),
      ],
    ).padding(top: Insets.m * 1.5, bottom: 50);
  }
}
