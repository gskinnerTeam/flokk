import 'package:flutter/material.dart';
import 'package:time/time.dart';

class DelayedBuilder extends StatefulWidget {
  final WidgetBuilder firstBuilder;
  final WidgetBuilder secondBuilder;
  final double delay;

  const DelayedBuilder({Key key, this.firstBuilder, this.secondBuilder, this.delay}) : super(key: key);

  @override
  _DelayedBuilderState createState() => _DelayedBuilderState();
}

class _DelayedBuilderState extends State<DelayedBuilder> {
  bool show = false;
  bool initComplete = false;

  @override
  void initState() {
    Future<void>.delayed((widget.delay ?? 0).milliseconds).then((value) {
      if (!mounted) return;
      return setState(() => show = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => !show ? widget.firstBuilder(context) : widget.secondBuilder(context);
}
