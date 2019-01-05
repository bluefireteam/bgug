import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';

import '../sfx.dart';
import '../constants.dart';
import '../mixins/has_game_ref.dart';

class _BaseCoin extends AnimationComponent {
  _BaseCoin(double x, double y) : super.sequenced(1.0, 1.0, 'coin.png', 10, textureWidth: 16.0, textureHeight: 16.0) {
    this.x = x;
    this.y = y;
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * sizeTenth(size);
  }
}

class _ExcitedCoin extends _BaseCoin {
  _ExcitedCoin(double x, double y) : super(x, y) {
    animation.stepTime = .005;
    List<Frame> newFrames = [];
    for (int i = 0; i < 5; i++) {
      newFrames.addAll(animation.frames);
    }
    animation.frames = newFrames;
    animation.loop = false;
  }

  @override
  bool destroy() => animation.done();
}

class Coin extends _BaseCoin with HasGameRef {
  bool collected = false;

  Coin(double x, double y) : super(x, y) {
    this.animation.stepTime = .15;
  }

  @override
  void update(double t) {
    super.update(t);

    if (gameRef != null && this.toRect().overlaps(gameRef.player.toRect())) {
      this.collected = true;
      gameRef.currentCoins++;
      Sfx.play('gem_collect.wav');
      gameRef.addLater(_ExcitedCoin(x, y));
    }
  }

  @override
  bool destroy() => collected;
}
