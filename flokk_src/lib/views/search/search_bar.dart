import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flokk/views/search/search_bar_view.dart';
import 'package:flokk/views/search/search_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  final void Function(ContactData)? onContactPressed;
  final VoidCallback? onSearchSubmitted;
  final double closedHeight;
  final SearchEngine searchEngine;
  final bool narrowMode;
  final double topPadding;

  const SearchBar({
    Key? key,
    required this.searchEngine,
    required this.closedHeight,
    this.onContactPressed,
    this.onSearchSubmitted,
    this.narrowMode = false,
    this.topPadding = 0.0,
  }) : super(key: key);

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final SearchEngine tmpSearch = SearchEngine();
  final GlobalKey<StyledSearchTextInputState> textKey = GlobalKey();
  final GlobalKey<StyledSearchTextInputState> resultsColumnKey = GlobalKey();

  late FocusNode textFocusNode;

  @override
  void initState() {
    RawKeyboard.instance.addListener(_handleRawKeyPressed);
    super.initState();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKeyPressed);
    super.dispose();
  }

  bool _isOpen = false;

  bool get isOpen => _isOpen;

  double _resultsHeight = 0;

  double get resultsHeight => _resultsHeight;

  set resultsHeight(double height) {
    if (_resultsHeight != height) setState(() => _resultsHeight = height);
  }

  bool get hasQuery => tmpSearch.hasQuery;

  set isOpen(bool value) {
    if (_isOpen == value) return;
    // When we open up, make a copy of the current search settings to work with
    if (value == true) {
      // Put the focus in the text field to start
      textFocusNode.requestFocus();
    } else {
      // Unfocus textNode when closing
      textFocusNode.unfocus();
    }
    // Anytime we toggle, make sure the search bar contents match the main searchEngine,
    // this will either revert the un-submitted changes, or do nothing.
    tmpSearch.copyFrom(widget.searchEngine);
    textKey.currentState?.text = tmpSearch.query;

    setState(() => _isOpen = value);
  }

  void cancel() => isOpen = false;

  void handleSearchChanged(String value) => tmpSearch.query = value;

  // Expand when we get focus
  void handleFocusChanged(bool value) {
    if (value || !hasQuery) isOpen = value;
  }

  void handleSearchSubmitted() {
    /// Copy the tmp values back into the main search engine, triggering a rebuild in the main list,
    save();
    widget.onSearchSubmitted?.call();
    isOpen = false;
  }

  void handleContactPressed(ContactData c) async {
    MainScaffoldState scaffold = context.read();
    if (!await scaffold.showDiscardWarningIfNecessary())
      return;
    tmpSearch.addFilterContact(c.nameFull);
    clearQueryString();
    handleSearchSubmitted();
    Future.microtask(() => scaffold.trySetSelectedContact(c));
  }

  void handleTagPressed(String tag) {
    tmpSearch.addTag(tag);
    clearQueryString();
    handleSearchSubmitted();
  }

  void _handleRawKeyPressed(RawKeyEvent evt) {
    if (evt is RawKeyDownEvent) {
      if (evt.logicalKey == LogicalKeyboardKey.keyK && evt.isControlPressed) {
        isOpen = true;
      } else if (textFocusNode.hasFocus && evt.logicalKey == LogicalKeyboardKey.enter) {
        handleSearchSubmitted();
      } else if (textFocusNode.hasFocus && evt.logicalKey == LogicalKeyboardKey.backspace) {
        if (textKey.currentState != null && (textKey.currentState?.text.isEmpty ?? true)) {
          final tl = tmpSearch.tagList;
          final cl = tmpSearch.filterContactList;
          if (cl.isNotEmpty) {
            tmpSearch.removeFilterContact(cl.last);
          } else if (tl.isNotEmpty) {
            tmpSearch.removeTag(tl.last);
          }
        }
      }
    }
  }

  void handleTextFocusCreated(FocusNode node) {
    textFocusNode = node;
  }

  void handleRemoveTag(String tag) {
    tmpSearch.removeTag(tag);
    if (!isOpen) save();
  }

  void handleRemoveFilterContact(String filterContact) {
    tmpSearch.removeFilterContact(filterContact);
    if (!isOpen) save();
  }

  void handleSearchIconPressed() => textFocusNode.requestFocus();

  void clearQueryString() {
    handleSearchChanged("");
    textKey.currentState?.text = "";
    textFocusNode.requestFocus();
  }

  void clearSearch() {
    handleSearchChanged("");
    textKey.currentState?.text = "";
    tmpSearch.clearTags();
    tmpSearch.clearFilterContacts();
    if (!isOpen)
      save();
    else
      textFocusNode.requestFocus();
  }

  void save() {
    widget.searchEngine.copyFrom(tmpSearch);
  }

  @override
  Widget build(BuildContext context) => SearchBarView(this);

}
