import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_gamepad/flame_gamepad.dart';

import 'game.dart';
import 'audio.dart';
import 'screens/home_screen.dart';
import 'screens/options_screen.dart';
import 'screens/score_screen.dart';
import 'screens/leaderboards_screen.dart';
import 'screens/start_game_screen.dart';
import 'screens/store_screen.dart';
import 'screens/skins_screen.dart';
import 'screens/credits_screen.dart';

class Main {
  static BgugGame game;
}

class _Handler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Audio.resume();
    } else {
      Audio.pause();
    }
  }
}

class MyDrag extends Drag {

  Position lastDragPos;

  @override
  void update(DragUpdateDetails details) {
    lastDragPos = new Position.fromOffset(details.globalPosition);
    Main.game?.dragTo(lastDragPos);
  }

  @override
  void end(DragEndDetails details) {
    if (lastDragPos != null) {
      Main.game?.endDrag(lastDragPos);
      lastDragPos = null;
    }
  }
}

main() async {
  Flame.audio.disableLog();

  runApp(new MaterialApp(
    home: new Scaffold(body: HomeScreen()),
    routes: {
      '/start': (BuildContext ctx) => Scaffold(body: StartGameScreen()),
      '/options': (BuildContext ctx) => Scaffold(body: OptionsScreen()),
      '/score': (BuildContext ctx) => Scaffold(body: ScoreScreen()),
      '/leaderboards': (BuildContext ctx) => Scaffold(body: LeaderboardsScreen()),
      '/store': (BuildContext ctx) => Scaffold(body: StoreScreen()),
      '/skins': (BuildContext ctx) => Scaffold(body: SkinScreen()),
      '/credits': (BuildContext ctx) => Scaffold(body: CreditsScreen()),
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

  var gamePadController = new FlameGamepad();
  gamePadController.setListener((String evtType, String key) {
    if (evtType == GAMEPAD_BUTTON_DOWN && key == GAMEPAD_BUTTON_A) {
      lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
      Main.game.hud.startGauge();
    } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_BUTTON_A) {
      int dt = new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
      Main.game.jumpInput(dt);
      Main.game.hud.clearGauge();
    } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_DPAD_DOWN) {
      Main.game.diveInput();
    } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_BUTTON_X) {
      Main.game.blockInput();
    }
  });

  Flame.util.addGestureRecognizer(new ImmediateMultiDragGestureRecognizer()..onStart = (Offset position) => new MyDrag());

  WidgetsBinding.instance.addObserver(new _Handler());
}
