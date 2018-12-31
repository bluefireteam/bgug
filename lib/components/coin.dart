import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/flame.dart';

import '../constants.dart';
import '../mixins/has_game_ref.dart';

class Coin extends AnimationComponent with HasGameRef {
  bool collected = false;

  Coin(double x, double y) : super.sequenced(1.0, 1.0, 'coin.png', 10, textureWidth: 16.0, textureHeight: 16.0) {
    this.x = x;
    this.y = y;
    this.animation.stepTime = .150;
  }

  @override
  void update(double t) {
    super.update(t);

    if (gameRef != null && this.toRect().overlaps(gameRef.player.toRect())) {
      this.collected = true;
      gameRef.currentCoins++;
      Flame.audio.play('gem_collect.wav');
    }
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * sizeTenth(size);
  }

  @override
  bool destroy() => collected;
}
