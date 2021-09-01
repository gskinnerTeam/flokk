import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/buttons/primary_btn.dart';
import 'package:flokk/styled_components/buttons/secondary_btn.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void p() => print("CLick1");
    AppTheme theme = context.watch();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SeparatedRow(
          mainAxisAlignment: MainAxisAlignment.center,
          separatorBuilder: () => HSpace(Insets.l),
          children: [
            SeparatedColumn(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                separatorBuilder: () => VSpace(Insets.m),
                children: [
                  ColorShiftIconBtn(StyledIcons.add,
                      color: theme.accent1, onPressed: p),
                ]),
            SeparatedColumn(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              separatorBuilder: () => VSpace(Insets.m),
              children: [
                SecondaryIconBtn(StyledIcons.add, onPressed: p),
                SecondaryBtn(child: FlutterLogo(), onPressed: p),
                SecondaryTextBtn("STAY ON THIS PAGE", onPressed: p),
                TransparentBtn(
                    child: Text("CLICK ME!",
                        style: TextStyles.Footnote.textColor(theme.accent1)),
                    onPressed: p),
                TransparentBtn(
                    bigMode: true,
                    child: Text(
                      "CLICK ME!",
                      style: TextStyles.Caption.textColor(theme.accent1),
                    ),
                    onPressed: p),
              ],
            ),
            SeparatedColumn(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              separatorBuilder: () => VSpace(Insets.m),
              children: [
                PrimaryTextBtn("SAVE", onPressed: p),
                PrimaryTextBtn("SAVE", bigMode: true, onPressed: p),
                PrimaryBtn(
                    onPressed: p,
                    child: Text("SAVE FOR WEB", style: TextStyles.Footnote)),
                PrimaryBtn(
                    onPressed: p,
                    child: Text("SAVE FOR WEB", style: TextStyles.Footnote),
                    bigMode: true),
              ],
            )
          ],
        ),
      ),
    );
  }
}
