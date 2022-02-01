import 'dart:convert';
import 'dart:typed_data';

import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:json_annotation/json_annotation.dart';

part "contact_data.g.dart";

enum ContactOrderBy {
  Email,
  FirstName,
  LastName,
}

@JsonSerializable(explicitToJson: true)
class ContactData {
  bool get isNew => StringUtils.isEmpty(id);

  String get id => googleId;

  /// ////////////////////////////////////////

  String get firstPhone {
    if (phoneList.isNotEmpty) {
      return phoneList.first.number;
    }
    return "";
  }

  String get firstEmail {
    if (emailList.isNotEmpty) {
      return emailList.first.value;
    }
    return "";
  }

  // Indicates that this contact came back in the the last refresh, UI can use this to animate new contacts
  bool isRecentlyAdded = false;
  bool isDeleted = false;
  String googleId = "";
  String etag = "";

  //Social
  String twitterHandle = "";
  String gitUsername = "";

  //Name info
  String generatedTitle = "";
  String nameFull = "";
  String namePrefix = "";
  String nameSuffix = "";
  String nameFamily = "";
  String nameGiven = "";
  String nameGivenPhonetic = "";
  String nameMiddle = "";
  String nameMiddlePhonetic = "";

  //Misc(
  String notes = "";
  BirthdayData birthday = BirthdayData();
  String nickname = "";
  String fileAs = "";
  bool isStarred = false;

  //Job
  String jobTitle = "";
  String jobDepartment = "";
  String jobCompany = "";

  String get formattedJob {
    bool hasTitle = !StringUtils.isEmpty(jobTitle);
    bool hasCompany = !StringUtils.isEmpty(jobCompany);
    if (hasTitle && hasCompany) return "$jobTitle, $jobCompany";
    return hasTitle ? jobTitle : jobCompany;
  }

  //Profile
  String profilePic = "";
  bool isDefaultPic = true;
  @JsonKey(ignore: true)
  String? profilePicBase64; //base 64 encoded bytes of profile pic (from picker)
  @JsonKey(ignore: true)
  Uint8List? profilePicBytes; //raw bytes of profile pic (from picker)
  @JsonKey(ignore: true)
  bool hasNewProfilePic = false;

  //Phone
  List<PhoneData> phoneList = const [];

  //Email
  List<EmailData> emailList = const [];

  //Address
  List<AddressData> addressList = const [];

  //Instant Messaging
  List<InstantMessageData> imList = const [];

  //User fields
  Map<String, String> customFields = const {};

  //Web Sites
  List<WebsiteData> websiteList = const [];

  //Relations
  List<RelationData> relationList = const [];

  //Labels
  @JsonKey(ignore: true)
  List<GroupData> groupList = const [];

  //Events
  List<EventData> eventList = const [];

  ContactData();

  factory ContactData.fromJson(Map<String, dynamic> json) => _$ContactDataFromJson(json);

  bool get hasName => !StringUtils.isEmpty("$nameGiven$nameMiddle$nameFamily$nameSuffix$namePrefix");

  bool get hasLabel => groupList.isNotEmpty;

  bool get hasEmail => emailList.isNotEmpty;

  bool get hasPhone => phoneList.isNotEmpty;

  bool get hasAddress => addressList.isNotEmpty;

  bool get hasLink => websiteList.isNotEmpty;

  bool get hasRelationship => relationList.isNotEmpty;

  bool get hasEvents => eventList.isNotEmpty;

  bool get hasJob => !StringUtils.isEmpty("$jobTitle$jobCompany$jobDepartment");

  bool get hasNotes => notes.isNotEmpty;

  bool get hasBirthday => !StringUtils.isEmpty(birthday.text);

  bool get hasValidDateForBirthday => birthday.date != DateTime(0, 1, 1);

  /// /////////////////////////////////////////////////////
  /// SOCIAL
  bool get hasTwitter => !StringUtils.isEmpty(twitterHandle);

  bool get hasGit => !StringUtils.isEmpty(gitUsername);

  bool get hasAllSocial => hasGit && hasTwitter;

  bool get hasAnySocial => hasGit || hasTwitter;

  bool hasSameSocial(ContactData other) => other.twitterHandle == twitterHandle && other.gitUsername == gitUsername;

  bool hasSocialOfType(SocialActivityType type) {
    if (type == SocialActivityType.Git) return hasGit;
    if (type == SocialActivityType.Twitter) return hasTwitter;
    return false;
  }

  //Not serialized, to be set/determined with each fetch because it's possible their account was deleted/changed in the meanwhile
  @JsonKey(ignore: true)
  bool hasValidGit = false;
  @JsonKey(ignore: true)
  bool hasValidTwitter = false;

  /// ////////////////////////////////////////////////
  /// SEARCHABLE
  late final String _searchable = _getSearchableFields().toLowerCase();

  String get searchable => _searchable;

  String _getSearchableFields() => "$nameGiven $nameMiddle $nameFamily $nameMiddlePhonetic $nameGivenPhonetic "
      "$namePrefix $nameSuffix $nameFull $twitterHandle $gitUsername $notes $birthday $nickname"
      "$jobTitle $jobDepartment $jobCompany ${phoneList.map((x) => x.number).join(",")}"
      "${addressList.map((x) => x.getFullAddress()).join(",")}"
      "${imList.map((x) => x.username).join(",")}"
      "${customFields.values.map((x) => x).join(",")}"
      "${relationList.map((x) => x.person).join(",")}"
      "${emailList.map((x) => x.value).join(",")} ${groupList.map((x) => x.name).join(",")}";

