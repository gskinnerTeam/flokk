import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/clickable_text.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ClickableIconRow extends StatefulWidget {
  final void Function(String)? onPressed;
  final VoidCallback? onEditPressed;
  final AssetImage? icon;
  final String value;
  final String? label;
  final double size;
  final Color? iconColor;
  final String editType;

  const ClickableIconRow(
      {Key? key,
      required this.icon,
      required this.value,
      this.label,
      this.onPressed,
      this.size = 20,
      this.iconColor,
      this.onEditPressed,
      required this.editType})
      : super(key: key);

  @override
  _ClickableIconRowState createState() => _ClickableIconRowState();
}

class _ClickableIconRowState extends State<ClickableIconRow> {
  bool get isMouseOver => _isMouseOver;
  bool _isMouseOver = false;

  set isMouseOver(bool value) => setState(() => _isMouseOver = value);

  void _handleEditPressed() =>
      context.read<MainScaffoldState>().editSelectedContact(widget.editType);
  void _handleCopyPressed() =>
      Clipboard.setData(ClipboardData(text: widget.value));

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    Color overColor = theme.isDark
        ? ColorUtils.shiftHsl(theme.bg1, .2)
        : theme.bg2.withOpacity(.35);
    return MouseRegion(
      onEnter: (_) => isMouseOver = true,
      onExit: (_) => isMouseOver = false,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Corners.s5Border,
          color: isMouseOver ? overColor : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(horizontal: Insets.l, vertical: Insets.m),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.icon != null)
                  StyledImageIcon(widget.icon!,
                      size: widget.size, color: widget.iconColor ?? theme.grey),
                SizedBox(width: Insets.l),
                // Wrap value in ClickableText widget, it will get colored if anyone is listening
                //Text(value),
                ClickableText(widget.value, onPressed: widget.onPressed)
                    .constrained(maxWidth: 300)
                    .flexible(),
                SizedBox(width: Insets.m),
                if (widget.label != null)
                  Text(widget.label!.toUpperCase(),
                          style: TextStyles.Caption.textColor(theme.greyWeak))
                      .translate(offset: Offset(0, 8)),
              ],
            ).padding(right: Insets.l * 1.5),
            if (isMouseOver)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ColorShiftIconBtn(
                        StyledIcons.copy,
                        color: theme.accent1,
                        padding: EdgeInsets.zero,
                        onPressed: _handleCopyPressed,
                      ),
                      ColorShiftIconBtn(
                        StyledIcons.edit,
                        color: theme.accent1,
                        padding: EdgeInsets.zero,
                        onPressed: _handleEditPressed,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

typedef Widget SeparatorBuilder();

class MultilineClickableIconRow extends StatelessWidget {
  final void Function(String)? onPressed;
  final AssetImage? icon;
  final List<Tuple2<String, String>> rows;
  final SeparatorBuilder? separator;
  final double size;
  final Color? iconColor;
  final String editType;

  const MultilineClickableIconRow({
    Key? key,
    this.icon,
    this.rows = const <Tuple2<String, String>>[],
    this.onPressed,
    this.separator,
    this.size = 20,
    this.iconColor,
    required this.editType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> kids = [];
    for (var i = 0; i < rows.length; i++) {
      kids.add(
        ClickableIconRow(

            /// Only show icon for the first row
            icon: i == 0 ? icon : null,
            onPressed: onPressed,
            editType: editType,
            value: rows[i].item1,
            label: rows[i].item2,
            size: size,
            iconColor: iconColor),
      );
    }
    return SeparatedColumn(children: kids, separatorBuilder: separator);
  }
}
