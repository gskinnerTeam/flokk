import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/date_sortable_interface.dart';
import 'package:github/github.dart';

class GitEvent implements DateSortable {
  //Populated at runtime
  Repository repository = Repository();

  //Serialized to json
  Event event = Event();

  @override
  DateTime get createdAt => event.createdAt ?? Dates.epoch; //Read only

  @override
  void set createdAt(DateTime value) {}

  GitEvent();

  factory GitEvent.fromJson(Map<String, dynamic> json) {
    return GitEvent()
      ..event = json["event"] == null
          ? Event()
          : Event.fromJson(json["event"] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {"event": event};
}
