import 'package:collection/collection.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_page/bulk_contact_edit_bar.dart';
import 'package:flokk/views/contact_page/contacts_list_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ContactsListWithHeaders extends StatefulWidget {
  final List<ContactData> contacts;
  final List<ContactData> checkedContacts;
  final ContactData? selectedContact;
  final ContactOrderBy orderBy;
  final bool orderDesc;
  final bool searchMode;
  final bool showHeaders;

  const ContactsListWithHeaders({
    Key? key,
    this.contacts = const <ContactData>[],
    this.orderBy = ContactOrderBy.FirstName,
    this.orderDesc = false,
    this.showHeaders = false,
    this.checkedContacts = const <ContactData>[],
    required this.selectedContact,
    this.searchMode = false,
  }) : super(key: key);

  @override
  _ContactsListWithHeadersState createState() => _ContactsListWithHeadersState();
}

class _ContactsListWithHeadersState extends State<ContactsListWithHeaders> {
  bool orderDesc = false;

  List<ContactData> get checked => widget.checkedContacts;

  bool _getIsChecked(String id) {
    ContactData? c = widget.checkedContacts.firstWhereOrNull((_c) => _c.id == id);
    return c != null;
  }

  Tuple2<List<ContactData>, int> getSortedContactsWithFavoriteCount() {
    List<ContactData> starred = widget.contacts.toList()..removeWhere((element) => !element.isStarred);
    int starCount = starred.length;
    List<ContactData> nonStarred = widget.contacts.toList()..removeWhere((element) => element.isStarred);
    return Tuple2(starred..addAll({...nonStarred}), starCount);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return LayoutBuilder(
      builder: (_, constraints) {
        Tuple2<List<ContactData>, int> contactsWithFavCount = getSortedContactsWithFavoriteCount();
        List<ContactData> contacts = contactsWithFavCount.item1;
        int favCount = contactsWithFavCount.item2;
        int itemCount = contacts.length + 1;
        // When not in search, if some of the contacts are favorited but not all then add another header for them
        if (!widget.searchMode && favCount != 0 && favCount != contacts.length)
          itemCount += 1;

        return Stack(
          children: <Widget>[
            /// ////////////////////////////////////////
            /// LIST / HEADER COLUMN
            Column(
              children: <Widget>[
                /// Header: Pass an empty contact, the renderer will switch to header mode
                ContactsListRow(null, parentWidth: constraints.maxWidth)
                    .constrained(height: 48)
                    .padding(right: Insets.lGutter - Insets.sm),

                /// List
                StyledListView(
                  itemExtent: 78,
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    /// Inject 1 or 2 header rows into the results
                    bool isFirstHeader = i == 0;
                    bool isSecondHeader = i == favCount + 1 && favCount != 0;
                    if (isFirstHeader || (isSecondHeader && !widget.searchMode)) {
                      String headerText = "SEARCH RESULTS";
                      int count = contacts.length;
                      if (!widget.searchMode) {
                        bool isFavorite = i == 0 && favCount > 0;
                        headerText = isFavorite ? "FAVORITE CONTACTS" : "OTHER CONTACTS";
                        count = isFavorite ? favCount : contacts.length - favCount;
                      }

                      /// Header text
                      return Container(
                        child: Text("$headerText ($count)", style: TextStyles.T1.textColor(theme.accent1Dark)),
                        alignment: Alignment.bottomLeft,
                        margin: EdgeInsets.only(bottom: Insets.l + 4),
                      );
                    }
                    // Regular Row
                    else {
                      //Because the list is 1-2 items longer
                      int offset = 1;
                      if (!widget.searchMode && i > favCount && favCount != 0)
                        ++offset;
                      ContactData c = contacts[i - offset];
                      return ContactsListRow(
                        c,
                        key: ValueKey(c.id),
                        // Pass our width into the renderers as an optimization, so they don't need to calculate their own
                        parentWidth: constraints.maxWidth,
                        isSelected: widget.selectedContact != null && c.id == widget.selectedContact!.id,
                        isChecked: _getIsChecked(c.id),
                      );
                    }
                  },
                ).expanded(),
              ],
            ),

            /// ////////////////////////////////////////
            /// BULK CONTROLS
            BulkContactEditBar(
              checked: checked,
              all: context.read<ContactsModel>().allContacts,
              onCheckChanged: () => setState(() {}),
            )
                .opacity(checked.isEmpty ? 0 : 1, animate: true)
                .scale(all: checked.isEmpty ? .98 : 1, animate: true)
                .animate(.1.seconds, Curves.easeOut)
          ],
        );
      },
    );
  }
}
