import 'package:flokk/api_keys.dart';
import 'package:flokk/services/google_rest/google_rest_auth_service.dart';
import 'package:flokk/services/google_rest/google_rest_contact_groups_service.dart';
import 'package:flokk/services/google_rest/google_rest_contacts_service.dart';

class GoogleRestService {
  static String kStarredGroupId = "contactGroups/starred";

  final GoogleRestContactsService contacts = GoogleRestContactsService();
  final GoogleRestContactGroupsService groups =
      GoogleRestContactGroupsService();
  final GoogleRestAuthService auth = GoogleRestAuthService(
      ApiKeys().googleClientId, ApiKeys().googleClientSecret);
}
