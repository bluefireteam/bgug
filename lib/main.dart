import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/animation_component.dart';

main() async {
  Flame.audio.disableLog();
  Flame.util.fullScreen();

//  Flame.audio.loop('music.ogg');

  var game = new MyGame()..start();
  window.onPointerDataPacket = (packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}

class Player extends AnimationComponent {

  Size dimension;

  Player(this.dimension, double x, double y) : super.sequenced(64.0, 72.0, 'player.png', 8, textureWidth: 16.0, textureHeight: 18.0) {
    this.x = x;
    this.y = y;
    this.stepTime = 0.4;
  }

  @override
  void update(double t) {
    this.x += 15 * t;
    if (x > dimension.height) {
      x = 0.0;
    }
    super.update(t);
  }
}

class MyGame extends BaseGame {

  @override
  start() async {
    super.start();

    Size dimension = await Flame.util.initialDimensions();
    this.components.add(new Player(dimension, 200.0, 200.0));
  }

  input(double x, double y) {
    // TODO
  }
}
