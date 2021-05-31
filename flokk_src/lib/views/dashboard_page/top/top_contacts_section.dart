import 'package:flokk/_internal/components/fading_index_stack.dart';
import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styled_components/styled_tab_bar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/dashboard_page/top/small_contact_card.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flokk/views/empty_states/placeholder_top_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopContactsSection extends StatefulWidget {
  const TopContactsSection({Key? key}) : super(key: key);

  @override
  _TopContactsSectionState createState() => _TopContactsSectionState();
}

class _TopContactsSectionState extends State<TopContactsSection> {
  void _handleTabPressed(int index) {
    context.read<AppModel>().dashContactsSection =
        index == 0 ? DashboardContactsSectionType.Favorites : DashboardContactsSectionType.RecentlyActive;
    context.read<AppModel>().scheduleSave();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    ContactsModel contactsModel = context.watch();

    /// Bind to section type on AppModel
    var sectionType = context.select<AppModel, DashboardContactsSectionType>((model) => model.dashContactsSection);
    int tabIndex = 0;
    if (sectionType == DashboardContactsSectionType.RecentlyActive) {
      tabIndex = 1;
    }

    /// Use a layout builder so we can size this view responsively when the panel slides out
    return LayoutBuilder(
      builder: (_, constraints) {
        List<ContactData> contacts = sectionType == DashboardContactsSectionType.Favorites
            ? contactsModel.starred
            : contactsModel.mostRecentSocialContacts.map((e) => e.contact).toList();
        double tabWidth = constraints.maxWidth < PageBreaks.LargePhone ? 240 : 280;
        TextStyle headerStyle = TextStyles.T1;
        double cardHeight = 208;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OneLineText("CONTACTS", style: headerStyle.textColor(theme.accent1Darker)).flexible(),
                StyledTabBar(
                  index: tabIndex,
                  sections: ["Favorites", "Recently Active"],
                  onTabPressed: _handleTabPressed,
                ).constrained(maxWidth: tabWidth, animate: true).animate(Durations.medium, Curves.easeOut),
              ],
            ).padding(horizontal: Insets.lGutter),
            VSpace(Insets.sm),

            /// Fading Stack to hold the 2 lists
            FadingIndexedStack(
              index: tabIndex,
              children: [
                _ContactCardList(this, contacts: contacts, placeholder: TopContactsPlaceholder()),
                _ContactCardList(this, contacts: contacts, placeholder: TopContactsPlaceholder(isRecent: true)),
              ],
            ).height(cardHeight + Insets.m * 2),
          ],
        );
      },
    );
  }
}

class _ContactCardList extends StatelessWidget {
  final _TopContactsSectionState state;
  final List<ContactData> contacts;
  final Widget placeholder;

  const _ContactCardList(this.state, {Key? key, this.contacts = const<ContactData>[], required this.placeholder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Layout content
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: Insets.l, vertical: Insets.m);
    // Placeholder content-box
    return PlaceholderContentSwitcher(
        hasContent: () => contacts.isNotEmpty,
        placeholder: placeholder,
        placeholderPadding: padding,
        content: StyledListView(
          axis: Axis.horizontal,
          itemCount: contacts.length,
          itemExtent: SmallContactCard.cardWidth,
          padding: EdgeInsets.only(left: Insets.l),
          scrollbarPadding: EdgeInsets.only(left: Insets.m, right: Insets.sm),
          barSize: 6,
          itemBuilder: (_, index) => SmallContactCard(contacts[index]),
          //itemExtent: itemSize,
        ));
  }
}
