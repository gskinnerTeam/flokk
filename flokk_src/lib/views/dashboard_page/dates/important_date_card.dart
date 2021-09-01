import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_card.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImportantEventCard extends StatelessWidget {
  const ImportantEventCard(this.contact, this.event, {Key? key})
      : super(key: key);

  static DateFormat get monthDayFmt => DateFormat("MMMMEEEEd");

  final ContactData contact;
  final DateMixin event;

  bool get isBirthday => event is BirthdayData;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    TextStyle cardContentText = TextStyles.H2.textColor(theme.txt);
    Color eventColor = isBirthday ? theme.accent3 : theme.accent2;

    return TransparentBtn(
      onPressed: () => context
          .read<MainScaffoldState>()
          .trySetSelectedContact(contact, showSocial: false),
      borderRadius: Corners.s8,
      contentPadding: EdgeInsets.zero,
      child: StyledCard(
        align: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HSpace(Insets.m),
            StyledUserAvatar(contact: contact, size: 40),
            HSpace(Insets.sm),
            Text(contact.nameFull, style: cardContentText),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Spacer(),
                OneLineText(event.getType(),
                    style: cardContentText.textColor(eventColor)),
                VSpace(Insets.sm),
                OneLineText(monthDayFmt.format(event.date),
                    style: cardContentText),
                Spacer(),
              ],
            ).width(110),
            HSpace(Insets.m),
            //Text(cWithD.item2.date.toString()),
          ],
        ).padding(all: Insets.sm),
      ).height(54),
    );
  }
}
