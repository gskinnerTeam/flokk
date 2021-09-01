import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactListPlaceholder extends StatelessWidget {
  final bool isSearching;

  const ContactListPlaceholder({Key? key, this.isSearching = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    var bgImage = Image.asset("assets/images/empty-noresult-bg@2x.png",
            height: 108, color: theme.bg2)
        .translate(offset: Offset(8, 2));
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      PlaceholderImageAndBgStack("noresult-owl",
          bgWidget: bgImage, height: 126, top: 15, left: -30),
      VSpace(Insets.l),
      isSearching
          ? EmptyStateTitleAndClickableText(
              title: "NO RESULTS IN YOUR CONTACTS",
              startText:
                  "We couldn't find any results that matched your search.\nPlease try another search.",
            )
          : EmptyStateTitleAndClickableText(
              onPressed: () => showContactPage(context),
              title: "NO CONTACTS YET",
              startText: "",
              linkText: "Create Contacts",
              endText: " to get started!",
            )
    ]);
  }
}
