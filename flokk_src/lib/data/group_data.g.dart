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
    ..groupType = _$enumDecodeNullable(_$GroupTypeEnumMap, json['groupType'])
    ..memberCount = json['memberCount'] as int
    ..members = (json['members'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$GroupDataToJson(GroupData instance) => <String, dynamic>{
      'id': instance.id,
      'etag': instance.etag,
      'name': instance.name,
      'groupType': _$GroupTypeEnumMap[instance.groupType],
      'memberCount': instance.memberCount,
      'members': instance.members,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$GroupTypeEnumMap = {
  GroupType.GroupTypeUnspecified: 'GroupTypeUnspecified',
  GroupType.UserContactGroup: 'UserContactGroup',
  GroupType.SystemContactGroup: 'SystemContactGroup',
};
