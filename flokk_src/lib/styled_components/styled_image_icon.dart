import 'package:flokk/styles.dart';
import 'package:flutter/material.dart';

//TODO SB:
// * Wherever possible allow it to fallback to the default size.
// * If you find yourself adding similar hardcoded values, feel free to add Sizes.iconSm or Sizes.iconLg
// The idea is to remove as many hard-coded icon sizes as possible from the app and localize them.
// If a size is truly one-off, that's fine to stay hardcoded.

class StyledImageIcon extends StatelessWidget {
  final AssetImage image;
  final Color color;
  final double size;

  const StyledImageIcon(this.image,
      {Key? key, this.color = Colors.white, this.size = Sizes.iconMed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImageIcon(image, size: size, color: color);
  }
}
