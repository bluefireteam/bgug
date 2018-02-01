import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Options {
  double bulletSpeed;
  int buttonCost;
  int buttonIncCost;

  Map toMap() {
    return {
      "bulletSpeed": bulletSpeed,
      "buttonCost": buttonCost,
      "buttonIncCost": buttonIncCost
    };
  }

  Options() {
    this.bulletSpeed = 500.0;
    this.buttonCost = 5;
    this.buttonIncCost = 2;
  }

  Options.fromMap(Map map) {
    bulletSpeed = map["bulletSpeed"];
    buttonCost = map["buttonCost"];
    buttonIncCost = map["buttonIncCost"];
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
