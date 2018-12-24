import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Options {
  bool showTutorial;
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
      'showTutorial': showTutorial,
      'bulletSpeed': bulletSpeed,
      'buttonCost': buttonCost,
      'buttonIncCost': buttonIncCost,
      'maxHoldJumpMillis': maxHoldJumpMillis,
      'gravityImpulse': gravityImpulse,
      'jumpImpulse': jumpImpulse,
      'diveImpulse': diveImpulse,
      'jumpTimeMultiplier': jumpTimeMultiplier,
    };
  }

  Options() {
    this.showTutorial = true;
    this.bulletSpeed = 500.0;
    this.buttonCost = 5;
    this.buttonIncCost = 2;
    this.maxHoldJumpMillis = 500;
    this.gravityImpulse = 1875.0;
    this.jumpImpulse = 7000.0;
    this.diveImpulse = 20000.0;
    this.jumpTimeMultiplier = 0.0004;
  }

  Options.fromMap(Map map) {
    showTutorial = map['showTutorial'] ?? true;
    bulletSpeed = map['bulletSpeed'] ?? 500.0;
    buttonCost = map['buttonCost'] ?? 5;
    buttonIncCost = map['buttonIncCost'] ?? 2;
    maxHoldJumpMillis = map['maxHoldJumpMillis'] ?? 500;
    gravityImpulse = map['gravityImpulse'] ?? 1875.0;
    jumpImpulse = map['jumpImpulse'] ?? 7000.0;
    diveImpulse = map['diveImpulse'] ?? 20000.0;
    jumpTimeMultiplier = map['jumpTimeMultiplier'] ?? 0.0004;
  }

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('options', json.encode(toMap()));
  }

  static Future<Options> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString('options');
    if (jsonStr == null) {
      return new Options();
    }
    return new Options.fromMap(json.decode(jsonStr));
  }

  Future<bool> getAndToggleShowTutorial() async {
    if (showTutorial) {
      showTutorial = false;
      await save();
      return true;
    }
    return false;
  }
}
