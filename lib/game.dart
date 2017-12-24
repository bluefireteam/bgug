import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class Floor extends SpriteComponent {

  Floor() : super.fromSprite(1.0, 16.0, new Sprite('base.png')) {
    this.x = 0.0;
  }

  @override
  void resize(Size size) {
    this.y = size.height - 16.0;
    this.width = size.width;
  }
}

class Player extends AnimationComponent {

  Size size = new Size(1.0, 1.0);

  Player(double x, double y) : super.sequenced(64.0, 72.0, 'player.png', 8, textureWidth: 16.0, textureHeight: 18.0) {
    this.x = x;
    this.y = y;
    this.stepTime = 0.075;
  }

  @override
  void update(double t) {
    this.x += 60 * t;
    super.update(t);
  }

  @override
  bool destroy() {
    return x > size.width;
  }

  @override
  void resize(Size size) {
    this.size = size;
    this.y = size.height - 72.0 - 16.0;
  }
}

class MyGame extends BaseGame {

  bool _running = false;

  bool isRunning() {
    return this._running;
  }

  void setRunning(bool running) {
    this._running = running;
  }

  start() async {
    this.components.add(new Floor());
    this.components.add(new Player(0.0, 0.0));

//    Flame.audio.loop('music.ogg');
    this._running = true;
  }

  input(double x, double y) {
    // TODO
  }

  @override
  void update(double dt) {
    if (!isRunning()) {
      return;
    }

    super.update(dt);

    if (!components.any((c) => c is Player)) {
      this.setRunning(false);
    }
  }

  // TODO BaseGame should do this
  @override
  void resize(Size size) {
    this.components.forEach((c) => c.resize(size));
  }
}
