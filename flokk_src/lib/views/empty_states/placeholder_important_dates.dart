import 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';
import 'package:flutter/material.dart';

class ImportantDatesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EmptyStateTitleAndClickableText(
          title: "NO UPCOMING IMPORTANT DATES",
          startText: "Add birthdays/special dates to your ",
          linkText: "contacts",
          onPressed: () => showContactPage(context),
        ),
      ],
    );
  }
}
