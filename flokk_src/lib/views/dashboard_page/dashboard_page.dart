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
        scrollPadding: const EdgeInsets.only(right: Insets.m),
        child: Column(
          children: <Widget>[
            const SizedBox(height: Insets.l),
            const TopContactsSection(),
            const VSpace(Insets.m),
            const SocialActivitySection().padding(horizontal: Insets.lGutter).flexible(),
            const SizedBox(height: Insets.l * 1.5),
            RepaintBoundary(
              child: const UpcomingActivitiesSection().height(170).padding(horizontal: Insets.lGutter),
            ),
            const SizedBox(height: Insets.l),
          ],
        ));
  }
}
