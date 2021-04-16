import 'package:flutter/material.dart';

/*
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetController createState() => _MyWidgetController();
}

class _MyWidgetController extends State<MyWidget> {
  @override
  Widget build(BuildContext context) => _MyWidgetView(this);
}

class _MyWidgetView extends WidgetView<MyWidget, _MyWidgetController> {
  _MyWidgetView(_MyWidgetController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
 */
abstract class WidgetView<T1, T2> extends StatelessWidget {
  final T2 state;

  T1 get widget => (state as State).widget as T1;

  const WidgetView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

abstract class StatelessView<T1> extends StatelessWidget {
  final T1 widget;

  const StatelessView(this.widget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}
