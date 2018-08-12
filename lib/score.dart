import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Score {
  List<String> scores;

  Score() {
    scores = [];
  }

  Score.fromMap(Map map) {
    scores = [];
    (map['scores'] as List).forEach((s) => scores.add(s.toString()));
  }

  Map toMap() {
    return {'scores': scores};
  }

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('score', json.encode(toMap()));
  }

  static Future<Score> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString('score');
    if (jsonStr == null) {
      return new Score();
    }
    return new Score.fromMap(json.decode(jsonStr));
  }
}
