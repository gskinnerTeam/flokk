// @dart=2.9
import 'package:flutter/material.dart';

class AppGlobals {
  static GlobalKey<NavigatorState> rootNavKey = GlobalKey();

  static NavigatorState get nav => rootNavKey.currentState;
}
