import 'package:flokk/commands/abstract_command.dart';
import 'package:flutter/cupertino.dart';

class TestRepeatCommand extends AbstractCommand {
  //needs to be outside the scope of instance otherwise it gets reset and doesn't cancel properly
  static bool _isCancelled = false;

  TestRepeatCommand(BuildContext c) : super(c);

  void stop() {
    print("stop() called");
    _isCancelled = true;
  }

  Future<List<String>> execute(
      {bool poll = false,
      Duration pollInterval = const Duration(seconds: 5),
      bool calledBySelf = false}) async {
    //reset the _isCancelled flag if poll is true and executed by self, allows proper restart of polling
    if (poll && !calledBySelf) {
      _isCancelled = false;
    }

    print("Do stuff: ${DateTime.now()}");

    if (poll) {
      Future.delayed(pollInterval).then((value) {
        print("delayed call, isCancelled? $_isCancelled");
        if (_isCancelled) {
          print("cancelled");
          return;
        }
        execute(poll: true, pollInterval: pollInterval, calledBySelf: true);
      });
    }
    print("return []");
    return [];
  }
}
