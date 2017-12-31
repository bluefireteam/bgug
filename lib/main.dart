import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gui.dart';

main() async {
  Flame.audio.disableLog();
  Flame.audio.loadAll([ 'death.wav', 'gem_collect.wav', 'jump.wav', 'laser_load.wav', 'laser_shoot.wav' ]).then((files) => print('Done loading ' + files.length.toString() + ' audios.'));
  Flame.util.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  runApp(new MaterialApp(
      home: new Scaffold(body: new HomeScreen())
  ));
}