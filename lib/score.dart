import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'score.g.dart';

@JsonSerializable()
class Score {
  List<String> scores;

  Score() {
    scores = [];
  }

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreToJson(this);

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('score.v2', json.encode(toJson()));
  }

  static Future<Score> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString('score.v2');
    if (jsonStr == null) {
      return new Score();
    }
    return new Score.fromJson(json.decode(jsonStr));
  }
}
