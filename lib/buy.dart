import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'buy.g.dart';

enum PlayerButtonState { LOCKED, AVAILABLE, SELECTED }

@JsonSerializable()
class Buy {
  List<String> skinsOwned;
  String selectedSkin;
  int coins;

  Buy() {
    skinsOwned = ['asimov.png'];
    selectedSkin = 'asimov.png';
    coins = 0;
  }

  factory Buy.fromJson(Map<String, dynamic> json) => _$BuyFromJson(json);

  Map<String, dynamic> toJson() => _$BuyToJson(this);

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('buy', json.encode(toJson()));
  }

  static Future<Buy> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString('buy');
    if (jsonStr == null) {
      return new Buy();
    }
    return new Buy.fromJson(json.decode(jsonStr));
  }
}
