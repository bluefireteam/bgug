import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flutter/services.dart';

import 'gui.dart';
import 'package:flutter/src/widgets/binding.dart';
import 'package:flutter/src/material/app.dart';
import 'package:flutter/src/material/scaffold.dart';

main() async {
  Flame.audio.disableLog();
//  Flame.util.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  var game = new MyGame();
  window.onPointerDataPacket = (packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };

  runApp(new MaterialApp(
      home: new Scaffold(body: new HomeScreen(game))
  ));
}

class Floor extends SpriteComponent {
  Floor(Size dim) : super.fromSprite(dim.width, 16.0, new Sprite('base.png')) {
    this.x = 0.0;
    this.y = dim.height - 16.0;
  }
}

class Player extends AnimationComponent {

  Size dimension;

  Player(this.dimension, double x, double y) : super.sequenced(64.0, 72.0, 'player.png', 8, textureWidth: 16.0, textureHeight: 18.0) {
    this.x = x;
    this.y = y;
    this.stepTime = 0.15;
  }

  @override
  void update(double t) {
    this.x += 30 * t;
    if (x > dimension.width) {
      x = 0.0;
    }
    super.update(t);
  }
}

class MyGame extends BaseGameWidget {

  bool running = false;

  start() async {
    // TODO consider both fullScreen and orientation for getDimensions
    Size _dimension = await Flame.util.initialDimensions();
    Size dimension = new Size(_dimension.height, _dimension.width);

    this.components.add(new Floor(dimension));
    this.components.add(new Player(dimension, 0.0, dimension.height - 72.0 - 16.0));

//    Flame.audio.loop('music.ogg');
    this.running = true;
  }

  input(double x, double y) {
    // TODO
  }
}
