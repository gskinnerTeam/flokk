import 'dart:math';

import 'package:flokk/_internal/components/listenable_builder.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/scrolling/styled_horizontal_scroll_view.dart';
import 'package:flokk/styled_components/styled_group_label.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/search/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchQueryRow extends StatelessWidget {
  final SearchBarState state;

  const SearchQueryRow(this.state, {Key? key}) : super(key: key);

  double calcTagWidth(String tag) {
    //Calculate all padding in the row (searchIcon + padding + closeIcon + padding)
    double tagPadding = 30 + Insets.m + 24 + Insets.m;
    //Return size of text + padding
    return StringUtils.measure(tag.toUpperCase(), TextStyles.Footnote.letterSpace(0)).width + tagPadding;
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return LayoutBuilder(
      builder: (_, constraints) {
        //Bind to search engine for results
        return ListenableBuilder(
            listenable: state.tmpSearch,
            builder: (_, __) {
              // Calculate the width of the text input based off of the width of the search bar
              double contentWidth = constraints.maxWidth - Insets.l + Insets.m;
              // Remove size of the close and search icons (in mobile mode, they are combined)
              double barQueryWidth = max(0, contentWidth - (Sizes.iconMed + Insets.l));
              if (state.widget.narrowMode == false) {
                barQueryWidth -= (Sizes.iconMed + Insets.m * 1.5);
              }
              //Subtract widths of tags and contacts, to get the max size for text input
              double barTextFieldWidth = barQueryWidth;
              state.tmpSearch.tagList.forEach((t) => barTextFieldWidth -= calcTagWidth(t));
              state.tmpSearch.filterContactList.forEach((fc) => barTextFieldWidth -= calcTagWidth(fc));
              //Enforce min-size of 200px for search input
              barTextFieldWidth = max(200, barTextFieldWidth);

              return Row(
                children: [
                  HSpace(Insets.l),
                  if (state.widget.narrowMode == false) ...{
                    _SearchIconBtn(state.handleSearchIconPressed),
                    HSpace(Insets.m),
                  },
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: barQueryWidth),
                    child: StyledHorizontalScrollView(
                      autoScrollDuration: Durations.fast,
                      autoScrollCurve: Curves.easeOut,
                      child: Row(
                        children: <Widget>[
                          for (var tag in state.tmpSearch.tagList) ...{
                            StyledGroupLabel(
                                icon: StyledIcons.label,
                                text: tag,
                                onClose: () => state.handleRemoveTag(tag)).padding(right: Insets.m),
                          },
                          for (var filterContact in state.tmpSearch.filterContactList) ...{
                            StyledGroupLabel(
                                icon: StyledIcons.user,
                                text: filterContact,
                                onClose: () => state.handleRemoveFilterContact(filterContact)).padding(right: Insets.m),
                          },
                          Container(
                            constraints: BoxConstraints(maxWidth: barTextFieldWidth),
                            child: StyledSearchTextInput(
                              contentPadding: EdgeInsets.all(Insets.m * 1.25 - 0.5).copyWith(left: 0),
                              hintText: state.widget.narrowMode ? "" : "Search for contacts",
                              key: state.textKey,
                              onChanged: state.handleSearchChanged,
                              // Disabled because this callback has different behavior on web for some reason,
                              // the hook is now in the states _handleRawKeyPressed method
                              //onFieldSubmitted: (s) => state.handleSearchSubmitted(),
                              onEditingCancel: state.cancel,
                              onFocusChanged: state.handleFocusChanged,
                              onFocusCreated: state.handleTextFocusCreated,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.hasQuery) ...{
                    ColorShiftIconBtn(
                      StyledIcons.closeLarge,
                      padding: EdgeInsets.zero,
                      size: 16,
                      minHeight: 0,
                      minWidth: 0,
                      color: theme.grey,
                      onPressed: state.clearSearch,
                    ),
                  } else if (state.widget.narrowMode) ...{
                    _SearchIconBtn(state.handleSearchIconPressed),
                  },
                  HSpace(Insets.m),
                ],
              );
            });
      },
    );
  }
}

class _SearchIconBtn extends StatelessWidget {
  final void Function() onPressed;

  const _SearchIconBtn(this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return StyledImageIcon(
      StyledIcons.search,
      size: Sizes.iconMed,
      color: theme.accent1Darker,
    ).clickable(onPressed, opaque: true);
  }
}
