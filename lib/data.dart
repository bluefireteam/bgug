import 'dart:async';

import 'options.dart';
import 'score.dart';
import 'buy.dart';

class Data {
  static Options options;
  static Score score;
  static Buy buy;

  static Future loadAll() async {
    return Future.wait([
      Options.fetch().then((r) => options = r),
      Score.fetch().then((r) => score = r),
      Buy.fetch().then((r) => buy = r),
    ]);
  }
}