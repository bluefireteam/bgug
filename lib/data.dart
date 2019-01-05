import 'dart:async';
import 'dart:convert';

import 'package:bgug/screens/merge_resolution.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:play_games/play_games.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buy.dart';
import 'options.dart';
import 'play_user.dart';
import 'score.dart';
import 'skin_list.dart';

part 'data.g.dart';

@JsonSerializable()
class SavedData {
  Options options;
  Score score;
  Buy buy;

  bool showTutorial;

  SavedData() {
    showTutorial = true;
    options = new Options();
    score = new Score();
    buy = new Buy();
  }

  factory SavedData.fromJson(Map<String, dynamic> json) => _$SavedDataFromJson(json);

  Map<String, dynamic> toJson() => _$SavedDataToJson(this);
}

class Data {
  static const SAVE_NAME = 'bgug.data.v3';

  static SkinList skinList;
  static SavedData _data;

  static Options get options => _data.options;

  static Score get score => _data.score;

  static Buy get buy => _data.buy;

  static PlayUser user;
  static Options currentOptions;
  static bool pristine = true;

  static Future loadHardData() {
    return SkinList.fetch().then((r) => skinList = r);
  }

  static Future loadLocalSoftData() {
    pristine = true;
    return Data.fetch(true).then((r) {
      return _data = r;
    });
  }

  static bool get hasData => _data != null;
  static bool get playGames => user != null;

  static Future<bool> getAndToggleShowTutorial() async {
    if (_data.showTutorial) {
      _data.showTutorial = false;
      await save();
      return true;
    }
    return false;
  }

  static Future save() async {
    pristine = false;
    String data = json.encode(_data.toJson());

    if (playGames) {
      await PlayGames.saveSnapshot(SAVE_NAME, data);
      return await PlayGames.openSnapshot(SAVE_NAME);
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(SAVE_NAME, data);
    }
  }

  static Future<SavedData> fetch(bool createNew) async {
    if (playGames) {
      return await _fetchFromPlayGames(createNew);
    } else {
      return await _fetchFromSharedPreferences(createNew);
    }
  }

  static Future<SavedData> _fetchFromPlayGames(bool createNew) async {
    Snapshot snap = await PlayGames.openSnapshot(SAVE_NAME);
    if (snap.content == null || snap.content.trim().isEmpty) {
      return createNew ? new SavedData() : null;
    }
    return SavedData.fromJson(json.decode(snap.content));
  }

  static Future<SavedData> _fetchFromSharedPreferences(bool createNew) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString(SAVE_NAME);
    if (jsonStr == null) {
      return createNew ? new SavedData() : null;
    }
    return new SavedData.fromJson(json.decode(jsonStr));
  }

  static void forceData(SavedData data) {
    pristine = false;
    _data = data;
  }

  static MergeResolution merge(SavedData cloudData) {
    return MergeResolution(_data, cloudData);
  }
}
