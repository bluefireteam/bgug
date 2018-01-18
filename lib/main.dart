import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gui.dart';
import 'options_gui.dart';
import 'score_gui.dart';

main() async {
  Flame.audio.disableLog();
  Flame.util.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  runApp(new MaterialApp(
    home: new Scaffold(body: new HomeScreen()),
    routes: {
      '/options': (BuildContext ctx) => new Scaffold(body: new OptionsScreen()),
      '/score': (BuildContext ctx) => new Scaffold(body: new ScoreScreen()),
    },
  ));
}
