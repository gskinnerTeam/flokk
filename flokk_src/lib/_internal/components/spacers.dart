import 'package:flutter/material.dart';

class VtSpace extends StatelessWidget {
  final double size;

  VtSpace(this.size);

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

class HzSpace extends StatelessWidget {
  final double size;

  HzSpace(this.size);

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}
