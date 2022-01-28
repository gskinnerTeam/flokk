import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/logout_command.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/flokk_logo.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/light_dark_toggle_switch.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flokk/views/main_scaffold/main_side_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenuOffsetNotification extends Notification {
  final Offset offset;
  final PageType pageType;

  MainMenuOffsetNotification(this.pageType, this.offset);
}

class MainSideMenu extends StatefulWidget {
  final void Function(PageType t)? onPageSelected;
  final VoidCallback? onAddNewPressed;
  final bool skinnyMode;

  const MainSideMenu({Key? key, this.onPageSelected, this.onAddNewPressed, this.skinnyMode = false}) : super(key: key);

  @override
  _MainSideMenuState createState() => _MainSideMenuState();
}

class _MainSideMenuState extends State<MainSideMenu> {

  final Map<PageType, Offset> _menuBtnOffsetsByType = {};
  PageType? _prevPage;

  double get _headerHeight => 106;

  double get _indicatorHeight => 48;

  double get _btnHeight => 60;

  double _indicatorY = 0.0;

  @override
  void initState() {
    //PageType p = PageType.Dashboard;
    Future.delayed(100.milliseconds).then((value) {
      _updateIndicatorState(context.read<AppModel>().currentMainPage);
    });
    super.initState();
  }

  void _handleLogoutPressed() => LogoutCommand(context).execute(doConfirm: true);

  void _handlePageSelected(PageType pageType) => widget.onPageSelected?.call(pageType);

  void _updateIndicatorState(PageType type) {
    if (_menuBtnOffsetsByType.containsKey(type)) {
      Offset o = _menuBtnOffsetsByType[type] ?? Offset.zero;
      setState(() => _indicatorY = o.dy - _headerHeight + _btnHeight * .5 - _indicatorHeight * .5);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    String versionNum = context.select<AppModel, String>((m) => m.version);
    /// Bind to AppModel when currentPage changes
    var currentPage = context.select<AppModel, PageType>((value) => value.currentMainPage);
    if (currentPage != _prevPage) {
      _updateIndicatorState(currentPage);
    }
    _prevPage = currentPage;
    Color bgColor = theme.isDark? ColorUtils.blend(theme.bg1, theme.accent1, .08) : theme.accent1;
    return FocusTraversalGroup(
      child: Container(
        child: Column(
          children: <Widget>[
            /// ////////////////////////////////////////////////////////
            /// HEADER
            Stack(
              children: <Widget>[
                // Background layer, scaled a bit on the Y axis so it under-hangs the menu below
                // This opaque background is only needed when the menu is in the slide-out drawer state
                StyledContainer(theme.bg1).transform(transform: Matrix4.diagonal3Values(1.0, 1.2, 1.0)),

                /// ////////////////////////////////////////////////
                /// Main Flock Logo
                FlokkSidebarLogo(widget.skinnyMode).center(),
                //Text("APP NAME", style: TextStyles.T1).textColor(theme.accent1Dark).center(),
              ],
            ).height(_headerHeight),

            /// ////////////////////////////////////////////////////////
            /// MENU
            Stack(
              children: <Widget>[
                /// Menu-Background
                StyledContainer(bgColor, borderRadius: BorderRadius.only(topRight: Corners.s10Radius)),

                /// Version
                Text("v$versionNum", style: TextStyles.Caption.textColor(Colors.white)).positioned(left: 4, bottom: 4),

                /// ////////////////////////////////////////////////////////
                /// Buttons
                NotificationListener<MainMenuOffsetNotification>(
                    // Listen for [MainMenuOffsetNotification], dispatched from each [MainMenuBtn] that is assigned a pageType.
                    // We use these to position the animated indicator in [_updateIndicatorState]
                    onNotification: (n) {
                      _menuBtnOffsetsByType[n.pageType] = n.offset;
                      return true; // Return true so the notification stops here
                    },
                    child: Column(
                      children: <Widget>[
                        VSpace(Insets.l),

                        /// New Contact Btn
                        MainMenuBtn(StyledIcons.add, "Create Contact",
                            compact: widget.skinnyMode,
                            height: _btnHeight,
                            transparent: false,
                            iconSize: 20,
                            isSelected: true,
                            dottedBorder: true,
                            onPressed: widget.onAddNewPressed),

                        VSpace(Insets.l),

                        /// Dashboard Btn
                        MainMenuBtn(
                          StyledIcons.dashboard,
                          "DASHBOARD",
                          compact: widget.skinnyMode,
                          pageType: PageType.Dashboard,
                          height: _btnHeight,
                          isSelected: currentPage == PageType.Dashboard,
                          onPressed: () => _handlePageSelected(PageType.Dashboard),
                        ),

                        /// Contacts Out Btn
                        MainMenuBtn(
                          StyledIcons.user,
                          "CONTACTS",
                          compact: widget.skinnyMode,
                          pageType: PageType.ContactsList,
                          height: _btnHeight,
                          isSelected: currentPage == PageType.ContactsList,
                          onPressed: () => _handlePageSelected(PageType.ContactsList),
                        ),

                        Spacer(),

                        /// Light / Dark Toggle
                        //Use a row to easily center the Toggle inside the column
                        [
                          LightDarkToggleSwitch(),
                        ].toRow(mainAxisAlignment: MainAxisAlignment.center),

                        VSpace(Insets.m),

                        /// Sign Out Btn
                        TransparentBtn(
                          hoverColor: theme.txt.withOpacity(.05),
                          contentPadding: EdgeInsets.all(Insets.m),
                          child: Text("SIGN OUT", style: TextStyles.Btn.textColor(Colors.white)),
                          onPressed: _handleLogoutPressed,
                          ),

                      ],
                    )).padding(all: Insets.l, bottom: Insets.m).constrained(maxWidth: 280),

                /// Animated line that moves up and down to select the current page
                _AnimatedMenuIndicator(_indicatorY, height: _indicatorHeight)
              ],
            ).flexible(),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMenuIndicator extends StatefulWidget {
  final double indicatorY;
  final double width;
  final double height;

  _AnimatedMenuIndicator(this.indicatorY, {this.width = 6, this.height = 24});

  @override
  _AnimatedMenuIndicatorState createState() => _AnimatedMenuIndicatorState();
}

class _AnimatedMenuIndicatorState extends State<_AnimatedMenuIndicator> {
  final double _duration = .5;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return AnimatedContainer(
        duration: _duration.seconds,
        curve: Curves.easeOutBack,
        width: widget.width,
        height: widget.height,
        child: StyledContainer(theme.surface),
        margin: EdgeInsets.only(top: widget.indicatorY));
  }
}
