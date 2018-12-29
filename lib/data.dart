import 'dart:async';

import 'package:flame/sprite.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'skin_list.dart';
import 'options.dart';
import 'score.dart';
import 'buy.dart';

class Data {
  static SkinList skinList;
  static Options options;
  static Score score;
  static Buy buy;
  static GoogleSignInAccount user;

  static Future loadAll() async {
    return Future.wait([
      SkinList.fetch().then((r) => skinList = r),
      Options.fetch().then((r) => options = r),
      Score.fetch().then((r) => score = r),
      Buy.fetch().then((r) => buy = r),
    ]);
  }
}