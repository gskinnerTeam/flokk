import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/scrolling/styled_scrollview.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_tab_bar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_info/contact_info_details_card.dart';
import 'package:flokk/views/contact_info/contact_info_header_card.dart';
import 'package:flokk/views/contact_info/contact_info_social_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactInfoPanel extends StatefulWidget {
  final VoidCallback? onClosePressed;
  final void Function(String?) onEditPressed;

  const ContactInfoPanel(
      {Key? key, this.onClosePressed, required this.onEditPressed})
      : super(key: key);

  @override
  ContactInfoPanelState createState() => ContactInfoPanelState();
}

class ContactInfoPanelState extends State<ContactInfoPanel> {
  ContactData? _prevContact;
  ValueNotifier<double> opacityNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  void startFadeIfContactsHaveChanged(ContactData c) {
    if (c.id != _prevContact?.id) {
      opacityNotifier.value = 0;
      Future.microtask(() => opacityNotifier.value = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// ///////////////////////////////////////////////
    /// Bind to Provided contact
    AppTheme theme = context.watch();
    return Consumer<ContactData>(
      builder: (_, c, __) {
        // Fade in each time we change contact
        startFadeIfContactsHaveChanged(c);
        //c ??= _prevContact;
        //if (c != null) _prevContact = c;
        _prevContact = c;
        return Column(
          children: <Widget>[
            /// TOP ICON ROW
            Row(children: <Widget>[
              ColorShiftIconBtn(StyledIcons.closeLarge,
                  size: 16,
                  color: theme.grey,
                  onPressed: widget.onClosePressed),
              Spacer(),
              ColorShiftIconBtn(StyledIcons.edit,
                  size: 22,
                  color: theme.accent1Dark,
                  onPressed: () => widget.onEditPressed("")),
            ]).padding(horizontal: Insets.l),

            /// CONTENT STACK

            ValueListenableBuilder<double>(
              valueListenable: opacityNotifier,
              builder: (_, value, __) => AnimatedOpacity(
                opacity: value,
                duration: (value == 0 ? 0 : .35).seconds,
                child: StyledScrollView(
                  child: Column(
                    children: <Widget>[
                      VSpace(2),

                      /// HEADER CARD
                      ContactInfoHeaderCard(),
                      VSpace(Insets.l),

                      /// INFO & SOCIAL
                      _DetailsAndSocialTabView(
                        onEditPressed: widget.onEditPressed,
                      ),
                    ],
                  ).padding(horizontal: Insets.l),
                ),
              ),
            ).flexible(),
          ],
        );
      },
    );
  }
}

class _DetailsAndSocialTabView extends StatefulWidget {
  final void Function(String?) onEditPressed;

  const _DetailsAndSocialTabView({Key? key, required this.onEditPressed})
      : super(key: key);

  @override
  _DetailsAndSocialTabViewState createState() =>
      _DetailsAndSocialTabViewState();
}

class _DetailsAndSocialTabViewState extends State<_DetailsAndSocialTabView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  void _handleTabPressed(int i) {
    AppModel appModel = context.read();
    setState(() => appModel.showSocialTabOnInfoView = i == 1);
  }

  @override
  void initState() {
    //Lookup the starting tab index
    int index = context.read<AppModel>().showSocialTabOnInfoView ? 1 : 0;
    tabController = TabController(length: 2, vsync: this, initialIndex: index);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use .select to bind to the AppModel when showSocialTabOnInfoView changes
    int index =
        context.select<AppModel, bool>((model) => model.showSocialTabOnInfoView)
            ? 1
            : 0;
    return Column(
      children: <Widget>[
        StyledTabBar(
          index: index,
          sections: ["DETAILS", "SOCIAL"],
          onTabPressed: _handleTabPressed,
        ),
        IndexedStack(
          index: index,
          children: <Widget>[
            ContactInfoDetailsCard(),
            ContactInfoSocialCard(),
          ],
        )
      ],
    );
  }
}
