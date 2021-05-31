// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupData _$GroupDataFromJson(Map<String, dynamic> json) {
  return GroupData()
    ..id = json['id'] as String
    ..etag = json['etag'] as String
    ..name = json['name'] as String
    ..groupType = _$enumDecode(_$GroupTypeEnumMap, json['groupType'])
    ..memberCount = json['memberCount'] as int
    ..members =
        (json['members'] as List<dynamic>).map((e) => e as String).toList();
}

Map<String, dynamic> _$GroupDataToJson(GroupData instance) => <String, dynamic>{
      'id': instance.id,
      'etag': instance.etag,
      'name': instance.name,
      'groupType': _$GroupTypeEnumMap[instance.groupType],
      'memberCount': instance.memberCount,
      'members': instance.members,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$GroupTypeEnumMap = {
  GroupType.Unspecified: 'Unspecified',
  GroupType.UserContactGroup: 'UserContactGroup',
  GroupType.SystemContactGroup: 'SystemContactGroup',
};
