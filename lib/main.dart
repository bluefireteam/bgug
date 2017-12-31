import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gui.dart';

main() async {
  Flame.audio.disableLog();

  Flame.audio.loadAll([ 'death.wav', 'gem_collect.wav', 'jump.wav', 'laser_load.wav', 'laser_shoot.wav', 'music.wav' ]).then((audios) => print('Done loading ' + audios.length.toString() + ' audios.'));
  Flame.images.loadAll([ 'base.png', 'bg.png', 'block.png', 'bullet.png', 'gem.png', 'obstacle.png', 'player.png', 'shooter.png' ]).then((images) => print('Done loading ' + images.length.toString() + ' images.'));

  Flame.util.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  runApp(new MaterialApp(
      home: new Scaffold(body: new HomeScreen())
  ));
}