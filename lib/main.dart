import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game.dart';
import 'ads.dart';
import 'screens/home_gui.dart';
import 'screens/options_gui.dart';
import 'screens/score_gui.dart';
import 'screens/start_game_gui.dart';

class Main {
  static MyGame game;
}

main() async {
  Ad.startup();
  Flame.audio.disableLog();
  Flame.util.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  runApp(new MaterialApp(
    home: new Scaffold(body: new HomeScreen()),
    routes: {
      '/start': (BuildContext ctx) => new Scaffold(body: new StartGameScreen()),
      '/options': (BuildContext ctx) => new Scaffold(body: new OptionsScreen()),
      '/score': (BuildContext ctx) => new Scaffold(body: new ScoreScreen()),
    },
  ));

  int lastTimestamp;
  Position lastPost;

  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
    ..onTapDown = (TapDownDetails details) {
      lastPost = new Position.fromOffset(details.globalPosition);
      lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
    }
    ..onTapUp = (TapUpDetails details) {
      if (lastTimestamp == null || lastPost == null) {
        return;
      }
      int dt = new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      if (Main.game != null && Main.game.isRunning()) {
        Main.game.input(lastPost, dt);
        lastTimestamp = lastPost = null;
      }
    });
}
