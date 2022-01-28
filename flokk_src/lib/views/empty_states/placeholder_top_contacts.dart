import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/empty_states/placeholder_widget_helpers.dart';
import 'package:flutter/material.dart';

class TopContactsPlaceholder extends StatelessWidget {
  final bool isRecent;

  const TopContactsPlaceholder({Key? key, this.isRecent = false}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        bool showImage = constraints.maxWidth > 500;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showImage) ...{
              isRecent
                  ? PlaceholderImageAndBgStack("dashboard-recentActive", height: 157, top: 2)
                  : PlaceholderImageAndBgStack("dashboard-favorites", height: 126, top: 22),
              HSpace(Insets.xl),
            },
            EmptyStateTitleAndClickableText(
              title: isRecent ? "NO RECENT ACTIVITY" : "NO FAVORITE CONTACTS",
              startText: "${isRecent ? "Add GitHub and Twitter handles in " : "Star "}",
              linkText: "contacts",
              endText: " to show their recent activity",
              onPressed: () => showContactPage(context),
              crossAxisAlign: showImage ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            ).width(230).translate(offset: Offset(0, -15))
          ],
        );
      },
    );
  }
}
