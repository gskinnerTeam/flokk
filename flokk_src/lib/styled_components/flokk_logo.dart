import 'package:flutter/material.dart';

class FlokkLogo extends StatelessWidget {
  final double size;
  final Color color;

  const FlokkLogo(this.size, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/flokk-logo.png", color: color, height: size);
  }
}

class FlokkSidebarLogo extends StatelessWidget {
  final bool skinny;

  const FlokkSidebarLogo(this.skinny, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: skinny ? 140 : 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset("assets/images/sidebar-logo.png", width: skinny ? 140 : 160, filterQuality: FilterQuality.high),
          if (!skinny) ...{
            Positioned(
              left: 160,
              top: 13,
              child: Image.asset("assets/images/sidebar-bg.png", width: 84, filterQuality: FilterQuality.high),
            ),
          },
        ],
      ),
    );
  }
}
