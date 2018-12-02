import 'dart:ui';

import 'package:flame/components/animation_component.dart';

import '../constants.dart';

class Coin extends AnimationComponent {
  bool collected = false;

  Coin(double x, double y) : super.sequenced(1.0, 1.0, 'coin.png', 6, textureWidth: 18.0, textureHeight: 20.0) {
    this.x = x;
    this.y = y;
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * tenth(size);
  }

  @override
  bool destroy() => collected;
}