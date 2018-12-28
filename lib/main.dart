import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game.dart';
import 'screens/home_gui.dart';
import 'screens/options_screen.dart';
import 'screens/score_screen.dart';
import 'screens/start_game_screen.dart';
import 'screens/store_screen.dart';
import 'screens/skins_screen.dart';

class Main {
  static BgugGame game;
}

main() async {
  Flame.audio.disableLog();

  runApp(new MaterialApp(
    home: new Scaffold(body: new HomeScreen()),
    routes: {
      '/start': (BuildContext ctx) => new Scaffold(body: new StartGameScreen()),
      '/options': (BuildContext ctx) => new Scaffold(body: new OptionsScreen()),
      '/score': (BuildContext ctx) => new Scaffold(body: new ScoreScreen()),
      '/store': (BuildContext ctx) => new Scaffold(body: new StoreScreen()),
      '/skins': (BuildContext ctx) => new Scaffold(body: new SkinScreen()),
    },
  ));

  int lastTimestamp;
  Position lastPost;

  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
    ..onTapDown = (TapDownDetails details) {
      lastPost = new Position.fromOffset(details.globalPosition);
      lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
      if (Main.game != null && Main.game.handlingClick()) {
        Main.game.startInput(lastPost, lastTimestamp);
      }
    }
    ..onTapUp = (TapUpDetails details) {
      if (lastTimestamp == null || lastPost == null) {
        return;
      }
      int dt = new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      if (Main.game != null && Main.game.handlingClick()) {
        Main.game.input(lastPost, dt);
        lastTimestamp = lastPost = null;
      }
    });
}
