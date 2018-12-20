import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';
import '../mixins/has_game_ref.dart';

class GemJuiceEngine {
  static const MAX_TIME = 1;

  double t = 0;
  Position start, end;
  double r, rEnd;
  double theta, thetaEnd;

  GemJuiceEngine({this.start, this.end}) {
    Position diff = end.minus(start);
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

class GemMoving extends SpriteComponent with HasGameRef {
  GemJuiceEngine juice;
  bool done = false;

  GemMoving(this.juice) : super.fromSprite(1.0, 1.0, new Sprite('gem.png')) {
    this.x = juice.x;
    this.y = juice.y;
  }

  @override
  void update(double t) {
    super.update(t);

    juice.update(t);
    x = juice.x;
    y = juice.y;

    if (juice.isComplete) {
      gameRef.points++;
      Flame.audio.play('gem_collect.wav');
      done = true;
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * size_tenth(size);
  }

  @override
  int priority() => 10;

  @override
  bool isHud() => true;

  @override
  bool destroy() => done;
}

class Gem extends SpriteComponent with HasGameRef {
  bool complete = false;
  double Function(Size) yGen;

  Gem(double x, this.yGen) : super.fromSprite(1.0, 1.0, new Sprite('gem.png')) {
    this.x = x;
  }

  @override
  void update(double t) {
    super.update(t);

    if (this.toRect().overlaps(gameRef.player.toRect())) {
      Position start = this.toPosition().minus(gameRef.camera);
      Position end = gameRef.hud.gemPosition;
      GemJuiceEngine juice = new GemJuiceEngine(start: start, end: end);
      gameRef.addLater(new GemMoving(juice));
      complete = true;
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * size_tenth(size);
    y = yGen(size);
  }

  @override
  bool destroy() => complete;
}
