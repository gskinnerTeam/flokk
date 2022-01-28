import 'package:flokk/_internal/components/fading_index_stack.dart';
import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/styled_components/social/git_item_renderer.dart';
import 'package:flokk/styled_components/social/tweet_item_renderer.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_tab_bar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/dashboard_page/social/responsive_double_list.dart';
import 'package:flokk/views/empty_states/placeholder_git.dart';
import 'package:flokk/views/empty_states/placeholder_twitter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocialActivitySection extends StatefulWidget {
  @override
  _SocialActivitySectionState createState() => _SocialActivitySectionState();
}

class _SocialActivitySectionState extends State<SocialActivitySection> {
  void _handleTabPressed(int index) {
    if (index == 0) context.read<AppModel>().dashSocialSection = DashboardSocialSectionType.All;
    if (index == 1) context.read<AppModel>().dashSocialSection = DashboardSocialSectionType.Twitter;
    if (index == 2) context.read<AppModel>().dashSocialSection = DashboardSocialSectionType.Git;
    context.read<AppModel>().scheduleSave();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    GithubModel gitModel = context.watch();
    TwitterModel twitterModel = context.watch();
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        /// Responsively size tab bars
        double tabWidth = constraints.maxWidth < PageBreaks.LargePhone ? 240 : 280;
        TextStyle headerStyle = TextStyles.T1;

        bool useTabView = constraints.maxWidth < PageBreaks.TabletPortrait - 100;

        /// Determine which tab should be selected
        var sectionType = layoutContext.select<AppModel, DashboardSocialSectionType>((model) => model.dashSocialSection);
        int tabIndex = 0;
        if (sectionType == DashboardSocialSectionType.Twitter) tabIndex = 1;
        if (sectionType == DashboardSocialSectionType.Git) tabIndex = 2;

        /// Get the 2 lists that should be displayed
        int maxItems = 20;
        List<Widget> list1;
        String list1Title = "";
        List<Widget> list2;
        String list2Title = "";
        Widget list1Placeholder;
        Widget list2Placeholder;
        AssetImage icon1;
        AssetImage icon2;

        switch (sectionType) {
          case DashboardSocialSectionType.All:
            list1Title = "TWITTER RECENT ACTIVITY";
            list1 = twitterModel.allTweets.map((tweet) => TweetListItem(tweet)).take(maxItems).toList();
            list1Placeholder = TwitterPlaceholder(contact: null);
            icon1 = StyledIcons.twitterActive;
            list2Title = "GITHUB RECENT ACTIVITY";
            list2 = gitModel.allEvents.map((event) => GitEventListItem(event)).take(maxItems).toList();
            list2Placeholder = GitPlaceholder(contact: null);
            icon2 = StyledIcons.githubActive;
            break;
          case DashboardSocialSectionType.Git:
            list1Title = "GITHUB RECENT ACTIVITY";
            list1Placeholder = GitPlaceholder(contact: null);
            list1 = gitModel.allEvents.map((event) => GitEventListItem(event)).take(maxItems).toList();
            icon1 = StyledIcons.githubActive;
            list2Title = "TRENDING REPOSITORIES";
            list2Placeholder = GitPlaceholder(contact: null, isTrending: true);
            list2 = gitModel.popularRepos.map((repo) => GitRepoListItem(repo)).take(maxItems).toList();
            icon2 = StyledIcons.githubActive;
            break;
          case DashboardSocialSectionType.Twitter:
            list1 = twitterModel.allTweets.map((e) => TweetListItem(e)).take(maxItems).toList();
            list1Placeholder = TwitterPlaceholder(contact: null);
            list1Title = "TWITTER RECENT ACTIVITY";
            icon1 = StyledIcons.twitterActive;
            list2 = twitterModel.popularTweets.map((e) => TweetListItem(e)).take(maxItems).toList();
            list2Placeholder = TwitterPlaceholder(contact: null, isPopular: true);
            list2Title = "POPULAR TWEETS";
            icon2 = StyledIcons.twitterActive;
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OneLineText("SOCIAL ACTIVITIES", style: headerStyle.textColor(theme.accent1Darker)).flexible(),
                StyledTabBar(
                  index: tabIndex,
                  sections: ["All", "Twitter", "GitHub"],
                  onTabPressed: _handleTabPressed,
                ).constrained(maxWidth: tabWidth, animate: true).animate(Durations.medium, Curves.easeOut),
              ],
            ),
            VSpace(Insets.l * .75),
            FadingIndexedStack(
              index: tabIndex,
              duration: Durations.fastest,
              children: [
                /// This looks weird, but it's really pretty robust / elegant
                /// Create 3 children, only the child that matches tabIndex will get the latest data, the previous index will fadeout while retaining it's old state.
                /// Doing it this way preserves scroll position & state for all tabs
                ...List<Widget>.generate(3, (index) {
                  return ResponsiveDoubleList(
                    list1: list1,
                    list1Title: list1Title,
                    list2: list2,
                    list2Title: list2Title,
                    list1Placeholder: list1Placeholder,
                    list2Placeholder: list2Placeholder,
                    useTabView: useTabView,
                    list1Icon: icon1,
                    list2Icon: icon2,
                  );
                }),
              ],
            ).expanded(),
          ],
        );
      },
    );
  }
}