  /// ////////////////////////////////////////////////
  /// PUBLIC API
  ContactData trimLists() {
    emailList.removeWhere((email) => email.isEmpty);
    phoneList.removeWhere((phone) => phone.isEmpty);
    addressList.removeWhere((address) => address.isEmpty);

    websiteList.removeWhere((email) => email.isEmpty);
    relationList.removeWhere((rel) => rel.isEmpty);
    eventList.removeWhere((evt) => evt.isEmpty);

    return this;
  }

  List<DateMixin> get allDates {
    //Need to explicitly cast x as DateMixin, otherwise will throw CastError when trying to add birthday
    // ignore: unnecessary_cast
    List<DateMixin> dates = hasEvents ? eventList.map((e) => e as DateMixin).toList() : [];

    if (hasValidDateForBirthday) {
      dates.add(birthday);
    }
    return dates;
  }

  ContactData copy() => ContactData.fromJson(toJson())..groupList = groupList;

  bool equals(ContactData value) {
    return jsonEncode(value.toJson()).hashCode == jsonEncode(toJson()).hashCode;
  }

  Map<String, dynamic> toJson() => _$ContactDataToJson(this);

  @override
  bool operator ==(covariant ContactData other) => equals(other);

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class AddressData {
  String formattedAddress = "";
  String street = "";
  String poBox = "";
  String neighborhood = "";
  String city = "";
  String region = "";
  String postcode = "";
  String country = "";
  String type = "";

  AddressData();

  get isEmpty => StringUtils.isEmpty("$street$poBox$neighborhood$city$region$postcode$country$type");

  factory AddressData.fromJson(Map<String, dynamic> json) => _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);

  String getFullAddress() {
    String ss(String value, [String? extra]) => StringUtils.safeGet(value, extra);

    String streetAddress = "${ss(street, ", ")}${ss(formattedAddress)}";
    String address = "${ss(streetAddress, " \n")}";

    String cityRegion = ("${ss(city, ", ")}${ss(region)}");
    address += ss(cityRegion, " \n");

    String postCountry = "${ss(postcode, ", ")}${ss(country)}";
    address += ss(postCountry, " \n");

    /// Trim trailing line-break
    if (address.length > 1) {
      address = address.substring(0, address.length - 1);
    }
    return address;
  }

  String get singleLineStreet {
    return street.replaceAll("\n", " "); //strip out \n chars for use in inputs
  }
}

@JsonSerializable()
class InstantMessageData {
  String username = "";
  String type = "";

  InstantMessageData();

  get isEmpty => StringUtils.isEmpty("$username$type");

  factory InstantMessageData.fromJson(Map<String, dynamic> json) => _$InstantMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$InstantMessageDataToJson(this);
}

@JsonSerializable()
class PhoneData {
  String uri = "";
  String number = "";
  String type = "";

  PhoneData();

  get isEmpty => StringUtils.isEmpty("$number$type");

  factory PhoneData.fromJson(Map<String, dynamic> json) => _$PhoneDataFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneDataToJson(this);
}

@JsonSerializable()
class WebsiteData {
  String href = "";
  String type = "";

  WebsiteData();

  get isEmpty => StringUtils.isEmpty("$href$type");

  factory WebsiteData.fromJson(Map<String, dynamic> json) => _$WebsiteDataFromJson(json);

  Map<String, dynamic> toJson() => _$WebsiteDataToJson(this);
}

@JsonSerializable()
class EmailData {
  String value = "";
  String type = "";

  EmailData();

  get isEmpty => StringUtils.isEmpty("$value$type");

  factory EmailData.fromJson(Map<String, dynamic> json) => _$EmailDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmailDataToJson(this);
}

@JsonSerializable()
class RelationData {
  String person = "";
  String type = "";

  RelationData();

  get isEmpty => StringUtils.isEmpty("$person$type");

  factory RelationData.fromJson(Map<String, dynamic> json) => _$RelationDataFromJson(json);

  Map<String, dynamic> toJson() => _$RelationDataToJson(this);
}

@JsonSerializable()
class EventData with DateMixin {
  String type = "";

  EventData();

  @override
  String getType() => type;

  get isEmpty => date == DateTime(0, 1, 1) || date.toString().isEmpty;

  factory EventData.fromJson(Map<String, dynamic> json) => _$EventDataFromJson(json);

  Map<String, dynamic> toJson() => _$EventDataToJson(this);
}

@JsonSerializable()
class BirthdayData with DateMixin {
  String text = "";

  BirthdayData();

  @override
  String getType() => "Birthday";

  get isEmpty => StringUtils.isEmpty("$text");

  factory BirthdayData.fromJson(Map<String, dynamic> json) => _$BirthdayDataFromJson(json);

  Map<String, dynamic> toJson() => _$BirthdayDataToJson(this);
}

abstract class DateMixin {
  DateTime date = DateTime(0, 1, 1);

  String getType() => "";

  int get daysTilAnniversary {
    final now = DateTime.now();
    final currentYearXDate = DateTime(now.year, date.month, date.day);
    final nextYearXDate = DateTime(now.year + 1, date.month, date.day);
    return currentYearXDate.isAfter(now)
        ? currentYearXDate.difference(now).inDays
        : nextYearXDate.difference(now).inDays;
  }
}
