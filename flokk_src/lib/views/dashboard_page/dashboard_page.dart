import 'package:flokk/_internal/components/scrolling_flex_view.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/dashboard_page/dates/important_dates_section.dart';
import 'package:flokk/views/dashboard_page/social/social_activities_section.dart';
import 'package:flokk/views/dashboard_page/top/top_contacts_section.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final ContactData selectedContact;

  const DashboardPage({Key? key, required this.selectedContact}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedFlexView(850,
        scrollPadding: EdgeInsets.only(right: Insets.m),
        child: Column(
          children: <Widget>[
            SizedBox(height: Insets.l),
            TopContactsSection(),
            VSpace(Insets.m),
            SocialActivitySection().padding(horizontal: Insets.lGutter).flexible(),
            SizedBox(height: Insets.l * 1.5),
            RepaintBoundary(
              child: UpcomingActivitiesSection().height(170).padding(horizontal: Insets.lGutter),
            ),
            SizedBox(height: Insets.l),
          ],
        ));
  }
}
