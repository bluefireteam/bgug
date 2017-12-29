import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

math.Random random = new math.Random();

class Bullet extends AnimationComponent {
  static const double SPEED = 500.0;

  Bullet(Position p) : super(64.0, 64.0, new Animation.sequenced('bullet.png', 3, textureWidth: 16.0, textureHeight: 16.0)..stepTime = 0.075) {
    this.x = p.x;
    this.y = p.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    this.x -= SPEED * dt;
  }

  @override
  bool destroy() {
    return this.x < - this.width;
  }
}

class ShooterCane extends PositionComponent {

  static final Paint paint = new Paint()..color = const Color(0xFF626262);

  ShooterCane() {
    this.y = 0.0;
    this.width = 2.0;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    c.drawRect(new Rect.fromLTWH(0.0, 0.0, width, height), paint);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    this.x = size.width - 8.0;
    this.height = size.height;
  }

  @override
  bool isHud() {
    return true;
  }
}

class Shooter extends SpriteComponent {

  static const double SPEED = 120.0;

  Size size;
  String kind;
  double yi, yf;
  double step;
  double clock = 0.0;
  String action;
  bool down = true;

  Animation shooting = new Animation.sequenced('shooter.png', 2, textureWidth: 32.0, textureX: 32.0);

  Shooter(this.kind) : super.fromSprite(32.0, 46.0, new Sprite('shooter.png', width: 32.0));

  @override
  void render(Canvas c) {
    if (action == 'shooting') {
      if (shooting.loaded() && x != null && y != null) {
        prepareCanvas(c);
        shooting.getSprite().render(c, width, height);
      }
    } else {
      super.render(c);
    }
  }

  @override
  void update(double dt) {
    clock += dt;
    if (clock > 1.0) {
      clock -= 1.0;
      nextAction();
    }

    if (action == 'moveUp') {
      moveUp(dt, -SPEED);
    } else if (action == 'moveDown') {
      moveDown(dt, SPEED);
    } else if (action == 'shoot') {
      // shoot animation?
    }
  }

  bool shoot() {
    if (action == 'shoot') {
      action = '';
      return true;
    }
    return false;
  }

  void moveDown(double dt, double speed) {
    double currentBit = (y - yi) % step;
    var dy = dt * speed;
    if (currentBit + dy >= step) {
      dy = step - currentBit;
      action = '';
    }
    y += dy;
  }

  void moveUp(double dt, double speed) {
    double currentBit = (y - yf) % step;
    while (currentBit > 0) {
      currentBit -= step;
    }
    var dy = dt * speed;
    if (currentBit + dy <= -step) {
      dy = - step - currentBit;
      action = '';
    }
    y += dy;
  }

  void nextAction() {
    if (action == 'shooting') {
      action = 'shoot';
    } else if (random.nextDouble() < 0.25) {
      action = 'shooting';
      shooting.lifeTime = 0.0;
    } else {
      if (y <= yi) {
        y = yi;
        down = true;
      } else if (y >= yf) {
        y = yf;
        down = false;
      }
      action = down ? 'moveDown' : 'moveUp';
    }
  }

  @override
  void resize(Size size) {
    this.size = size;
    x = size.width - width;

    step = size.height / 10;
    height = step;
    action = '';
    if (kind == 'up') {
      yi = step;
      yf = step * 4;
      y = yi;
    } else {
      yi = step * 5;
      yf = step * 8;
      y = yf;
    }
  }

  @override
  bool isHud() {
    return true;
  }
}

class Block extends SpriteComponent {

  int slot;

  Block(this.slot) : super.fromSprite(16.0, 16.0, new Sprite('block.png'));

  @override
  void resize(Size size) {
    this.width = this.height = size.height / 10.0;
    this.x = size.width - this.width;
    this.y = this.slot * this.height;
  }

  @override
  bool isHud() {
    return true;
  }
}