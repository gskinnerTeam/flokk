import 'package:flutter/material.dart';

class ListenableBuilder extends AnimatedBuilder {
  ListenableBuilder({
    Key key,
    @required Listenable listenable,
    @required TransitionBuilder builder,
    Widget child,
  }) : super(key: key, animation: listenable, builder: builder, child: child);
}
