import 'dart:math';

import 'package:flokk/_internal/components/content_underlay.dart';
import 'package:flokk/_internal/widget_view.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/opening_divider.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/search/search_bar.dart';
import 'package:flokk/views/search/search_query_results.dart';
import 'package:flokk/views/search/search_query_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchBarView extends WidgetView<SearchBar, SearchBarState> {
  SearchBarView(SearchBarState state, {Key? key}) : super(state, key: key);

  bool get isOpen => state.isOpen;

  bool _handleKeyPress(FocusNode node, RawKeyEvent evt) {
    if (evt is RawKeyDownEvent) {
      if (evt.logicalKey == LogicalKeyboardKey.escape) {
        state.cancel();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();

    // Fixed content height plus top and bottom padding
    double barHeight = 30 + Insets.m * 1.25 * 2.0;
    double topPadding = state.widget.narrowMode ? Insets.m : Insets.l;
    double leftPadding = state.widget.narrowMode ? 50 : 0; // Move over to not overlay with main-app menu btn
    /// CONTENT UNDERLAY
    Widget underlay = ContentUnderlay(
      isActive: isOpen && state.resultsHeight > 0,
      color: theme.bg1.withOpacity(.7),
    );
    return FocusScope(
      onKey: _handleKeyPress,
      child: Stack(
        children: <Widget>[
          /// Clickable underlay, closes on press
          underlay.gestures(onTap: state.cancel),

          /// Wrap content in an animated card, this will handle open and closing animations
          _AnimatedSearchCard(
            state,
            // Content Column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Search Box
                SearchQueryRow(state),
                // Search Results
                SearchResults(state)
                    // Fade search results out when we're not open
                    .opacity(isOpen ? 1 : 0, animate: true)
                    .animate(Durations.fast, Curves.easeOut)
                    .expanded()
              ],
            ),
          ).padding(left: Insets.lGutter + leftPadding, right: Insets.lGutter, vertical: topPadding),

          /// Animated Search Underline
          if (state.resultsHeight > 0) ...{
            Positioned(
              top: topPadding + barHeight - 6,
              left: Insets.lGutter + leftPadding + Insets.l,
              right: Insets.lGutter + Insets.l,
              child: OpeningDivider(isOpen: isOpen),
            ),
          },
        ],
      ),
    );
  }
}

/// Handles the transition from open and closed, the content is a Column, contains the SearchBox, and SearchResults
class _AnimatedSearchCard extends StatelessWidget {
  final Widget? child;
  final SearchBarState searchBar;

  const _AnimatedSearchCard(this.searchBar, {Key? key, this.child}) : super(key: key);

  bool get isOpen => searchBar.isOpen;

  bool get hasQuery => searchBar.hasQuery;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double openHeight = min(searchBar.widget.closedHeight + searchBar.resultsHeight + 1, 600);
    return StyledContainer(isOpen || hasQuery ? theme.surface : theme.surface.withOpacity(.4),
        height: isOpen ? openHeight : searchBar.widget.closedHeight,
        borderRadius: BorderRadius.circular(6),
        duration: Durations.fast,
        //border: Border.all(color: Colors.grey.withOpacity(isOpen ? .3 : 0)),
        shadows: isOpen || hasQuery ? Shadows.m(theme.accent1Darker) : [],
        child: child);
  }
}
