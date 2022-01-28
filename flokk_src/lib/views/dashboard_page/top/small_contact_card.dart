import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/social/clickable_social_badges.dart';
import 'package:flokk/styled_components/styled_card.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SmallContactCard extends StatelessWidget {

  static const double cardWidth = 162;

  final ContactData contact;

  const SmallContactCard(this.contact, {Key? key}) : super(key: key);

  void _handleCardPressed(BuildContext c) =>
      c.read<MainScaffoldState>().trySetSelectedContact(contact, showSocial: false);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    Color txtColor = theme.isDark ? Colors.white : Colors.black;
    return StyledCard(
      onPressed: () => _handleCardPressed(context),
      child: Container(
        margin: EdgeInsets.all(Insets.m),
        width: cardWidth - Insets.m * 2,
        child: Column(
          children: [
            StyledUserAvatar(contact: contact, size: 60),
            VSpace(Insets.m),
            Text(
              contact.nameFull,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: TextStyles.H2.textHeight(1.3).textColor(txtColor).regular,
              textAlign: TextAlign.center,
            ).center().height(30),
            Spacer(),
            ClickableSocialBadges(contact, showTimeSince: true),
          ],
        ),
      ),
    ).padding(
      right: Insets.m * 1.75,
      vertical: Insets.m,
    );
  }
}
