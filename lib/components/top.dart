import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Top extends SpriteComponent {
  Top() : super.fromSprite(1.0, BAR_SIZE, new Sprite('base.png'));

  @override
  bool isHud() {
    return true;
  }

  @override
  void resize(Size size) {
    x = 0.0;
    y = 0.0;
    width = size.width;
  }
}