import 'package:flokk/_internal/components/fading_index_stack.dart';
import 'package:flokk/_internal/widget_view.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/styled_components/flokk_logo.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_page/contacts_page.dart';
import 'package:flokk/views/dashboard_page/dashboard_page.dart';
import 'package:flokk/views/main_scaffold/contact_panel.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flokk/views/main_scaffold/main_side_menu.dart';
import 'package:flokk/views/search/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

class MainScaffoldView extends WidgetView<MainScaffold, MainScaffoldState> {
  MainScaffoldView(MainScaffoldState state) : super(state);

  @override
  Widget build(BuildContext context) {
    /// ///////////////////////////////////////////////////////////
    /// Bind to AppModel when selectedContact changes, and provide it to the sub-tree
    ContactData selectedContact = context.select<AppModel, ContactData>((model) => model.selectedContact);

    /// Bind to page-change
    var currentPage = context.select<AppModel, PageType>((value) => value.currentMainPage);

    /// Flutter throws an error when it's forced to close the drawer on resize, so pre-emptively close it
    state.closeScaffoldOnResize();

    /// /////////////////////////////////////////////////
    /// RESPONSIVE LAYOUT LOGIC

    /// Calculate Left Menu Size
    double leftMenuWidth = Sizes.sideBarSm;
    bool skinnyMenuMode = true;
    if (context.widthPx >= PageBreaks.Desktop) {
      leftMenuWidth = Sizes.sideBarLg;
      skinnyMenuMode = false;
    } else if (context.widthPx > PageBreaks.TabletLandscape) {
      leftMenuWidth = Sizes.sideBarMed;
    }

    /// Calculate Right panel size
    double detailsPanelWidth = 400;
    if (context.widthInches > 8) {
      //Panel size gets a little bigger as the screen size grows
      detailsPanelWidth += (context.widthInches - 8) * 12;
    }

    bool isNarrow = context.widthPx < PageBreaks.TabletPortrait;

    /// Calculate Top bar height
    double topBarHeight = 60;
    double topBarPadding = isNarrow ? Insets.m : Insets.l;

    /// Figure out what should be visible, and the size of our viewport
    /// 3 cases: 1) Single Column, 2) LeftMenu + Single Column, 3) LeftMenu + Dual Column
    /// (Dual Column means it can show both ContentArea and EditPanel at the same time)
    bool showPanel = selectedContact != ContactData(); //Contact panel is always shown if a contact is selected
    bool showLeftMenu = !isNarrow; //Whether main menu is shown, or hidden behind hamburger btn
    bool useSingleColumn = context.widthInches < 10; //Whether detail panel fills the entire content area
    bool hideContent = showPanel && useSingleColumn; //If single column + panel, we can hide the content
    double leftContentOffset = showLeftMenu ? leftMenuWidth : Insets.mGutter; //Left position for the main content stack
    double contentRightPos = showPanel ? detailsPanelWidth : 0; //Right position for main content stack

    /// Sometimes we want to skip the layout animations, for example, when we're changing main pages ,
    /// we want the new page to ignore the panel that is sliding out of the view.
    Duration animDuration = state.skipScaffoldAnims ? .01.seconds : .35.seconds;
    state.skipScaffoldAnims = false; // Reset flag so we only skip animations for one build cycle
    if (UniversalPlatform.isWeb && !AppModel.enableAnimationsOnWeb) {
      animDuration = .0.seconds;
    }

    /// /////////////////////////////////////////////////
    /// CONTENT WIDGETS

    /// Edit Panel
    Widget editPanel = ContactPanel(
      key: MainScaffold.sidePanelKey,
      onClosePressed: () => state.trySetSelectedContact(ContactData()),
      contactsModel: state.appModel.contactsModel,
    );
    editPanel = RepaintBoundary(child: editPanel);
    editPanel = FocusTraversalGroup(child: editPanel);

    /// Search Bar
    Widget searchBar = SearchBar(
      key: MainScaffold.searchBarKey,
      closedHeight: topBarHeight - 5,
      narrowMode: !showLeftMenu,
      searchEngine: state.appModel.searchEngine,
      onContactPressed: (c) => state.trySetSelectedContact(c, showSocial: false),
      onSearchSubmitted: state.handleSearchSubmit,
    );
    searchBar = RepaintBoundary(child: searchBar);
    searchBar = FocusTraversalGroup(child: searchBar);

    /// Main content page stack
    Widget contentStack = FadingIndexedStack(
      index: state.pages.indexOf(currentPage),
      children: <Widget>[
        /// DASHBOARD PAGE
        DashboardPage(
          selectedContact: selectedContact,
        ),

        /// CONTACTS PAGE
        ValueListenableBuilder<List<ContactData>>(
          valueListenable: state.checkedContactsNotifier,
          builder: (_, checkedContacts, __) {
            return ContactsPage(
              //key: MainScaffold.contactPageKey,
              selectedContact: selectedContact,
              checkedContacts: checkedContacts,
              searchEngine: state.appModel.searchEngine,
              //onContactSelected: state.setSelectedContact,
            )
                //Asymmetric padding for the ListView, as we need to leave room in the gutter for the scroll bar
                .padding(left: Insets.lGutter, right: Insets.mGutter);
          },
        ),
      ],
    );
    //contentStack = RepaintBoundary(child: contentStack);
    contentStack = FocusTraversalGroup(child: contentStack);

    /// /////////////////////////////////////////////////
    /// BUILD
    AppTheme theme = context.watch();
    return Provider.value(
      /// Provide the currently selected contact to all views below this
      value: selectedContact,
      child: Scaffold(
        key: MainScaffold.scaffoldKey,

        /// If menu is hidden, pass it to the .drawer property of scaffold.
        /// Assign a max width since it will be unconstrained in overlay mode and we don't want it to fill the entire screen.
        drawer: showLeftMenu
            ? null
            : MainSideMenu(
                onPageSelected: state.trySetCurrentPage,
                onAddNewPressed: state.addNew,
              ).constrained(maxWidth: Sizes.sideBarLg),
        body:
            //Main App Bg
            StyledContainer(
          theme.bg1,
          child: Stack(
            children: <Widget>[
              Stack(children: <Widget>[
                /// /////////////////////////////////////////////////
                /// INNER CONTENT STACK
                contentStack.padding(top: topBarHeight + topBarPadding),

                /// /////////////////////////////////////////////////
                /// HAMBURGER MENU BTN
                IconButton(icon: Icon(Icons.menu, size: 24, color: theme.accent1), onPressed: state.openMenu)
                    .animatedPanelX(closeX: -50, isClosed: showLeftMenu)
                    .positioned(left: Insets.m, top: Insets.m),

                /// Flokk Logo, Top-Center, only shown in narrow mode
                if (isNarrow) FlokkLogo(40, theme.accent1).alignment(Alignment.topCenter).padding(top: Insets.l),

                /// /////////////////////////////////////////////////
                /// SEARCH BAR
                searchBar.constrained(minHeight: topBarHeight),
              ]) // Shared styling for the entire content area (content + search)
                  .constrained(minWidth: 500)
                  .opacity(hideContent ? 0 : 1, animate: true)
                  .positioned(left: leftContentOffset, right: contentRightPos, bottom: 0, top: 0, animate: true)
                  .animate(animDuration, Curves.easeOut),

              /// /////////////////////////////////////////////////
              /// LEFT MENU
              /// This is defined in the tree unlike the other elements because actually want it to exist twice
              /// This menu may be animating out, while the other version exists in the app drawer
              MainSideMenu(
                onPageSelected: state.trySetCurrentPage,
                onAddNewPressed: state.addNew,
                skinnyMode: skinnyMenuMode,
              )
                  .animatedPanelX(
                    closeX: -leftMenuWidth,
                    // Rely on the animatedPanel to toggle visibility of this when it's hidden. It renders an empty Container() when closed
                    isClosed: !showLeftMenu,
                  ) // Styling, pin to left, fixed width
                  .positioned(left: 0, top: 0, width: leftMenuWidth, bottom: 0, animate: true)
                  .animate(animDuration, Curves.easeOut),

              /// /////////////////////////////////////////////////
              /// RIGHT PANEL - Layout editPanel in 1 of 2 ways, single or double column
              !useSingleColumn

                  /// Dual-column mode: the edit panel is a fixed width
                  ? editPanel
                      .animatedPanelX(
                        duration: animDuration.inMilliseconds * .001,
                        closeX: detailsPanelWidth,
                        isClosed: !showPanel,
                      ) // Styling: Pin to right, using a fixed-width for the panel
                      .positioned(right: 0, width: detailsPanelWidth, top: 0, bottom: 0)
                  //.animate(animDuration, Curves.easeOut)

                  /// Single-column mode: the edit panel is the entire width, minus the left-menu
                  : editPanel
                      .animatedPanelX(
                        closeX: context.widthPx - leftContentOffset,
                        isClosed: !showPanel,
                      ) // Styling: Pin to left instead of right for better window resizing, allow panel to stretch as needed
                      .padding(left: leftContentOffset, animate: true)
                      .animate(animDuration, Curves.easeOut),
            ],
          ),
        ),
      ).gestures(onTap: state.handleBgTapped),
    );
  }
}
