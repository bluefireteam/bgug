import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum PlayerButtonState {
  LOCKED, AVALIABLE, SELECTED
}

class PlayerType {
  static const PlayerType Asimov = const PlayerType(1, 'Asimov', 0);
  static const PlayerType Ritchie = const PlayerType(2, 'Ritchie', 20);

  static const List<PlayerType> values = const [Asimov, Ritchie];

  final int id;
  final String name;
  final int cost;

  String get icon => 'assets/images/btns/player_$id.png';
  String get sprite => 'player_$id.png';

  const PlayerType(this.id, this.name, this.cost);

  @override
  String toString() => 'Player.${this.name}';
}

class Player {
  PlayerType type;
  PlayerButtonState state;

  Player(this.type, this.state);
}

final PlayerType Function(String) getPlayer = (str) => PlayerType.values.firstWhere((e) => e.toString() == str);

class Buy {
  List<PlayerType> owned;
  PlayerType selected;
  int coins;

  Buy() {
    owned = [ PlayerType.Asimov ];
    selected = PlayerType.Asimov;
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

  PlayerButtonState _state(PlayerType type) {
    return type == selected ? PlayerButtonState.SELECTED : (owned.contains(type) ? PlayerButtonState.AVALIABLE : PlayerButtonState.LOCKED);
  }

  List<Player> players() {
    return PlayerType.values.map((type) => new Player(type, _state(type))).toList();
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
