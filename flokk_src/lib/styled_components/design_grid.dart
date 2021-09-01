import 'package:flokk/_internal/components/design_grid_overlay.dart';
import 'package:flokk/styles.dart';
import 'package:flutter/material.dart';

class StyledDesignGrid extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final bool isEnabled;

  const StyledDesignGrid(
      {Key? key,
      required this.child,
      this.alignment = Alignment.center,
      this.isEnabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesignGridOverlay(
        alignment: alignment,
        isEnabled: isEnabled,
        grids: [
          GridLayout(
            breakPt: PageBreaks.TabletPortrait,
            gutters: EdgeInsets.only(left: 48, right: 0),
            numCols: 6,
            padding: Insets.lGutter,
          ),
          GridLayout(
            breakPt: PageBreaks.TabletLandscape,
            gutters: EdgeInsets.only(left: Sizes.sideBarSm),
            numCols: 8,
            padding: Insets.lGutter,
          ),
          GridLayout(
            breakPt: PageBreaks.Desktop,
            gutters: EdgeInsets.only(left: Sizes.sideBarMed),
            numCols: 12,
            padding: Insets.lGutter,
          ),
          GridLayout(
            breakPt: double.infinity,
            gutters: EdgeInsets.only(left: Sizes.sideBarLg),
            numCols: 12,
            padding: Insets.lGutter,
          ),
        ],
        child: child);
  }
}
