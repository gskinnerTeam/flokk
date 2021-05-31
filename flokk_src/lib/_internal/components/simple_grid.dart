import 'package:flokk/app_extensions.dart';
import 'package:flutter/material.dart';

class SimpleGrid extends StatelessWidget {
  final double hSpace;
  final double vSpace;
  final int colCount;
  final List<Widget> kids;
  final double kidHeight;
  final CrossAxisAlignment align;

  //TODO SB: Refactor this class to support Hz scrolling
  const SimpleGrid({
    Key? key,
    this.hSpace = 0,
    this.vSpace = 0,
    required this.kids,
    this.colCount = 2,
    this.kidHeight = 40,
    this.align = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Build a bunch of columns in a bunch of rows
    int rowCount = (kids.length / colCount).ceil();
    List<Widget> col = [];
    //Fill each row with items
    int kidIndex = 0;
    for (var i = rowCount; i-- > 0;) {
      List<Widget> row = [];
      for (var i2 = colCount; i2-- > 0;) {
        if (kidIndex <= kids.length - 1) {
          row.add(kids[kidIndex].flexible());
        } else {
          row.add(Container().flexible());
        }
        kidIndex++;
        // Fill gaps with hSpace
        if (i2 > 0) {
          row.add(SizedBox(width: hSpace));
        }
      }
      col.add(Row(children: row).height(kidHeight));
      // Fill gaps with vSpace
      if (i > 0) col.add(SizedBox(height: vSpace));
    }
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: col,
    );
  }
}
