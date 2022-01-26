import 'package:flokk/_internal/components/mouse_hover_builder.dart';
import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/widget_view.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/toggle_favorite_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/social/clickable_social_badges.dart';
import 'package:flokk/styled_components/styled_checkbox.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsListRow extends StatefulWidget {
  final ContactData? contact;
  final bool oddRow;
  final bool lastNameFirst;
  final double? parentWidth;
  final bool isSelected;
  final bool isChecked;
  final bool isStarred;
  final bool showDividers;
  final ShapeBorder shape;

  ContactsListRow(
    this.contact, {
    Key? key,
    this.oddRow = false,
    this.lastNameFirst = false,
    this.parentWidth,
    this.isSelected = false,
    this.isChecked = false,
    this.isStarred = false,
    this.shape = const RoundedRectangleBorder(),
    this.showDividers = true,
  }) : super(key: key);

  @override
  _ContactsListRowState createState() => _ContactsListRowState();
}

class _ContactsListRowState extends State<ContactsListRow> {
  void handleStarPressed() {
    ToggleFavoriteCommand(context).execute(widget.contact!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ContactListCardView(this);
}

class ContactListCardView extends WidgetView<ContactsListRow, _ContactsListRowState> {
  const ContactListCardView(_ContactsListRowState state, {Key? key}) : super(state, key: key);

  ContactData? get contact => widget.contact;

  bool get headerMode => contact == null;

  void _handleRowPressed(BuildContext context) {
    context.read<MainScaffoldState>().trySetSelectedContact(widget.contact);
  }

  void _handleRowChecked(BuildContext context, bool value) {
    context.read<MainScaffoldState>().setCheckedContact(widget.contact!, value);
  }

  @override
  Widget build(BuildContext context) {
    var theme = context.watch<AppTheme>();
    Color bgColor = headerMode ? Colors.transparent : theme.surface;
    if (widget.isSelected) {
      bgColor = theme.greyWeak.withOpacity(.35);
    }

    double width = widget.parentWidth ?? context.widthPx;
    int colCount = 1;
    if (width > 450) colCount = 2;
    if (width > 600) colCount = 3;
    if (width > 1000) colCount = 4;
    if (width > 1300) colCount = 5;

    TextStyle textStyle = !headerMode ? TextStyles.Body1.size(15) : TextStyles.H2.copyWith(color: theme.greyStrong);
    Widget rowText(String value) => OneLineText(value, style: textStyle);

    Widget btn = BaseStyledBtn(
      onPressed: headerMode ? null : () => _handleRowPressed(context),
      bgColor: bgColor,
      downColor: bgColor,
      hoverColor: widget.isSelected ? bgColor : Colors.transparent,
      shape: widget.shape,
      contentPadding: EdgeInsets.zero,
      useBtnText: false,
      child: Stack(
        children: <Widget>[
          /// DIVIDERS - Top and Bottom
          if (!headerMode && widget.showDividers) Container(width: double.infinity, height: 1, color: theme.bg1),
          if (headerMode)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(width: double.infinity, height: 1, color: theme.grey.withOpacity(.6)),
            ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /// Name & ProfilePic
              (headerMode
                      ? rowText("Name")
                      : _ProfileCheckboxWithLabels(
                          contact!,
                          isChecked: state.widget.isChecked,
                          onChecked: (value) => _handleRowChecked(context, value),
                        ))
                  .constrained(minWidth: 300)
                  .expanded(flex: 20 * 100),

              /// Social Media
              _FadingFlexContent(
                isVisible: colCount > 1,
                flex: 10,
                child: headerMode ? rowText("Social") : ClickableSocialBadges(contact!, showTimeSince: false),
              ),

              /// Phone
              _FadingFlexContent(
                child: rowText(headerMode ? "Phone" : contact!.firstPhone),
                flex: 11,
                isVisible: colCount > 2,
              ),

              /// Email
              _FadingFlexContent(
                isVisible: colCount > 3,
                flex: 16,
                child: rowText(headerMode ? "Email" : contact!.firstEmail),
              ),

              /// COMPANY
              _FadingFlexContent(
                isVisible: colCount > 4,
                flex: 16,
                child: rowText(headerMode ? "Job / Company" : contact!.jobCompany),
              ),

              //SizedBox(width: Insets.m),
              /// Star Icon
              if (!headerMode)
                TransparentBtn(
                  bigMode: true,
                  onPressed: state.handleStarPressed,
                  child: StyledImageIcon(
                    widget.contact!.isStarred ? StyledIcons.starFilled : StyledIcons.starEmpty,
                    color: widget.contact!.isStarred ? theme.accent1Dark : theme.greyWeak,
                  ).opacity(headerMode ? 0 : 1),
                )
            ],
          ).padding(
            left: headerMode ? 0 : Insets.m,
            right: Insets.m * 1.5,
            vertical: Insets.sm,
          )
        ],
      ),
    );
    return btn;
  }
}

class _ProfileCheckboxWithLabels extends StatefulWidget {
  final void Function(bool) onChecked;
  final ContactData contact;
  final bool isChecked;

  const _ProfileCheckboxWithLabels(this.contact, {Key? key, required this.onChecked, this.isChecked = false}) : super(key: key);

  @override
  _ProfileCheckboxWithLabelsState createState() => _ProfileCheckboxWithLabelsState();
}

class _ProfileCheckboxWithLabelsState extends State<_ProfileCheckboxWithLabels> {
  @override
  Widget build(BuildContext context) {
    double size = 42;
    return Row(
      children: <Widget>[
        MouseHoverBuilder(
          builder: (_, isHovering) {
            bool showCheckbox = isHovering || widget.isChecked;
            return IndexedStack(
              index: showCheckbox ? 0 : 1,
              children: <Widget>[
                _buildCheckbox(size),
                StyledUserAvatar(size: size, contact: widget.contact),
              ],
            );
          },
        ).gestures(onTapUp: (d) => widget.onChecked(!widget.isChecked), behavior: HitTestBehavior.opaque),
        SizedBox(width: Insets.m),
        OneLineText(widget.contact.nameFull, style: TextStyles.Body1.size(15)).expanded(),
      ],
    );
  }

  Widget _buildCheckbox(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: StyledCheckbox(size: 18, value: widget.isChecked ? StyledCheckboxValue.All : StyledCheckboxValue.None),
    );
  }
}

class _FadingFlexContent extends StatelessWidget {
  final Widget? child;
  final int flex;
  final bool isVisible;
  final bool enableAnimations;

  const _FadingFlexContent({Key? key, this.child, required this.flex, this.isVisible = true, this.enableAnimations = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVisible == false) return Container();
    int targetFlex = 1 + flex * 100;
    if (enableAnimations) {
      return TweenAnimationBuilder<double>(
          curve: !isVisible ? Curves.easeOut : Curves.easeIn,
          tween: Tween<double>(begin: isVisible ? 1 : 0, end: isVisible ? 1 : 0),
          duration: (isVisible ? .5 : .2).seconds,
          builder: (_, value, child) {
            if (value == 0 && !isVisible || child == null) return Container();
            return child.opacity(value).expanded(flex: (targetFlex * value).round());
//
          },
          child: Container(child: child, alignment: Alignment.centerLeft));
    }

    return Container(
      child: child,
      alignment: Alignment.centerLeft,
    ).expanded(flex: targetFlex);
  }
}
