import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/flokk_logo.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/welcome/animated_bird_splash_clipper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedBirdSplashWidget extends StatefulWidget {
  final Alignment alignment;
  final bool showText;
  final bool showLogo;
  final bool showSpannedView;
  const AnimatedBirdSplashWidget({
    Key key,
    this.alignment,
    this.showText = false,
    this.showLogo = true,
    this.showSpannedView = false,
  }) : super(key: key);

  @override
  _AnimatedBirdSplashState createState() => _AnimatedBirdSplashState();
}

class _AnimatedBirdSplashState extends State<AnimatedBirdSplashWidget>
    with SingleTickerProviderStateMixin {
  GooeyEdge _gooeyEdge;

  AnimationController _animationController;
  double _cloudXOffset = 0.0;

  @override
  void initState() {
    _gooeyEdge = GooeyEdge();
    _animationController = AnimationController(vsync: this);
    _animationController.repeat(
        reverse: true, min: 0.0, max: 1.0, period: 800.milliseconds);
    _animationController.addListener(_tick);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _tick() {
    _gooeyEdge.tick(_animationController.lastElapsedDuration);
    _cloudXOffset += _animationController.velocity * 0.08;
    while (_cloudXOffset > 800.0) {
      _cloudXOffset -= 800.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    String bgImagePath = "assets/images/onboarding-bg.png";
    String cloudImagePath = "assets/images/onboarding-clouds.png";
    String fgImagePath = "assets/images/onboarding-birds.png";

    return Stack(
      children: [
        Flex(
            direction: widget.showSpannedView ? Axis.horizontal : Axis.vertical,
            children: [
              /// Clipped Image Stack
              Expanded(
                flex: 6,
                child: ClipPath(
                  clipper: AnimatedBirdSplashClipper(_gooeyEdge),
                  child: Stack(children: [
                    /// BG
                    _BuildImage(bgImagePath, BoxFit.fill)
                        .positioned(left: 0, top: 0, right: 0, bottom: 0),

                    /// CLOUD 1
                    _BuildImage(cloudImagePath)
                        .translate(offset: Offset(_cloudXOffset, 0))
                        .fractionallySizedBox(heightFactor: 0.4),

                    /// CLOUD2
                    _BuildImage(cloudImagePath)
                        .translate(offset: Offset(-800 + _cloudXOffset, 0))
                        .fractionallySizedBox(heightFactor: 0.4),

                    /// Foreground
                    _BuildImage(fgImagePath, BoxFit.scaleDown).center(),
                  ]),
                )
                    .aspectRatio(aspectRatio: 1.8)
                    .constrained(maxWidth: 700)
                    .padding(
                      horizontal: 40,
                      top: 200,
                      bottom: widget.showSpannedView ? 200 : 64,
                    ),
              ),

              /// Loading Text
              Expanded(
                flex: widget.showSpannedView ? 6 : 1,
                child: Text(
                  "GATHERING YOUR FLOKK...",
                  style: TextStyles.T1.textColor(theme.accent1Darker),
                  textAlign: TextAlign.center,
                ) //Bottom positioned, fades in and out
                    .opacity(widget.showText ? 1 : 0, animate: true)
                    .animate(Durations.slow, Curves.easeOut),
              )
            ]).center(),

        /// Flock Logo
        if (widget.showLogo)
          FlokkLogo(56, Color(0xff116d5a))
              .center()
              .constrained(width: 156, height: 56)
              .alignment(Alignment(-0.84, -0.84)),
      ],
    );
  }

  Widget _BuildImage(String url, [BoxFit fit = BoxFit.fitHeight]) =>
      Image.asset(url, filterQuality: FilterQuality.high, fit: fit);
}
