import 'dart:math';

import 'package:flokk/_internal/components/listenable_builder.dart';
import 'package:flokk/_internal/components/simple_grid.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/build_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/scrolling/styled_scrollview.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_label_pill.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/search/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// SEARCH RESULTS LIST
/// Binds to notifications from the tmpSearchEngine using ListenableBuilder
class SearchResults extends StatelessWidget {
  final SearchBarState state;

  const SearchResults(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return LayoutBuilder(
      builder: (_, constraints) {
        return ListenableBuilder(
          listenable: state.tmpSearch,
          builder: (_, __) {
            //Add a callback hook, so the column can pass us it's size after layout.
            BuildUtils.getFutureSizeFromGlobalKey(state.resultsColumnKey, (size) => state.resultsHeight = size.height);

            int maxResults = 6;
            int colCount = max(1, (constraints.maxWidth / 280).floor()).clamp(1, maxResults);

            /// Create Result Items
            List<ContactData> contacts = state.tmpSearch.hasQuery ? state.tmpSearch.getResults() : <ContactData>[];

            List<String> tags = state.tmpSearch.getTagResults();
            final List<StyledLabelPill> labelPills = tags
                .take(maxResults)
                .map((tag) => StyledLabelPill(tag.toUpperCase(),
                        textStyle: TextStyles.Footnote.textColor(theme.grey).letterSpace(0).textHeight(1.63),
                        borderRadius: Corners.s5, onPressed: () => state.handleTagPressed(tag)))
                .toList();

            final List<_ContactSearchListItem> contactListItems = contacts
                .take(maxResults)
                .map((c) => _ContactSearchListItem(
                      contact: c,
                      onPressed: () => state.handleContactPressed(c),
                    ))
                .toList();

            /// Layout
            return StyledScrollView(
              child: Column(
                key: state.resultsColumnKey,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /// Labels/Tags
                  if (tags.isNotEmpty) ...{
                    _SearchCategory(
                      icon: StyledIcons.label,
                      text: "Labels",
                      child: Wrap(
                        spacing: Insets.m,
                        runSpacing: Insets.sm,
                        children: labelPills,
                      ),
                    ),
                  },
                  /// Contacts / People
                  if (contacts.isNotEmpty) ...{
                    _SearchCategory(
                      icon: StyledIcons.user,
                      text: "Contacts",
                      child: SimpleGrid(
                        colCount: colCount,
                        hSpace: Insets.xl,
                        vSpace: Insets.sm,
                        kidHeight: 48,
                        kids: contactListItems,
                      ),
                    ),
                  },
                  /// Submit Btn
                  if (contacts.length > 6) ...{
                    TransparentTextBtn(
                      "Show More (${contacts.length - 6} results)",
                      bgColor: theme.surface,
                      bigMode: true,
                      onPressed: state.handleSearchSubmitted,
                    ).constrained(width: 220, height: 60).center().padding(top: Insets.l),
                    VSpace(Insets.m * 1.5),
                  },
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactSearchListItem extends StatelessWidget {
  final ContactData contact;
  final VoidCallback? onPressed;

  _ContactSearchListItem({required this.contact, this.onPressed});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return TransparentBtn(
      bgColor: theme.surface,
      onPressed: onPressed,
      bigMode: true,
      child: Container(
        child: Row(
          children: <Widget>[
            StyledUserAvatar(contact: contact, size: 36),
            HSpace(Insets.m * 1.5),
            Text(contact.nameFull, style: TextStyles.H2.textColor(theme.txt)),
          ],
        ),
      ),
    );
  }
}

class _SearchCategory extends StatelessWidget {
  final AssetImage icon;
  final String text;
  final Widget child;

  _SearchCategory({required this.icon, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[_SearchHeading(icon, text), child.padding(horizontal: Insets.xl, top: Insets.m)],
    ).padding(horizontal: Insets.xl, top: Insets.l * 0.9);
  }
}

class _SearchHeading extends StatelessWidget {
  final AssetImage icon;
  final String text;

  _SearchHeading(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    TextStyle txtStyle = TextStyles.T1.size(FontSizes.s16).letterSpace(0.8).textColor(theme.accent1Darker);
    return Row(children: <Widget>[
      StyledImageIcon(icon, color: theme.grey),
      HSpace(Insets.m * 1.5),
      Text(text.toUpperCase(), style: txtStyle),
    ]);
  }
}
