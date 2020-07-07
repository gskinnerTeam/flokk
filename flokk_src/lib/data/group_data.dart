import 'package:json_annotation/json_annotation.dart';

part 'group_data.g.dart';

@JsonSerializable(nullable: true)
class GroupData {
  String id;
  String etag; //required field in API call for updates
  String name;
  GroupType groupType;
  int memberCount;
  List<String> members;

  GroupData();

  factory GroupData.fromJson(Map<String, dynamic> json) => _$GroupDataFromJson(json);

  Map<String, dynamic> toJson() => _$GroupDataToJson(this);
}

enum GroupType { GroupTypeUnspecified, UserContactGroup, SystemContactGroup }
