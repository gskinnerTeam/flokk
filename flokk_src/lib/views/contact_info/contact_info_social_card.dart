import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/social_contact_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styled_components/social/git_item_renderer.dart';
import 'package:flokk/styled_components/social/tweet_item_renderer.dart';
import 'package:flokk/styled_components/styled_card.dart';
import 'package:flokk/styled_components/styled_progress_spinner.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flokk/views/empty_states/placeholder_git.dart';
import 'package:flokk/views/empty_states/placeholder_twitter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactInfoSocialCard extends StatefulWidget {
  const ContactInfoSocialCard({Key? key}) : super(key: key);

  @override
  _ContactInfoSocialCardState createState() => _ContactInfoSocialCardState();
}

class _ContactInfoSocialCardState extends State<ContactInfoSocialCard> {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();

    /// ///////////////////////////////////////////////
    /// Bind to provided contact
    ContactData contact = context.watch();
    ContactsModel contactsModel = context.watch();
    bool isGitLoading = context.select<GithubModel, bool>((gm) => gm.isLoading);
    bool isTwitterLoading = context.select<TwitterModel, bool>((tm) => tm.isLoading);
    SocialContactData? social = contactsModel.getSocialById(contact.id);

    int maxItems = 30;
    final gitItems = social?.gitEvents.map((event) => GitEventListItem(event)).take(maxItems).toList() ?? [];
    final tweetItems = social?.tweets.map((tweet) => TweetListItem(tweet)).take(maxItems).toList() ?? [];

    //return Container();
    return Column(
      children: <Widget>[
        (isTwitterLoading
                ? StyledCard(bgColor: theme.bg1, child: StyledProgressSpinner())
                : PlaceholderContentSwitcher(
                    hasContent: () => tweetItems.isNotEmpty,
                    placeholder: TwitterPlaceholder(contact: contact),
                    content: StyledListViewWithTitle(
                      bgColor: theme.bg1.withOpacity(.35),
                      listItems: tweetItems,
                      title: "TWITTER RECENT ACTIVITY",
                    ),
                  ))
            .height(300),
        VSpace(Insets.l),
        (isGitLoading
                ? StyledCard(bgColor: theme.bg1, child: StyledProgressSpinner())
                : PlaceholderContentSwitcher(
                    hasContent: () => gitItems.isNotEmpty,
                    placeholder: GitPlaceholder(contact: contact),
                    content: StyledListViewWithTitle(
                      bgColor: theme.bg1.withOpacity(.35),
                      listItems: gitItems,
                      title: "GITHUB RECENT ACTIVITY",
                    ),
                  ))
            .height(300),
      ],
    ).padding(top: Insets.m * 1.5, bottom: Insets.l);
  }
}
