import 'dart:convert';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:googleapis/people/v1.dart';

class GoogleRestContactsService {
  static final String kTwitterParam = "Twitter";
  static final String kGitParam = "Github";

  //The requested fields to fetch, full list here: https://developers.google.com/people/api/rest/v1/people.connections/list?hl=ru
  static const List<String> kAllPersonFields = [
    "addresses",
    "ageRanges",
    "biographies",
    "birthdays",
    "braggingRights",
    "coverPhotos",
    "emailAddresses",
    "events",
    "genders",
    "imClients",
    "interests",
    "locales",
    "memberships",
    "metadata",
    "names",
    "nicknames",
    "occupations",
    "organizations",
    "phoneNumbers",
    "photos",
    "relations",
    "relationshipInterests",
    "relationshipStatuses",
    "residences",
    "sipAddresses",
    "skills",
    "taglines",
    "urls",
    "userDefined"
  ];

  //List of update fields https://developers.google.com/people/api/rest/v1/people/updateContact
  //Note that these are just a subset of the full list of PersonFields (kAllPersonFields)
  //Removed "memberships" field, because that should only be edited by the group API calls
  static const kAllUpdatePersonFields = [
    "addresses",
    "biographies",
    "birthdays",
    "emailAddresses",
    "events",
    "genders",
    "imClients",
    "interests",
    "locales",
    "names",
    "nicknames",
    "occupations",
    "organizations",
    "phoneNumbers",
    "relations",
    "residences",
    "sipAddresses",
    "urls",
    "userDefined"
  ];

  //Debug hook to test many contacts, if the multiplier is > 1, it will clone your contacts list that many times.
  static int contactsMultiplier = 1;

  Future<ServiceResult<GetContactsResult>> getAll(String accessToken, String syncToken) async {
    List<ContactData> list = [];
    bool requestSyncToken = syncToken == "";
    int retryCount = 0;
    String nextPageToken = "";
    ServiceResult<GetContactsResult> result;
    if (requestSyncToken) {
      //Request new sync token
      result = await get(accessToken, requestSyncToken: requestSyncToken);
    } else {
      //Attempt to use existing token (possible that it's expired)
      result = await get(accessToken, syncToken: syncToken);

      //We get a 400 status if the token is expired, try again and request new sync token
      if (result.response.errorType == NetErrorType.denied) {
        requestSyncToken = true;
        result = await get(accessToken, requestSyncToken: requestSyncToken);
      }
    }

    list = result.content?.contacts ?? [];
    nextPageToken = result.content?.nextPageToken ?? "";
    syncToken = result.content?.syncToken ?? "";

    //Attempt to load all chunks of data, just for edge cases that have > 2000 contacts (max page size)
    while (nextPageToken.isNotEmpty && retryCount < 3) {
      ServiceResult<GetContactsResult> result = await get(
        accessToken,
        nextPageToken: nextPageToken,
      );

      if (result.success) {
        list.addAll(result.content?.contacts ?? []);
        nextPageToken = result.content?.nextPageToken ?? "";
      } else {
        //Possible for subsequent calls to fail and return 503
        retryCount++;
      }
    }
    return result;
  }

  //List of valid PersonFields can be found here https://developers.google.com/people/api/rest/v1/people.connections/list
  Future<ServiceResult<GetContactsResult>> get(String accessToken,
      {List<String> personFields = const [],
        String nextPageToken = "",
        String syncToken = "",
        bool requestSyncToken = true}) async {
    // Default to all person fields if none are passed
    if (personFields.isEmpty) {
      personFields = kAllPersonFields;
    }
    String url = "https://people.googleapis.com/v1/people/me/connections?"
        "access_token=$accessToken"
        "&personFields=${kAllPersonFields.join(',')}"
        "&sortOrder=FIRST_NAME_ASCENDING"
        "&pageSize=2000";

    if (nextPageToken.isNotEmpty) {
      url += "&pageToken=$nextPageToken";
    }

    if (syncToken.isNotEmpty) {
      url += "&syncToken=$syncToken";
    }

    url += "&requestSyncToken=$requestSyncToken";
    HttpResponse response = await HttpClient.get(url);
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    List<ContactData> list = [];
    String newNextPageToken = "";
    String newSyncToken = "";
    if (response.success == true) {
      Map<String, dynamic> data = jsonDecode(response.body);
      newNextPageToken = data["nextPageToken"] ?? "";
      newSyncToken = data["nextSyncToken"] ?? "";
      List<dynamic> entries = data["connections"] ?? [];
      print("token: $newNextPageToken ${entries.length} out of ${data["totalPeople"]}");
      for (int i = 0, l = entries.length; i < l; i++) {
        ContactData c = contactFromJson(entries[i]);
        list.add(c);
      }
      if (contactsMultiplier > 1) {
        List<ContactData> copy = list.toList();
        for (var i = contactsMultiplier; i-- > 0;) {
          list.addAll(copy);
        }
      }
    }
    return ServiceResult(GetContactsResult(list, nextPageToken: nextPageToken, syncToken: newSyncToken), response);
  }

