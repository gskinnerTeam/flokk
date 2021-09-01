import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabbedListView extends StatelessWidget {
  final List<Widget> list1;
  final String list1Title;

  final List<Widget> list2;
  final String list2Title;

  final Widget? list1Placeholder;
  final Widget? list2Placeholder;
  final AssetImage list1Icon;
  final AssetImage list2Icon;

  final void Function(int)? onTabPressed;

  final int index;

  const TabbedListView(
      {Key? key,
      required this.list1,
      required this.list1Title,
      required this.list2,
      required this.list2Title,
      this.list1Placeholder,
      this.list2Placeholder,
      this.index = 0,
      this.onTabPressed,
      required this.list1Icon,
      required this.list2Icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    double barHeight = 40;

    ShapeDecoration buildTabDec(bool isBg) {
      return ShapeDecoration(
        shape: TabBorder(selectedTab: isBg ? -1 : index, barHeight: barHeight),
        color:
            isBg ? theme.surface : ColorUtils.blend(theme.bg1, theme.bg2, .35),
        shadows: isBg ? Shadows.m(theme.accent1) : null,
      );
    }

    bool firstSelected = index == 0;

    return Stack(
      children: [
        /// Tab Bg
        Container(
            decoration: buildTabDec(true),
            foregroundDecoration: buildTabDec(false)),

        /// Top Row of Btns
        Row(
          children: [
            Container(
              child: _TransparentTabBtn(
                title: list1Title,
                icon: list1Icon,
                isSelected: firstSelected,
                height: barHeight,
                type: SocialActivityType.Git,
                onPressed: () => onTabPressed?.call(0),
              ),
            ).expanded(),
            Container(
              child: _TransparentTabBtn(
                title: list2Title,
                icon: list2Icon,
                isSelected: !firstSelected,
                height: barHeight,
                type: SocialActivityType.Twitter,
                onPressed: () => onTabPressed?.call(1),
              ),
            ).expanded(),
          ],
        ).height(barHeight),

        /// Content
        Container(
          child: Container(
            margin: EdgeInsets.all(Insets.l)
                .copyWith(right: Insets.m, top: Insets.m * 1.5),
            child: PlaceholderContentSwitcher(
              hasContent: () =>
                  firstSelected ? list1.isNotEmpty : list2.isNotEmpty,
              placeholderPadding: EdgeInsets.only(right: Insets.m),
              placeholder:
                  (firstSelected ? list1Placeholder : list2Placeholder) ??
                      Container(),
              content: StyledListView(
                itemCount: firstSelected ? list1.length : list2.length,
                itemBuilder: (_, i) => firstSelected ? list1[i] : list2[i],
              ),
            ),
          ),
        ).positioned(top: barHeight, bottom: 0, left: 0, right: 0),
      ],
    );
  }
}

class _TransparentTabBtn extends StatelessWidget {
  final bool isSelected;
  final SocialActivityType type;
  final VoidCallback? onPressed;
  final double height;
  final String title;
  final AssetImage icon;

  const _TransparentTabBtn(
      {Key? key,
      this.isSelected = false,
      required this.type,
      this.onPressed,
      this.height = 0,
      this.title = "",
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    Color color = isSelected ? theme.accent1Darker : theme.grey;
    TextStyle titleStyle = TextStyles.T2.textColor(color);
    return BaseStyledBtn(
      contentPadding: EdgeInsets.zero,
      bgColor: Colors.transparent,
      downColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onPressed: isSelected ? null : onPressed,
      child: Row(
        children: [
          HSpace(Insets.m * 1.5),
          StyledImageIcon(icon, color: color, size: 26),
          HSpace(Insets.sm),
          OneLineText(title, style: titleStyle).flexible(),
        ],
      ),
    ).height(height);
  }
}

class TabBorder extends ShapeBorder {
  final int selectedTab;
  final double barHeight;

  TabBorder({this.selectedTab = -1, this.barHeight = 0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var radius = Radius.circular(8);

    void drawBody(Path p) {
      Rect tabRect = Rect.fromLTWH(
          rect.left, rect.top + barHeight, rect.width, rect.height - barHeight);
      p.addRRect(RRect.fromRectAndCorners(tabRect,
          topLeft: Radius.zero,
          bottomLeft: radius,
          topRight: Radius.zero,
          bottomRight: radius));
    }

    void drawTab(Path p, bool rightSide) {
      double xPos = rightSide ? rect.width * .5 : 0;
      Rect tabRect =
          Rect.fromLTWH(rect.left + xPos, rect.top, rect.width * .5, barHeight);
      p.addRRect(RRect.fromRectAndCorners(tabRect,
          topLeft: radius,
          bottomLeft: Radius.zero,
          topRight: radius,
          bottomRight: Radius.zero));
    }

    //Bg mode draws 2 tabs and a body section. Otherwise, just the un-selected tab is drawn.
    bool bgMode = selectedTab == -1;
    Path path = Path();
    //Draw Left side?
    if (bgMode || selectedTab == 1) {
      drawTab(path, false);
    }
    //Draw Right Side?
    if (bgMode || selectedTab == 0) {
      drawTab(path, true);
    }
    if (bgMode) {
      drawBody(path);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
