import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_gamepad/flame_gamepad.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Error thrown! Logging $details');
    FlutterError.dumpErrorToConsole(details);
    Crashlytics.instance.onError(details);
  };

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

  int getDt() {
    return new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
  }

  bool handlingInput() {
    return Main.game != null && Main.game.handlingClick();
  }

  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
    ..onTapDown = (TapDownDetails details) {
      lastPost = new Position.fromOffset(details.globalPosition);
      lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
      if (handlingInput()) {
        Main.game.startInput(lastPost, lastTimestamp);
      }
    }
    ..onTapCancel = () {
      if (lastTimestamp == null || lastPost == null) {
        return;
      }
      if (handlingInput()) {
        Main.game.input(lastPost, getDt());
        lastTimestamp = lastPost = null;
      }
    }
    ..onTapUp = (TapUpDetails details) {
      if (lastTimestamp == null || lastPost == null) {
        return;
      }
      if (handlingInput()) {
        Main.game.input(lastPost, getDt());
        lastTimestamp = lastPost = null;
      }
    });

  var gamePadController = new FlameGamepad();
  gamePadController.setListener((String evtType, String key) {
    int dt;
    if (evtType == GAMEPAD_BUTTON_DOWN && key == GAMEPAD_BUTTON_A) {
      lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
    } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_BUTTON_A) {
      dt = new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
    }

    if (Main.game != null) {
      Main.game.gamepadInput(evtType, key, dt);
    }
  });

  // Flame.util.addGestureRecognizer(new ImmediateMultiDragGestureRecognizer()..onStart = (Offset position) => new MyDrag());

  WidgetsBinding.instance.addObserver(new _Handler());
}
