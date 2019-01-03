import 'dart:async';

import 'buy.dart';
import 'options.dart';
import 'score.dart';
import 'skin_list.dart';
import 'play_user.dart';

class Data {
  static SkinList skinList;
  static Options options;
  static Score score;
  static Buy buy;

  static PlayUser user;
  static Options currentOptions;

  static Future loadAll() async {
    return Future.wait([
      SkinList.fetch().then((r) => skinList = r),
      Options.fetch().then((r) => options = r),
      Score.fetch().then((r) => score = r),
      Buy.fetch().then((r) => buy = r),
    ]);
  }
}
