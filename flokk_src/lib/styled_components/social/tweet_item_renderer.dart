import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/selectable_link_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/url_launcher/url_launcher.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/tweet_data.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styled_icons.dart';

class TweetListItem extends StatelessWidget {
  final Tweet tweet;

  const TweetListItem(this.tweet, {Key? key}) : super(key: key);

  void _handleRowPressed() {
    UrlLauncher.openHttp(tweet.url);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    int minutesAgo = DateTime.now().difference(tweet.createdAt).inMinutes;
    String timeTxt =
        minutesAgo < 60 ? "${minutesAgo}m" : "${(minutesAgo / 60).round()}h";
    if (minutesAgo > 60 * 24) {
      timeTxt = "${(minutesAgo / 60 / 24).round()}d";
    }
    TextStyle titleStyle = TextStyles.Body2;
    return Column(
      children: [
        Row(children: [
          OneLineText(tweet.user.name, style: titleStyle.bold).flexible(),
          HSpace(Insets.sm),
          OneLineText(tweet.retweeted ? "Retweeted" : "Tweeted",
                  style: titleStyle)
              .flexible(),
          Text("  ·  ", style: titleStyle),
          Text(timeTxt, style: titleStyle),
        ]),
        VSpace(Insets.sm),
        Row(children: [
          SelectableLinkText(
                  text: "${tweet.text}",
                  linkStyle:
                      TextStyles.Body1.textHeight(1.6).textColor(theme.accent1),
                  textStyle:
                      TextStyles.Body1.textHeight(1.6).textColor(theme.txt))
              .flexible()
        ]),
        VSpace(Insets.m),
        Row(children: [
          StyledImageIcon(StyledIcons.socialLike, size: 12, color: theme.grey),
          HSpace(Insets.sm),
          Text(
            "${tweet.favoriteCount}",
            style: TextStyles.Body3.textColor(theme.grey),
          ),
          HSpace(Insets.m),
          StyledImageIcon(StyledIcons.socialRetweet,
              size: 12, color: theme.grey),
          HSpace(Insets.sm),
          Text(
            "${tweet.retweetCount}",
            style: TextStyles.Body3.textColor(theme.grey),
          ),
        ]),
        VSpace(Insets.m),
        Container(
            color: theme.greyWeak.withOpacity(.35),
            width: double.infinity,
            height: 1),
        VSpace(Insets.l),
      ],
    ).gestures(onTap: _handleRowPressed, behavior: HitTestBehavior.opaque);
  }
}
