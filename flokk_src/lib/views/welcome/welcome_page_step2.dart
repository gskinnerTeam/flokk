import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/buttons/primary_btn.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_progress_spinner.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/welcome/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePageStep2 extends StatefulWidget {
  const WelcomePageStep2({Key? key}) : super(key: key);

  @override
  _WelcomePageStep2State createState() => _WelcomePageStep2State();
}

class _WelcomePageStep2State extends State<WelcomePageStep2> {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    WelcomePageState state = context.watch();

    TextStyle bodyTxtStyle =
        TextStyles.Body1.textColor(Colors.white).textHeight(1.6);
    TextStyle titleTxtStyle = TextStyles.T1.textColor(theme.accent1Darker);
    TextStyle headerTxtStyle =
        TextStyles.CalloutFocus.bold.size(24).textColor(Colors.white);

    return state.isLoading
        ? StyledProgressSpinner()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Authorization",
                  style: headerTxtStyle, textAlign: TextAlign.center),
              VSpace(Insets.l * 2),

              /// ////////////////////////////////////////////////
              /// STEP 1
              Text("STEP 1", style: titleTxtStyle, textAlign: TextAlign.center),
              Text(
                "Copy the following code to your clipboard by clicking the icon or selecting the text.",
                style: bodyTxtStyle,
                textAlign: TextAlign.center,
              ),

              /// DEVICE CODE BOX
              StyledOutlinedBox(
                child: state.isLoading
                    ? StyledProgressSpinner()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          SelectableText("${state.authCode}",
                                  style: bodyTxtStyle.size(16))
                              .center(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ColorShiftIconBtn(StyledIcons.refresh,
                                  size: 28,
                                  color: Colors.white,
                                  onPressed: state.handleRefreshPressed),
                              ColorShiftIconBtn(StyledIcons.copy,
                                  size: 24,
                                  color: Colors.white,
                                  onPressed: state.handleCodeClicked),
                            ],
                          ).padding(horizontal: Insets.m),
                        ],
                      ),
              ).padding(vertical: Insets.l),
              VSpace(Insets.m),

              /// ////////////////////////////////////////////////
              /// STEP 2
              Text("STEP 2", style: titleTxtStyle, textAlign: TextAlign.center),
              Text(
                "Navigate to the following link and enter the code you’ve copied.\nFollow the provided instructions to authorize this application.",
                style: bodyTxtStyle,
                textAlign: TextAlign.center,
              ),

              /// DEVICE URL BOX
              StyledOutlinedBox(
                child: state.isLoading
                    ? StyledProgressSpinner()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          SelectableText("${state.authUrl}",
                                  style: bodyTxtStyle.size(16))
                              .center(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ColorShiftIconBtn(StyledIcons.linkout,
                                  size: 24,
                                  color: Colors.white,
                                  onPressed: state.handleUrlClicked),
                            ],
                          ).padding(horizontal: Insets.m),
                        ],
                      ),
              ).padding(vertical: Insets.l),
              VSpace(Insets.m),

              /// ////////////////////////////////////////////////
              /// STEP 3
              Text("STEP 3", style: titleTxtStyle, textAlign: TextAlign.center),
              Text(
                "Press the button below when you have completed the process.",
                style: bodyTxtStyle,
                textAlign: TextAlign.center,
              ),
              VSpace(Insets.m),
              PrimaryTextBtn(
                "CONTINUE",
                bigMode: true,
                onPressed: state.handleCompletePressed,
              ).padding(top: Insets.m).width(215),
              VSpace(Insets.l),
              if (state.authCodeError || state.httpError)
                Text(
                  "Error: ${getCurrentErrorCode(state)}",
                  textAlign: TextAlign.center,
                  style: TextStyles.T1.bold.textColor(
                    theme.error,
                  ),
                ).padding(all: Insets.m).decorated(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Corners.s5),
                    ),
            ],
          ).constrained(maxWidth: 500);
  }

  String getCurrentErrorCode(WelcomePageState state) {
    if (state.httpError) {
      return "We couldn’t connect to the internet. Please check your connection.";
    } else {
      return "We couldn’t authorize your account. Please make sure that you’ve completed the entire verification process.";
    }
  }
}

class StyledOutlinedBox extends StatelessWidget {
  final Widget? child;

  const StyledOutlinedBox({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: Corners.s8Border,
        border: Border.all(color: Colors.white.withOpacity(.35), width: 1.2),
      ),
      child: child,
    );
  }
}
