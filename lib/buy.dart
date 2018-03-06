import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum Player {
  Asimov, Ritchie
}

final Player Function(String) getPlayer = (str) => Player.values.firstWhere((e) => e.toString() == str);

class Buy {
  List<Player> owned;
  Player selected;
  int coins;

  Buy() {
    owned = [ Player.Asimov ];
    selected = Player.Asimov;
    coins = 0;
  }

  Buy.fromMap(Map map) {
    owned = map["owned"].toString().split(';').map(getPlayer).toList();
    selected = getPlayer(map["selected"].toString());
    coins = map["coins"];
  }

  Map toMap() {
    return {
      "owned": owned.map((e) => e.toString()).join(';'),
      "selected": selected.toString(),
      "coins": coins,
    };
  }

  Future save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("buy", JSON.encode(toMap()));
  }

  static Future<Buy> fetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("buy");
    if (json == null) {
      return new Buy();
    }
    return new Buy.fromMap(JSON.decode(json));
  }
}
