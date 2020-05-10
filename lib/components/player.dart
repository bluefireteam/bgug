import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';

import '../audio.dart';
import '../constants.dart';
import '../data.dart';
import '../util.dart';

class Player extends PositionComponent {
  Map<String, Animation> animations;
  Position velocity = Position(320.0, 0.0);
  double y0, yf;
  String state;

  Impulse jumpImpulse;
  Impulse diveImpulse;

  Player() {
    jumpImpulse = Impulse(-1 * Data.currentOptions.jumpImpulse);
    diveImpulse = Impulse(Data.currentOptions.diveImpulse);

    final skinSpritePath = 'skins/' + Data.buy.selectedSkin;
    animations = <String, Animation>{};
    animations['running'] = Animation.sequenced(skinSpritePath, 8, textureWidth: 16.0, textureHeight: 18.0)..stepTime = 0.0375;
    animations['dead'] = Animation.sequenced(skinSpritePath, 3, textureWidth: 16.0, textureX: 16.0 * 8, textureHeight: 18.0)..stepTime = 0.075;
    state = 'running';
  }

  @override
  void render(Canvas canvas) {
    // prepareCanvas(canvas); TODO use this with the anchor = center

    canvas.translate(x, y);

    canvas.translate(width / 2, height / 2);
    canvas.rotate(angle);
    canvas.translate(-width / 2, -height / 2);

    animations[state].getSprite().render(canvas, width: width, height: height);
  }

  @override
  void update(double t) {
    super.update(t);

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
      Audio.playSfx('jump.wav');
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
      Audio.playSfx('death.wav');
    }
  }
}
