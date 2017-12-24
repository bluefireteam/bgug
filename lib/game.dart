import 'dart:ui';

import 'math_util.dart';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class Floor extends SpriteComponent {
  Floor(double width) : super.fromSprite(1.0, 16.0, new Sprite('base.png')) {
    this.x = 0.0;
    this.width = width;
  }

  @override
  void resize(Size size) {
    this.y = size.height - 16.0;
  }
}

class Top extends SpriteComponent {
  Top(double width) : super.fromSprite(1.0, 16.0, new Sprite('base.png')) {
    this.x = 0.0;
    this.y = 0.0;
    this.width = width;
  }
}

class Player extends AnimationComponent {

  Point velocity = new Point(180.0, 0.0);
  Impulse impulse = new Impulse(20000.0);
  double y0, worldSize;

  Player(double x, double y, this.worldSize) : super.sequenced(64.0, 72.0, 'player.png', 8, textureWidth: 16.0, textureHeight: 18.0) {
    this.x = x;
    this.y = y;
    this.y0 = 0.0;
    this.stepTime = 0.075 / 2.0;
  }

  @override
  void update(double t) {
    velocity.y -= impulse.tick(t);
    if (falling()) {
      velocity.y += 7500.0 * t; // gravity
    }

    x += velocity.x * t;
    y += velocity.y * t;
    if (y > y0) {
      y = y0;
      velocity.y = 0.0;
    }
    super.update(t);
  }

  bool falling() {
    return y < y0;
  }

  @override
  bool destroy() {
    return x > worldSize;
  }

  @override
  void resize(Size size) {
    y0 = size.height - 72.0 - 16.0;
  }

  void jump() {
    if (!falling()) {
      impulse.impulse(0.1);
    } else
      print('Can\'t jump in the air, mate');
  }
}

class MyGame extends BaseGame {

  static const double WORLD_SIZE = 1000.0;

  Size size;
  Point camera = new Point(0.0, 0.0);
  bool _running = false;

  bool isRunning() {
    return this._running;
  }

  void setRunning(bool running) {
    this._running = running;
  }

  void start() {
    components.add(new Top(WORLD_SIZE));
    components.add(new Floor(WORLD_SIZE));
    components.add(new Player(0.0, 0.0, WORLD_SIZE));

    _running = true;
  }

  Player getPlayer() {
    return components.firstWhere((c) => c is Player, orElse: () => null) as Player;
  }

  void input(double x, double y) {
    getPlayer()?.jump();
  }

  @override
  void update(double dt) {
    if (!isRunning()) {
      return;
    }

    super.update(dt);
    cameraFollow(getPlayer());

    if (getPlayer() == null) {
      this.setRunning(false);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) {
      canvas.translate(-camera.x, -camera.y);
      comp.render(canvas);
      canvas.restore();
      canvas.save();
    });
    canvas.restore();
  }

  void cameraFollow(Player c) {
    if (c != null) {
      camera.x = c.x - size.width / 2 + c.width/2;
      if (camera.x < 0.0) {
        camera.x = 0.0;
      } else if (camera.x > WORLD_SIZE - size.width) {
        camera.x = WORLD_SIZE - size.width;
      }
    }
  }

  // TODO BaseGame should do this
  @override
  void resize(Size size) {
    this.size = size;
    this.components.forEach((c) => c.resize(size));
  }
}
