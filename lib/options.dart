import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'options.g.dart';

@JsonSerializable()
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

  int mapSize;
  bool hasGuns;
  bool gunRespawn;

  bool get hasLimit => mapSize != -1;

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
    this.mapSize = -1; // infinite
    this.hasGuns = true;
    this.gunRespawn = false;
  }

  factory Options.fromJson(Map<String, dynamic> json) => _$OptionsFromJson(json);
  Map<String, dynamic> toJson() => _$OptionsToJson(this);

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('options.v2', json.encode(toJson()));
  }

  static Future<Options> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString('options.v2');
    if (jsonStr == null) {
      return new Options();
    }
    return new Options.fromJson(json.decode(jsonStr));
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