  //List of valid PersonFields can be found here https://developers.google.com/people/api/rest/v1/people/updateContact
  Future<ServiceResult<ContactData>> set(String accessToken, ContactData contact, {List<String> personFields = const[]}) async {
    if (personFields.isEmpty)
      personFields = kAllUpdatePersonFields;
    String url = "https://people.googleapis.com/v1/${contact.googleId}:updateContact?"
        "updatePersonFields=${personFields.join(',')}";

    HttpResponse response = await HttpClient.patch(url,
        headers: {"Authorization": "Bearer $accessToken"}, body: jsonEncode(contactToJson(contact)));
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    ContactData updatedContact = ContactData();
    if (response.success == true) {
      //updated contact returned from server
      updatedContact = contactFromJson(jsonDecode(response.body));
    }
    return ServiceResult(updatedContact, response);
  }

  Future<ServiceResult<ContactData>> create(String accessToken, ContactData contact) async {
    String url = "https://people.googleapis.com/v1/people:createContact";

    HttpResponse response = await HttpClient.post(url,
        headers: {"Authorization": "Bearer $accessToken"}, body: jsonEncode(contactToJson(contact)));
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    ContactData newContact = ContactData();
    if (response.success == true) {
      //new contact with proper "resourceName"(googleId) and "etag" properties set
      newContact = contactFromJson(jsonDecode(response.body));
    }
    return ServiceResult(newContact, response);
  }

  Future<ServiceResult<void>> delete(String accessToken, ContactData contact) async {
    String url = "https://people.googleapis.com/v1/${contact.googleId}:deleteContact";

    HttpResponse response = await HttpClient.delete(url, headers: {"Authorization": "Bearer $accessToken"});
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    return ServiceResult(null, response);
  }

  //Takes a base64 encoded image
  Future<ServiceResult<ContactData>> updatePic(String accessToken, ContactData contact, String profilePic) async {
    String url = "https://people.googleapis.com/v1/${contact.googleId}:updateContactPhoto";

    Map<String, String> bodyJson = {"photoBytes": profilePic, "personFields": "names,photos"};

    HttpResponse response =
        await HttpClient.patch(url, headers: {"Authorization": "Bearer $accessToken"}, body: jsonEncode(bodyJson));
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    ContactData updatedContact = ContactData();
    if (response.success == true) {
      updatedContact = contactFromJson(jsonDecode(response.body)["person"]);
    }
    return ServiceResult(updatedContact, response);
  }

  Future<ServiceResult<void>> deletePic(String accessToken, ContactData contact) async {
    String url = "https://people.googleapis.com/v1/${contact.googleId}:deleteContactPhoto";

    HttpResponse response = await HttpClient.delete(url, headers: {"Authorization": "Bearer $accessToken"});
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    return ServiceResult(null, response);
  }

