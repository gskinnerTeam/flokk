import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/globals.dart';
import 'package:flokk/styled_components/buttons/ok_cancel_btn_row.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<dynamic> show(Widget child, [BuildContext? context]) async {
    return await (context != null ? Navigator.of(context) : AppGlobals.nav)
        ?.push(
      StyledDialogRoute(
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(child: child);
        },
      ),
    );
    /*return await showDialog(
      context: context ?? MainViewContext.value,
      builder: (context) => child,
    );*/
  }
}

class StyledDialog extends StatelessWidget {
  final Widget? child;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius borderRadius;
  final Color? bgColor;
  final bool shrinkWrap;

  const StyledDialog({
    Key? key,
    this.child,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.padding,
    this.margin,
    this.bgColor,
    this.borderRadius = Corners.s8Border,
    this.shrinkWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();

    Widget innerContent = Container(
      padding: padding ?? EdgeInsets.all(Insets.lGutter),
      color: bgColor ?? theme.surface,
      child: child,
    );

    if (shrinkWrap) {
      innerContent =
          IntrinsicWidth(child: IntrinsicHeight(child: innerContent));
    }

    return FocusTraversalGroup(
      child: Container(
        margin: margin ?? EdgeInsets.all(Insets.lGutter * 2),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 280.0,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: SingleChildScrollView(
              physics: StyledScrollPhysics(),
              child: Material(
                  type: MaterialType.transparency, child: innerContent),
            ),
          ),
        ),
      ),
    );
  }
}

class OkCancelDialog extends StatelessWidget {
  final VoidCallback? onOkPressed;
  final VoidCallback? onCancelPressed;
  final String? okLabel;
  final String? cancelLabel;
  final String? title;
  final String message;
  final double maxWidth;

  const OkCancelDialog(
      {Key? key,
      this.onOkPressed,
      this.onCancelPressed,
      this.okLabel,
      this.cancelLabel,
      this.title,
      this.message = "",
      this.maxWidth = 500})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    String? titleStr = title;
    return StyledDialog(
      maxWidth: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (titleStr != null) ...[
            Text(titleStr.toUpperCase(),
                style: TextStyles.T1.textColor(theme.accent1Darker)),
            VSpace(Insets.sm * 1.5),
            Container(color: theme.greyWeak.withOpacity(.35), height: 1),
            VSpace(Insets.m * 1.5),
          ],
          Text(message, style: TextStyles.Body1.textHeight(1.5)),
          SizedBox(height: Insets.l),
          OkCancelBtnRow(
            onOkPressed: onOkPressed,
            onCancelPressed: onCancelPressed,
            okLabel: okLabel?.toUpperCase(),
            cancelLabel: cancelLabel?.toUpperCase(),
          )
        ],
      ),
    );
  }
}

class StyledDialogRoute<T> extends PopupRoute<T> {
  StyledDialogRoute({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    String barrierLabel = "",
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    RouteSettings? settings,
  })  : _pageBuilder = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder,
        super(settings: settings);

  final RoutePageBuilder _pageBuilder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Semantics(
      child: _pageBuilder(context, animation, secondaryAnimation),
      scopesRoute: true,
      explicitChildNodes: true,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    RouteTransitionsBuilder? tb = _transitionBuilder;
    if (tb == null) {
      return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
          child: child);
    } // Some default transition
    return tb(context, animation, secondaryAnimation, child);
  }
}
