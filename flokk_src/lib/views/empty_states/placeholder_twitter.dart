import 'package:flokk/data/contact_data.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';
import 'package:flutter/material.dart';

class TwitterPlaceholder extends StatelessWidget {
  // If popular, this widget will use slightly different text
  final bool isPopular;

  // If contact is set, this widget will act as if it belongs to a single contact
  final ContactData? contact;

  const TwitterPlaceholder({Key? key, this.isPopular = false, required this.contact}) : super(key: key);

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
        if (constraints.maxHeight > 250) PlaceholderImageAndBgStack("dashboard-twitter", height: 126, top: 43),
        EmptyStateTitleAndClickableText(
          title: isPopular ? "NO POPULAR TWEETS" : "NO TWITTER ACTIVITY",
          startText: contact == null ? "Add Twitter Handles in " : "Add ",
          linkText: contact == null ? "contacts" : "Twitter Handle",
          endText: " to show ${isPopular ? "popular tweets" : "recent activity"}",
          onPressed: () => _handleLinkPressed(context),
        ),
      ]),
    );
  }
}
