import 'package:flokk/app_extensions.dart';
import 'package:flutter/material.dart';

class GridLayout {
  final EdgeInsets gutters;
  final double padding;
  final int numCols;
  final double breakPt;

  GridLayout({this.gutters = EdgeInsets.zero, this.padding = 0, this.numCols = 0, this.breakPt = 0});
}

class DesignGridOverlay extends StatefulWidget {
  final Widget child;

  final Alignment alignment;
  final List<GridLayout> grids;
  final bool isEnabled;

  DesignGridOverlay(
      {Key? key,
      required this.child,
      this.grids = const <GridLayout>[],
      this.isEnabled = true,
      this.alignment = Alignment.center})
      : super(key: key);

  @override
  _DesignGridOverlayState createState() => _DesignGridOverlayState();
}

class _DesignGridOverlayState extends State<DesignGridOverlay> {
  double gridAlpha = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEnabled
        ? Stack(
            children: <Widget>[
              widget.child,
              //Main View
              _DesignGridView(this),
            ],
          )
        : widget.child;
  }

  void handleTap() => setState(() => gridAlpha >= 1 ? gridAlpha = 0 : gridAlpha += .48);
}

class _DesignGridView extends StatelessWidget {
  final _DesignGridOverlayState state;

  const _DesignGridView(this.state, {Key? key}) : super(key: key);

  GridLayout getGrid(BuildContext context) {
    for (var i = 0; i < state.widget.grids.length; i++) {
      final List<GridLayout> grids = state.widget.grids;
      if (grids[i].breakPt >= context.widthPx) return grids[i];
    }
    return state.widget.grids.last;
  }

  @override
  Widget build(BuildContext context) {
    final GridLayout grid = getGrid(context);
    final List<Widget> content = [Container(width: grid.padding)];
    final int numCols = grid.numCols;
    for (var i = numCols; i-- > 0;) {
      content.add(
          Flexible(child: Container(color: Colors.red.withOpacity(state.gridAlpha * .4), height: double.infinity)));
      content.add(Container(width: grid.padding));
    }
    print("CurrentBreak: ${grid.breakPt}");
    return Stack(children: [
      if (state.gridAlpha > 0)
        IgnorePointer(
          child: Padding(
            padding: grid.gutters,
            child: Row(children: content),
          ),
        ),
      Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("   ${context.widthPx} x ${context.heightPx}   ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            Text(
                "   ${(context.widthInches).toStringAsPrecision(3)}'' x ${(context.heightInches).toStringAsPrecision(3)}''   ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ).padding(all: 4),
      )
          .gestures(
            onTapUp: (d) => state.handleTap(),
            behavior: HitTestBehavior.opaque,
          )
          .alignment(state.widget.alignment),
    ]);
  }
}
