import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:flokk/data/social_contact_data.dart';
import 'package:flokk/data/tweet_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/styled_components/social/social_badge.dart';
import 'package:flokk/styled_components/social/social_popup_form.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../styled_icons.dart';

class ClickableSocialBadges extends StatefulWidget {
  final ContactData contact;
  final bool showTimeSince;

  const ClickableSocialBadges(this.contact, {Key? key, this.showTimeSince = false}) : super(key: key);

  @override
  _ClickableSocialBadgesState createState() => _ClickableSocialBadgesState();
}

class _ClickableSocialBadgesState extends State<ClickableSocialBadges> {
  LayerLink overlayLink = LayerLink();

  late Size _viewSize;

  void _handleSocialClicked(BuildContext context, ContactData contact, SocialActivityType type) {
    // If they clicked a badge that they have already entered a handle for, then open their social panel.
    if (contact.hasSocialOfType(type)) {
      context.read<MainScaffoldState>().trySetSelectedContact(contact, showSocial: true);
    } else {
      _showSocialMiniFormOverlay(context, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    //Bind to social models so we always rebuild when they change
    context.watch<TwitterModel>();
    context.watch<GithubModel>();
    //Fetch model so we can get the latest social info
    ContactsModel contactsModel = Provider.of(context, listen: false);
    // Grab socialData for this contact (might be null)
    SocialContactData social = contactsModel.getSocialById(widget.contact.id);
    // Get the time of their last activity
    DateTime lastSocialTime = social.latestActivity.createdAt;
    // Grab any tweets we haven't look at yet
    List<Tweet> newTweets = social.newTweets;
    List<GitEvent> newGits = social.newGits;
    // Figure out bottom text, changes if we have no social
    String bottomTxt = "Add Social IDs";
    if (widget.contact.hasAnySocial) {
      bottomTxt = lastSocialTime != Dates.epoch ? timeago.format(lastSocialTime) : "No New Activities";
    }
    return LayoutBuilder(
      builder: (_, constraints) {
        // Record the current view size so the Overlay knows how much to offset itself by
        _viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        return CompositedTransformTarget(
          link: overlayLink,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SocialBadge(
                  icon: StyledIcons.twitterActive,
                  iconPlaceholder: StyledIcons.twitterEmpty,
                  newMessageCount: newTweets.length,
                  hasAccount: widget.contact.hasTwitter,
                  onPressed: () => _handleSocialClicked(context, widget.contact, SocialActivityType.Twitter),
                ),
                HSpace(Insets.m),
                SocialBadge(
                  icon: StyledIcons.githubActive,
                  iconPlaceholder: StyledIcons.githubEmpty,
                  newMessageCount: newGits.length,
                  hasAccount: widget.contact.hasGit,
                  onPressed: () => _handleSocialClicked(context, widget.contact, SocialActivityType.Git),
                ),
              ],
            ),
            if (widget.showTimeSince) VSpace(Insets.sm * 1.5),
            if (widget.showTimeSince) Text(bottomTxt, style: TextStyles.Body2.textColor(theme.greyWeak)),
            VSpace(Insets.sm),
          ]),
        );
      },
    );
  }

  void _showSocialMiniFormOverlay(BuildContext context, SocialActivityType type) {
    AppTheme theme = context.read();
    late OverlayEntry bg;
    late OverlayEntry form;

    void _closeOverlay() {
      bg.remove();
      form.remove();
    }

    bg = OverlayEntry(
      builder: (_) {
        return FadeInWidget(
          Container(color: theme.greyWeak.withOpacity(.6)).gestures(onTap: _closeOverlay),
        );
      },
    );
    form = OverlayEntry(builder: (_) {
      return CompositedTransformFollower(
          offset: Offset(-SocialPopupForm.kWidth * .5 + _viewSize.width * .5, 0),
          link: overlayLink,
          child: FadeInWidget(SocialPopupForm(
            widget.contact,
            onClosePressed: _closeOverlay,
            socialActivityType: type,
          )));
    });
    Overlay.of(context)?.insert(bg);
    Overlay.of(context)?.insert(form);
  }
}

class FadeInWidget extends StatelessWidget {
  final Widget child;

  const FadeInWidget(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Durations.fastest,
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
