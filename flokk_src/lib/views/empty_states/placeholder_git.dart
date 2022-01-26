
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';
import 'package:flutter/material.dart';

class GitPlaceholder extends StatelessWidget {
  final bool isTrending;

  // If contact is set, this widget will act as if it belongs to a single contact
  final ContactData? contact;

  const GitPlaceholder({Key? key, this.isTrending = false, required this.contact}) : super(key: key);

  void _handleLinkPressed(BuildContext context) {
    //If in single-contact mode, try and edit the selected contact
    if (contact != null) {
      showSocial(context, ContactSectionType.github);
    }
    // Try and move to ContactList page
    else {
      showContactPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (constraints.maxHeight > 250) PlaceholderImageAndBgStack("dashboard-github", height: 126, top: 43, left: -30),
        EmptyStateTitleAndClickableText(
          title: isTrending ? "NO TRENDING REPOS" : "NO GITHUB ACTIVITY",
          startText: contact == null ? "Add GitHub ID in " : "Add ",
          linkText: contact == null ? "contacts" : "GitHub ID",
          endText: " to show ${isTrending ? "trending repos" : "recent activity"}",
          onPressed: () => _handleLinkPressed(context),
          ),
      ]),
      );
  }
}
