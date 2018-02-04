import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Options {
  double bulletSpeed;

  int buttonCost;
  int buttonIncCost;

  int maxHoldJumpMillis;
  double gravityImpulse;
  double jumpImpulse;
  double diveImpulse;
  double jumpTimeMultiplier;

  Map toMap() {
    return {
      "bulletSpeed": bulletSpeed,
      "buttonCost": buttonCost,
      "buttonIncCost": buttonIncCost,
      "maxHoldJumpMillis": maxHoldJumpMillis,
      "gravityImpulse": gravityImpulse,
      "jumpImpulse": jumpImpulse,
      "diveImpulse": diveImpulse,
      "jumpTimeMultiplier": jumpTimeMultiplier,
    };
  }

  Options() {
    this.bulletSpeed = 500.0;
    this.buttonCost = 5;
    this.buttonIncCost = 2;
    this.maxHoldJumpMillis = 2000;
    this.gravityImpulse = 1875.0;
    this.jumpImpulse = 15000.0;
    this.diveImpulse = 20000.0;
    this.jumpTimeMultiplier = 0.0004;
  }

  Options.fromMap(Map map) {
    bulletSpeed = map["bulletSpeed"] ?? 500.0;
    buttonCost = map["buttonCost"] ?? 5;
    buttonIncCost = map["buttonIncCost"] ?? 2;
    maxHoldJumpMillis = map["maxHoldJumpMillis"] ?? 2000;
    gravityImpulse = map["gravityImpulse"] ?? 1875.0;
    jumpImpulse = map["jumpImpulse"] ?? 15000.0;
    diveImpulse = map["diveImpulse"] ?? 20000.0;
    jumpTimeMultiplier = map["jumpTimeMultiplier"] ?? 0.0004;
  }

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("options", JSON.encode(toMap()));
  }

  static Future<Options> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("options");
    if (json == null) {
      return new Options();
    }
    return new Options.fromMap(JSON.decode(json));
  }
}
