import 'package:flokk/_internal/components/listenable_builder.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/widget_view.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_page/contacts_list_with_headers.dart';
import 'package:flokk/views/empty_states/placeholder_contact_list.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flokk/views/search/search_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsPage extends StatefulWidget {
  final SearchEngine searchEngine;
  final List<ContactData> checkedContacts;
  final ContactData selectedContact;

  const ContactsPage({Key? key, required this.searchEngine, this.checkedContacts = const<ContactData>[], required this.selectedContact}) : super(key: key);

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  Future<void> handleRefreshTriggered() async => await RefreshContactsCommand(context).execute();

  @override
  Widget build(BuildContext context) => _ContactsPageView(this);
}

class _ContactsPageView extends WidgetView<ContactsPage, ContactsPageState> {
  _ContactsPageView(ContactsPageState state) : super(state);

  @override
  Widget build(BuildContext context) {
    context.watch<ContactsModel>();
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(children: <Widget>[
          VSpace(Insets.sm),

          /// Bind to SearchEngine
          ListenableBuilder(
            listenable: widget.searchEngine,
            builder: (_, __) {
              /// Filter active contacts using the search engine provided
              List<ContactData> sorted = widget.searchEngine.getResults();

              /// Wrap content in PlaceholderSwitcher, which will handle empty results
              return PlaceholderContentSwitcher(
                hasContent: () => sorted.isNotEmpty,
                placeholder: ContactListPlaceholder(isSearching: widget.searchEngine.hasQuery),
                showOutline: false,
                placeholderPadding: EdgeInsets.only(top: Insets.m * 1.5, right: Insets.m, bottom: Insets.m),

                /// ContactList
                content: ContactsListWithHeaders(
                  contacts: sorted,
                  // Indicate to page that it should show search-results formatting
                  searchMode: widget.searchEngine.hasQuery,
                  selectedContact: widget.selectedContact,
                  checkedContacts: widget.checkedContacts,
                  orderBy: widget.searchEngine.orderBy,
                  orderDesc: widget.searchEngine.orderDesc,
                ),
              );
            },
          ).expanded(),
          VSpace(Insets.m),
        ]),
      ],
    );
  }
}
