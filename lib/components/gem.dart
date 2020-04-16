import 'dart:ui';
import 'dart:math' as math;

import 'package:bgug/game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../audio.dart';
import '../constants.dart';

class GemJuiceEngine {
  static const MAX_TIME = 1;

  double t = 0;
  Position start, end;
  double r, rEnd;
  double theta, thetaEnd;

  GemJuiceEngine({this.start, this.end}) {
    final diff = end.minus(start);
    r = 0;
    rEnd = diff.length();
    theta = 0;
    thetaEnd = (2 * math.pi + math.atan2(end.y, end.x)) % (2 * math.pi);
  }

  void update(double dt) {
    t += dt;
    r = math.pow(t / MAX_TIME, 2) * rEnd;
    if (r > rEnd) {
      r = rEnd;
    }

    theta += dt * thetaEnd / MAX_TIME;
    if (theta > thetaEnd) {
      theta = thetaEnd;
    }
  }

  double get x => start.x + r * math.cos(theta);

  double get y => start.y + r * math.sin(theta);

  bool get isComplete => r >= rEnd;
}

class GemMoving extends SpriteComponent with HasGameRef<BgugGame> {
  GemJuiceEngine juice;
  bool done = false;

  GemMoving(this.juice) : super.fromSprite(1.0, 1.0, Sprite('gem.png')) {
    x = juice.x;
    y = juice.y;
  }

  @override
  void update(double t) {
    super.update(t);

    juice.update(t);
    x = juice.x;
    y = juice.y;

    if (juice.isComplete) {
      gameRef.gems++;
      gameRef.totalGems++;
      Audio.playSfx('gem_collect.wav');
      done = true;
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * sizeTenth(size);
  }

  @override
  int priority() => 10;

  @override
  bool isHud() => true;

  @override
  bool destroy() => done;
}

class Gem extends SpriteComponent with HasGameRef<BgugGame> {
  bool complete = false;

  Gem(double x, double y) : super.fromSprite(1.0, 1.0, Sprite('gem.png')) {
    this.x = x;
    this.y = y;
  }

  @override
  void update(double t) {
    super.update(t);

    if (toRect().overlaps(gameRef.player.toRect())) {
      final start = toPosition().minus(gameRef.camera);
      final end = gameRef.hud.gemPosition;
      final juice = GemJuiceEngine(start: start, end: end);
      gameRef.addLater(GemMoving(juice));
      complete = true;
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * sizeTenth(size);
  }

  @override
  bool destroy() => complete;
}
