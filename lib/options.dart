import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Options {
  double bulletSpeed;

  Map toMap() {
    return {"bulletSpeed": bulletSpeed};
  }

  Options() {
    this.bulletSpeed = 500.0;
  }

  Options.fromMap(Map map) {
    bulletSpeed = map["bulletSpeed"];
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
