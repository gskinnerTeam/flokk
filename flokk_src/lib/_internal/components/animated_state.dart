import 'package:flutter/material.dart';

class AnimatedTextSpike extends StatefulWidget {
  @override
  _AnimatedTextSpikeState createState() => _AnimatedTextSpikeState();
}

class _AnimatedTextSpikeState extends AnimatedState<AnimatedTextSpike> {
  @override
  void initAnimation() => animation = createAnim(seconds: 4)..forward();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value,
      child: GestureDetector(
        onTap: () => animation.forward(from: 0),
        child: Text("Hello Fade:"),
      ),
    );
  }
}

abstract class AnimatedState<T> extends State
    with SingleTickerProviderStateMixin {
  late AnimationController animation;

  AnimationController createAnim(
      {double lowerBound = 0, double upperBound = 1, double seconds = .2}) {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (seconds * 1000).round()),
      lowerBound: lowerBound,
      upperBound: upperBound,
    )..addListener(() => setState(() {}));
  }

  void initAnimation() => animation = createAnim();

  @override
  void initState() {
    initAnimation();
    super.initState();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context);
}
