import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Gem extends SpriteComponent {
  bool collected = false;
  double Function(Size) yGen;

  Gem(double x, this.yGen) : super.fromSprite(1.0, 1.0, new Sprite('gem.png')) {
    this.x = x;
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * tenth(size);
    y = yGen(size);
  }

  void collect() {
    collected = true;
  }

  @override
  bool destroy() => collected;
}