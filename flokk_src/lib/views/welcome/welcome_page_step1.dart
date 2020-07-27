import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/primary_btn.dart';
import 'package:flokk/styled_components/flokk_logo.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/welcome/animated_bird_splash.dart';
import 'package:flokk/views/welcome/welcome_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePageStep1 extends StatelessWidget {
  final bool singleColumnMode;

  const WelcomePageStep1({Key key, this.singleColumnMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    WelcomePageState state = context.watch();
    TextStyle bodyTxtStyle =
        TextStyles.Body1.textColor(Color(0xfff1f7f0)).textHeight(1.6);
    return SeparatedColumn(
      separatorBuilder: () => SizedBox(height: Insets.l),
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (singleColumnMode) FlokkLogo(24, Colors.white).center(),
        if (singleColumnMode)
          AnimatedBirdSplashWidget(
                  alignment: Alignment.bottomCenter, showLogo: false)
              .padding(all: Insets.m * 1.5)
              .height((context.heightPx - (state.isDuo ? 170 : 0)) * .25),
        [
          Text(
            "Welcome to Flokk Contacts",
            style:
                TextStyles.CalloutFocus.bold.size(24).textColor(Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            "Flokk is a modern Contacts manager that integrates with your connections on Twitter, GitHub and Microsoft Graph.",
            style: bodyTxtStyle,
            textAlign: TextAlign.center,
          ).padding(vertical: Insets.l),
          Text(
            "To get started, you will first need to authorize this application and import your existing Microsoft or Google Contacts.",
            style: bodyTxtStyle,
            textAlign: TextAlign.center,
          ),
        ].toColumn().constrained(
            maxWidth: state.isDuoSpanned
                ? MediaQuery.of(context).size.width / 2 - 150
                : 755),
        kIsWeb
            ? Image.asset("assets/images/google-signin.png", height: 50)
                .gestures(onTap: state.handleStartPressed)
            : Column(
                children: [
                  PrimaryTextBtn(
                    "Sign in with Microsoft",
                    onPressed: state.handleStartPressed,
                  ).padding(top: Insets.m).width(239),
                  Text(
                    "or",
                    style: bodyTxtStyle,
                    textAlign: TextAlign.center,
                  ),
                  PrimaryTextBtn(
                    "Sign in with Google",
                    onPressed: state.handleStartPressed,
                  ).padding(top: Insets.m).width(239),
                ],
              ),
      ],
    ).padding(vertical: Insets.l);
  }
}
