import 'package:dotted_border/dotted_border.dart';
import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/build_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flokk/views/main_scaffold/main_side_menu.dart';
import 'package:flutter/material.dart';

class MainMenuBtn extends StatefulWidget {
  final AssetImage icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;
  final double iconSize;
  final bool compact;
  final bool transparent;
  final double height;
  final PageType pageType;
  final bool dottedBorder;

  MainMenuBtn(this.icon, this.label,
      {Key? key,
      this.onPressed,
      this.isSelected = false,
      this.iconSize = 26,
      this.compact = false,
      this.transparent = true,
      this.height = 60,
      this.pageType = PageType.None, this.dottedBorder = false})
      : super(key: key);

  @override
  MainMenuBtnState createState() => MainMenuBtnState();
}

class MainMenuBtnState extends State<MainMenuBtn> {
  @override
  Widget build(BuildContext context) {
    /// If we have a pageType, send a notification to the parent menu, so it know the position of each btn, and can position it's current-page indicator
    if (widget.pageType != PageType.None) {
      Future.delayed(1.milliseconds, () {
        Offset o = BuildUtils.getOffsetFromContext(context) ?? Offset.zero;
        MainMenuOffsetNotification(widget.pageType, o).dispatch(context);
      });
    }

    /// Create the Icon / Text Row that animates opacity when selected and hides text when compactMode = true
    TextStyle btnStyle = TextStyles.Btn;
    Widget btnContents = Row(
      mainAxisAlignment: widget.compact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: <Widget>[
        if (!widget.compact) HSpace(Insets.l),
        Padding(
          padding: EdgeInsets.all(2.0),
          child: StyledImageIcon(widget.icon, size: widget.iconSize - 4.0, color: Colors.white),
        ),
        if (!widget.compact)... {
          HSpace(Insets.l * .5),
          OneLineText(widget.label.toUpperCase(), style: btnStyle).flexible()
        }
      ],
    ).height(widget.height).opacity(widget.isSelected ? 1 : .8, animate: true).animate(.3.seconds, Curves.easeOut);


    //Wrap btn in a border... maybe
    btnContents = widget.dottedBorder? DottedBorder(
        dashPattern: [3, 5],
        color: Colors.white.withOpacity(.7),
        borderType: widget.compact? BorderType.Circle : BorderType.RRect,
        radius: Corners.s8Radius,
        child: Center(child: btnContents)) : btnContents;

    /// Wrap contents in a btn
    return RawMaterialButton(
        textStyle: (widget.isSelected ? TextStyles.BtnSelected : TextStyles.Btn).textColor(Colors.white),
        fillColor: Colors.transparent,
        highlightColor: Colors.white.withOpacity(.1),
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: widget.compact ? CircleBorder() : RoundedRectangleBorder(borderRadius: Corners.s8Border),
        onPressed: widget.onPressed,
        child: btnContents);

  }
}
