// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactData _$ContactDataFromJson(Map<String, dynamic> json) {
  return ContactData()
    ..isRecentlyAdded = json['isRecentlyAdded'] as bool
    ..isDeleted = json['isDeleted'] as bool
    ..googleId = json['googleId'] as String
    ..etag = json['etag'] as String
    ..twitterHandle = json['twitterHandle'] as String
    ..gitUsername = json['gitUsername'] as String
    ..generatedTitle = json['generatedTitle'] as String
    ..nameFull = json['nameFull'] as String
    ..namePrefix = json['namePrefix'] as String
    ..nameSuffix = json['nameSuffix'] as String
    ..nameFamily = json['nameFamily'] as String
    ..nameGiven = json['nameGiven'] as String
    ..nameGivenPhonetic = json['nameGivenPhonetic'] as String
    ..nameMiddle = json['nameMiddle'] as String
    ..nameMiddlePhonetic = json['nameMiddlePhonetic'] as String
    ..notes = json['notes'] as String
    ..birthday = BirthdayData.fromJson(json['birthday'] as Map<String, dynamic>)
    ..nickname = json['nickname'] as String
    ..fileAs = json['fileAs'] as String
    ..isStarred = json['isStarred'] as bool
    ..jobTitle = json['jobTitle'] as String
    ..jobDepartment = json['jobDepartment'] as String
    ..jobCompany = json['jobCompany'] as String
    ..profilePic = json['profilePic'] as String
    ..isDefaultPic = json['isDefaultPic'] as bool
    ..phoneList = (json['phoneList'] as List<dynamic>)
        .map((e) => PhoneData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..emailList = (json['emailList'] as List<dynamic>)
        .map((e) => EmailData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..addressList = (json['addressList'] as List<dynamic>)
        .map((e) => AddressData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..imList = (json['imList'] as List<dynamic>)
        .map((e) => InstantMessageData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..customFields = Map<String, String>.from(json['customFields'] as Map)
    ..websiteList = (json['websiteList'] as List<dynamic>)
        .map((e) => WebsiteData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..relationList = (json['relationList'] as List<dynamic>)
        .map((e) => RelationData.fromJson(e as Map<String, dynamic>))
        .toList()
    ..eventList = (json['eventList'] as List<dynamic>)
        .map((e) => EventData.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ContactDataToJson(ContactData instance) =>
    <String, dynamic>{
      'isRecentlyAdded': instance.isRecentlyAdded,
      'isDeleted': instance.isDeleted,
      'googleId': instance.googleId,
      'etag': instance.etag,
      'twitterHandle': instance.twitterHandle,
      'gitUsername': instance.gitUsername,
      'generatedTitle': instance.generatedTitle,
      'nameFull': instance.nameFull,
      'namePrefix': instance.namePrefix,
      'nameSuffix': instance.nameSuffix,
      'nameFamily': instance.nameFamily,
      'nameGiven': instance.nameGiven,
      'nameGivenPhonetic': instance.nameGivenPhonetic,
      'nameMiddle': instance.nameMiddle,
      'nameMiddlePhonetic': instance.nameMiddlePhonetic,
      'notes': instance.notes,
      'birthday': instance.birthday.toJson(),
      'nickname': instance.nickname,
      'fileAs': instance.fileAs,
      'isStarred': instance.isStarred,
      'jobTitle': instance.jobTitle,
      'jobDepartment': instance.jobDepartment,
      'jobCompany': instance.jobCompany,
      'profilePic': instance.profilePic,
      'isDefaultPic': instance.isDefaultPic,
      'phoneList': instance.phoneList.map((e) => e.toJson()).toList(),
      'emailList': instance.emailList.map((e) => e.toJson()).toList(),
      'addressList': instance.addressList.map((e) => e.toJson()).toList(),
      'imList': instance.imList.map((e) => e.toJson()).toList(),
      'customFields': instance.customFields,
      'websiteList': instance.websiteList.map((e) => e.toJson()).toList(),
      'relationList': instance.relationList.map((e) => e.toJson()).toList(),
      'eventList': instance.eventList.map((e) => e.toJson()).toList(),
    };

AddressData _$AddressDataFromJson(Map<String, dynamic> json) {
  return AddressData()
    ..formattedAddress = json['formattedAddress'] as String
    ..street = json['street'] as String
    ..poBox = json['poBox'] as String
    ..neighborhood = json['neighborhood'] as String
    ..city = json['city'] as String
    ..region = json['region'] as String
    ..postcode = json['postcode'] as String
    ..country = json['country'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'formattedAddress': instance.formattedAddress,
      'street': instance.street,
      'poBox': instance.poBox,
      'neighborhood': instance.neighborhood,
      'city': instance.city,
      'region': instance.region,
      'postcode': instance.postcode,
      'country': instance.country,
      'type': instance.type,
    };

InstantMessageData _$InstantMessageDataFromJson(Map<String, dynamic> json) {
  return InstantMessageData()
    ..username = json['username'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$InstantMessageDataToJson(InstantMessageData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'type': instance.type,
    };

PhoneData _$PhoneDataFromJson(Map<String, dynamic> json) {
  return PhoneData()
    ..uri = json['uri'] as String
    ..number = json['number'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$PhoneDataToJson(PhoneData instance) => <String, dynamic>{
      'uri': instance.uri,
      'number': instance.number,
      'type': instance.type,
    };

WebsiteData _$WebsiteDataFromJson(Map<String, dynamic> json) {
  return WebsiteData()
    ..href = json['href'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$WebsiteDataToJson(WebsiteData instance) =>
    <String, dynamic>{
      'href': instance.href,
      'type': instance.type,
    };

EmailData _$EmailDataFromJson(Map<String, dynamic> json) {
  return EmailData()
    ..value = json['value'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$EmailDataToJson(EmailData instance) => <String, dynamic>{
      'value': instance.value,
      'type': instance.type,
    };

RelationData _$RelationDataFromJson(Map<String, dynamic> json) {
  return RelationData()
    ..person = json['person'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$RelationDataToJson(RelationData instance) =>
    <String, dynamic>{
      'person': instance.person,
      'type': instance.type,
    };

EventData _$EventDataFromJson(Map<String, dynamic> json) {
  return EventData()
    ..date = DateTime.parse(json['date'] as String)
    ..type = json['type'] as String;
}

Map<String, dynamic> _$EventDataToJson(EventData instance) => <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'type': instance.type,
    };

BirthdayData _$BirthdayDataFromJson(Map<String, dynamic> json) {
  return BirthdayData()
    ..date = DateTime.parse(json['date'] as String)
    ..text = json['text'] as String;
}

Map<String, dynamic> _$BirthdayDataToJson(BirthdayData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'text': instance.text,
    };
