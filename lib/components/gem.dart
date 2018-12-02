import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';
import '../mixins/has_game_ref.dart';

class Gem extends SpriteComponent with HasGameRef {
  bool collected = false;
  double Function(Size) yGen;

  Gem(double x, this.yGen) : super.fromSprite(1.0, 1.0, new Sprite('gem.png')) {
    this.x = x;
  }

  @override
  void update(double t) {
    super.update(t);

    if (this.toRect().overlaps(gameRef.player.toRect())) {
      this.collect();
      gameRef.points++;
      Flame.audio.play('gem_collect.wav');
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * size_tenth(size);
    y = yGen(size);
  }

  void collect() {
    collected = true;
  }

  @override
  bool destroy() => collected;
}