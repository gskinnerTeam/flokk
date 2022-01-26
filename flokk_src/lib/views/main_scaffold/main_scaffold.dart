import 'dart:async';

import 'package:flokk/_internal/components/simple_value_notifier.dart';
import 'package:flokk/_internal/utils/utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/commands/dialogs/show_discard_warning_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/views/contact_page/contacts_page.dart';
import 'package:flokk/views/dashboard_page/dashboard_page.dart';
import 'package:flokk/views/main_scaffold/contact_panel.dart';
import 'package:flokk/views/main_scaffold/main_scaffold_view.dart';
import 'package:flokk/views/search/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PageType { None, Dashboard, ContactsList }

class MainScaffold extends StatefulWidget {
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  static GlobalKey<ContactPanelState> sidePanelKey = GlobalKey();
  static GlobalKey<DashboardPageState> dashboardKey = GlobalKey();
  static GlobalKey<ContactsPageState> contactPageKey = GlobalKey();
  static GlobalKey<SearchBarState> searchBarKey = GlobalKey();

  @override
  MainScaffoldState createState() => MainScaffoldState();
}

/// Handles all button handlers and business logic functions for the MainScaffoldView
/// Also contains any local view state.
class MainScaffoldState extends State<MainScaffold> {
  //Pages
  List<PageType> pages = [
    PageType.Dashboard,
    PageType.ContactsList,
  ];

  SimpleValueNotifier<List<ContactData>> checkedContactsNotifier = SimpleValueNotifier([]);

  late AppModel appModel;

  /// Easily lookup the current state of the SidePanel
  ContactPanelState? get contactsPanel => MainScaffold.sidePanelKey.currentState;

  SearchBarState? get searchBar => MainScaffold.searchBarKey.currentState;

  /// Disable scaffold animations, used when changing pages, so the new page does not animate in
  bool skipScaffoldAnims = false;

  @override
  void initState() {
    /// Get a reference to the app model
    appModel = context.read();

    /// Change current page
    Future.microtask(() => trySetCurrentPage(PageType.Dashboard, false));
    super.initState();
  }

  /// Setting an empty id will trigger the Create User panel to open
  void addNew() async {
    if (!await showDiscardWarningIfNecessary()) return;
    searchBar?.cancel();

    /// FutureUser Case: Need to jump from mainScaffold, into any contact and edit.
    appModel.selectedContact = ContactData();
  }

  void editSelectedContact(String section) => contactsPanel?.showEditView(section);

  //TODO: This should be a command
  /// Attempt to change current page, this might not complete if user is currently editing
  Future<void> trySetCurrentPage(PageType t, [bool refresh = true]) async {
    if (t == appModel.currentMainPage) return;

    // Show a Ok/Cancel dialog if the user has un-saved edits.
    // Exit early if the user chooses to cancel the page change.
    if (!await showDiscardWarningIfNecessary()) return;

    // Change page
    appModel.currentMainPage = t;

    // Close SearchBar if it's open
    searchBar?.cancel();

    //Skip Scaffold animations if the editPanel is currently open, we don't want the new page animating with the closing panel
    if (appModel.selectedContact != null) skipScaffoldAnims = true;

    //Clear any selected contact, causing the editPanel to close
    appModel.selectedContact = null;

    // Clear any checked contacts
    checkedContactsNotifier.value = [];

    //Refresh each time we change pages
    if (refresh) {
      RefreshContactsCommand(context).execute();
    }
  }

  /// Change selected contact, this might not complete if user is currently editing
  Future<void> trySetSelectedContact(ContactData? value, {showSocial = false}) async {
    if (!await showDiscardWarningIfNecessary()) return;
    final currentlySelectedContact = appModel.selectedContact;
    if (value != null && currentlySelectedContact != null) {
      //De-select contact if we selected the currently selected contact
      bool hasSocialChanged = showSocial != appModel.showSocialTabOnInfoView;
      if (!hasSocialChanged && currentlySelectedContact.id == value.id) {
        value = null;
      }
    }
    appModel.selectedContact = value;
    appModel.showSocialTabOnInfoView = showSocial;
    contactsPanel?.showInfoView();
  }

  /// Change checked contacts
  Future<void> setCheckedContact(ContactData contact, bool value) async {
    List<ContactData> checked = checkedContactsNotifier.value;
    if (value) {
      checked.add(contact);
    } else {
      checked.removeWhere((element) => element.id == contact.id);
    }
    checkedContactsNotifier.notify();
  }

  Future<bool> showDiscardWarningIfNecessary() async {
    // If there are no actual changes, no need to bug the user.
    if (!(contactsPanel?.hasUnsavedChanged ?? false)) return true;
    // Ask user if they'd like to discard
    return await ShowDiscardWarningCommand(context).execute();
  }

  // Avoids a layout error thrown by Flutter when scaffold is forced to close while re-sizing the window
  void closeScaffoldOnResize() {
    if (MainScaffold.scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scheduleMicrotask(() => Navigator.pop(context));
    }
  }

  void openMenu() => MainScaffold.scaffoldKey.currentState?.openDrawer();

  void handleBgTapped() {
    Utils.unFocus();
  }

  void handleSearchSubmit() {
    // When a search is submitted, try and navigate to the contactsView
    trySetCurrentPage(PageType.ContactsList);
    // [SB] Hack to try and get more reliable scroll-bar sizing when submitting.
    //TODO: Confirm this bug still exists (scrollbar can stay stuck on, even when there are no results)
    Future.delayed(1000.milliseconds, () => setState(() {}));
  }

  /// Provide this state to all the views below it, enabling child-widgets to request page changes, select a certain contact,
  /// or make other requests on MainScaffold to do something.
  @override
  Widget build(BuildContext context) => Provider.value(
        value: this,
        child: MainScaffoldView(this),
      );

}
