import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Score {
  List<String> scores;

  Score() {
    scores = [];
  }

  Score.fromMap(Map map) {
    scores = map["scores"];
  }

  Map toMap() {
    return {"scores": scores};
  }

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("score", JSON.encode(toMap()));
  }

  static Future<Score> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("score");
    if (json == null) {
      return new Score();
    }
    return new Score.fromMap(JSON.decode(json));
  }
}
