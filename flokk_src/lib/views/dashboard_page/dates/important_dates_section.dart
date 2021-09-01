import 'dart:math';

import 'package:flokk/_internal/components/simple_grid.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/dashboard_page/dates/important_date_card.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flokk/views/empty_states/placeholder_important_dates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class UpcomingActivitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    ContactsModel contactsModel = context.watch();
    List<Tuple2<ContactData, DateMixin>> contactsWithDate =
        contactsModel.upcomingDateContacts;
    TextStyle headerStyle = TextStyles.T1;

    /// Create list of ItemRenderers
    List<Widget> kids = contactsWithDate
        .map((cWithD) => ImportantEventCard(cWithD.item1, cWithD.item2))
        .toList();

    /// Build list
    return LayoutBuilder(
      builder: (_, constraints) {
        int colCount = max(1, (constraints.maxWidth / 320).floor());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("UPCOMING IMPORTANT DATES",
                style: headerStyle.textColor(theme.accent1Darker)),
            VSpace(Insets.l * .75),
            PlaceholderContentSwitcher(
              hasContent: () => kids.isNotEmpty,
              placeholder: ImportantDatesPlaceholder(),
              content: SingleChildScrollView(
                child: SimpleGrid(
                  kidHeight: 54,
                  kids: kids,
                  colCount: colCount,
                  hSpace: Insets.m * 1.5,
                  vSpace: Insets.l * .75,
                ),
              ),
            ).flexible(),
          ],
        );
      },
    );
  }
}