  ContactData contactFromJson(Map<String, dynamic> json) {
    // c.fileAs =
    Person p = Person.fromJson(json);
    ContactData c = ContactData()
      ..googleId = p.resourceName ?? ""
      ..etag = p.etag ?? ""
      ..nameGiven = p.names?.first.givenName ?? ""
      ..nameGivenPhonetic = p.names?.first.phoneticGivenName ?? ""
      ..nameMiddle = p.names?.first.middleName ?? ""
      ..nameMiddlePhonetic = p.names?.first.phoneticMiddleName ?? ""
      ..nameFamily = p.names?.first.familyName ?? ""
      ..nameFull = p.names?.first.displayName ?? ""
      ..namePrefix = p.names?.first.honorificPrefix ?? ""
      ..nameSuffix = p.names?.first.honorificSuffix ?? ""
      ..nickname = p.nicknames?.first.value ?? ""
      ..profilePic = p.photos?.first.url ?? ""
      ..isDefaultPic = p.photos?.first.default_ ?? false
      ..isDeleted = p.metadata?.deleted ?? false
      ..jobCompany = p.organizations?.first.name ?? ""
      ..jobDepartment = p.organizations?.first.department ?? ""
      ..jobTitle = p.organizations?.first.title ?? ""
      ..notes = p.biographies?.first.value ?? ""
      ..emailList = p.emailAddresses
              ?.where((x) => x.metadata?.source?.type != "DOMAIN_PROFILE")
              .map((x) => EmailData()
                ..value = x.value ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..phoneList = p.phoneNumbers
              ?.map((x) => PhoneData()
                ..number = x.value ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..websiteList = p.urls
              ?.map((x) => WebsiteData()
                ..href = x.value ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..imList = p.imClients
              ?.map((x) => InstantMessageData()
                ..username = x.username ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..relationList = p.relations
              ?.map((x) => RelationData()
                ..person = x.person ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..eventList = p.events
              ?.map((x) => EventData()
                ..date = DateTime(x.date?.year ?? 0, x.date?.month ?? 1, x.date?.day ?? 1)
                ..type = x.formattedType ?? "")
              .toList() ??
          []
      ..addressList = p.addresses
              ?.map((x) => AddressData()
                ..city = x.city ?? ""
                ..country = x.country ?? ""
                ..poBox = x.poBox ?? ""
                ..street = x.streetAddress ?? ""
                ..formattedAddress = x.extendedAddress ?? ""
                ..postcode = x.postalCode ?? ""
                ..region = x.region ?? ""
                ..type = x.formattedType ?? "")
              .toList() ??
          [];

    if (p.birthdays?.isNotEmpty ?? false) {
      c.birthday = BirthdayData()
        ..date = DateTime(
            p.birthdays?.first.date?.year ?? 0, p.birthdays?.first.date?.month ?? 1, p.birthdays?.first.date?.day ?? 1)
        ..text = p.birthdays?.first.text ?? "";

      if (c.birthday.date == DateTime(0, 1, 1)) {
        try {
          c.birthday.date = DateFormats.google.parse(c.birthday.text);
        } catch (e) {
          c.birthday.date = DateTime(0, 1, 1);
        }
      }
    }

    if (p.userDefined?.isNotEmpty ?? false) {
      c.customFields =
          Map.fromIterable(p.userDefined ?? [], key: (x) => (x as UserDefined).key ?? "", value: (x) => (x as UserDefined).value ?? "");

      /// Inject known custom fields into Contact, and remove from Map
      c.twitterHandle = c.customFields.remove(kTwitterParam) ?? "";
      c.gitUsername = c.customFields.remove(kGitParam) ?? "";
    }

    c.groupList = []; //will be populated by GroupData

    // Don't allow empty lists into the app domain, makes our life much easier on the UI end :)
    c.trimLists();

    return c;
  }

  Map<String, dynamic> contactToJson(ContactData contact) {
    Person p = Person()
      ..resourceName = contact.googleId
      ..etag = contact.etag
      ..names = [
        Name()
          ..givenName = contact.nameGiven
          ..phoneticGivenName = contact.nameGivenPhonetic
          ..middleName = contact.nameMiddle
          ..phoneticMiddleName = contact.nameMiddlePhonetic
          ..familyName = contact.nameFamily
          ..displayName = contact.nameFull
          ..honorificPrefix = contact.namePrefix
          ..honorificSuffix = contact.nameSuffix
      ]
      ..nicknames = [Nickname()..value = contact.nickname]
      ..organizations = [
        Organization()
          ..name = contact.jobCompany
          ..department = contact.jobDepartment
          ..title = contact.jobTitle
      ]
      ..biographies = [Biography()..value = contact.notes]
      ..emailAddresses = contact.emailList
          .map((x) => EmailAddress()
            ..value = x.value
            ..type = x.type)
          .toList()
      ..phoneNumbers = contact.phoneList
          .map((x) => PhoneNumber()
            ..value = x.number
            ..type = x.type)
          .toList()
      ..urls = contact.websiteList
          .map((x) => Url()
            ..value = x.href
            ..type = x.type)
          .toList()
      ..imClients = contact.imList
          .map((x) => ImClient()
            ..username = x.username
            ..type = x.type)
          .toList()
      ..relations = contact.relationList
          .map((x) => Relation()
            ..person = x.person
            ..type = x.type)
          .toList()
      ..events = contact.eventList.map((x) {
        Date d = Date()
          ..year = x.date.year
          ..month = x.date.month
          ..day = x.date.day;
        return Event()
          ..date = d
          ..type = x.type;
      }).toList()
      ..addresses = contact.addressList
          .map((x) => Address()
            ..city = x.city
            ..country = x.country
            ..poBox = x.poBox
            ..streetAddress = x.street
            ..extendedAddress = x.formattedAddress
            ..postalCode = x.postcode
            ..region = x.region
            ..type = x.type)
          .toList();

    if (contact.birthday.isEmpty == false) {
      p.birthdays = [Birthday()..text = contact.birthday.text];
    }

    if (contact.hasGit || contact.hasTwitter || contact.customFields.isNotEmpty) {
      /// Inject known custom fields back into the payload
      void addUserDefined(String key, dynamic value) {
        if (value == null) return;
        p.userDefined?.add(UserDefined()
          ..key = key
          ..value = value);
      }

      p.userDefined = [];

      /// Inject each customField that's been set into the Person
      contact.customFields.forEach(addUserDefined);

      /// Inject our own, known fields
      if (contact.hasTwitter) addUserDefined(kTwitterParam, contact.twitterHandle);
      if (contact.hasGit) addUserDefined(kGitParam, contact.gitUsername);
    }
    //NOTE: Person.Photos are not needed in this, they are read-only
    return p.toJson();
  }
}

class GetContactsResult {
  final List<ContactData> contacts;
  final String nextPageToken;
  final String syncToken;

  GetContactsResult(this.contacts, {required this.nextPageToken, required this.syncToken});
}
