import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';

import '../constants.dart';
import '../data.dart';
import '../util.dart';

class Player extends PositionComponent {
  Map<String, Animation> animations;
  Position velocity = new Position(320.0, 0.0);
  double y0, yf;
  String state;

  Impulse jumpImpulse;
  Impulse diveImpulse;

  Player() {
    jumpImpulse = new Impulse(-1 * Data.currentOptions.jumpImpulse);
    diveImpulse = new Impulse(Data.currentOptions.diveImpulse);

    String skinSpritePath = 'skins/' + Data.buy.selectedSkin;
    animations = new Map<String, Animation>();
    animations['running'] = new Animation.sequenced(skinSpritePath, 8, textureWidth: 16.0)..stepTime = 0.0375;
    animations['dead'] = new Animation.sequenced(skinSpritePath, 3, textureWidth: 16.0, textureX: 16.0 * 8)..stepTime = 0.075;
    state = 'running';
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animations[state].getSprite().render(canvas, width, height);
  }

  @override
  void update(double t) {
    animations[state].update(t);

    if (dead()) {
      return;
    }

    x += velocity.x * t;

    double accY = jumpImpulse.tick(t) + diveImpulse.tick(t);
    if (falling()) {
      accY += Data.currentOptions.gravityImpulse;
    }

    y += accY * t * t / 2 + velocity.y * t;
    velocity.y += accY * t;

    if (y > y0) {
      y = y0;
      clearVerticalSpeed();
    } else if (y < yf) {
      y = yf;
      clearVerticalSpeed();
    }
  }

  void clearVerticalSpeed() {
    velocity.y = 0.0;
    jumpImpulse.clear();
    diveImpulse.clear();
  }

  bool dead() {
    return state == 'dead';
  }

  bool falling() {
    return y < y0;
  }

  @override
  void resize(Size size) {
    height = sizeTenth(size);
    width = 48.0 / 54.0 * height;
    y = y0 = sizeBottom(size) - height;
    yf = sizeTop(size);
  }

  void jump(int dt) {
    if (!falling()) {
      jumpImpulse.impulse(Data.currentOptions.jumpTimeMultiplier * dt);
      Flame.audio.play('jump.wav');
    }
  }

  void dive() {
    if (falling()) {
      diveImpulse.impulse(0.1);
    }
  }

  void die() {
    if (!dead()) {
      state = 'dead';
      Flame.audio.play('death.wav');
    }
  }
}
