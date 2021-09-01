import 'package:json_annotation/json_annotation.dart';

part 'group_data.g.dart';

@JsonSerializable()
class GroupData {
  String id = "";
  String etag = ""; //required field in API call for updates
  String name = "";
  GroupType groupType = GroupType.Unspecified;
  int memberCount = 0;
  List<String> members = const [];

  GroupData();

  factory GroupData.fromJson(Map<String, dynamic> json) =>
      _$GroupDataFromJson(json);

  Map<String, dynamic> toJson() => _$GroupDataToJson(this);

  @override
  bool operator ==(covariant GroupData other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum GroupType { Unspecified, UserContactGroup, SystemContactGroup }
