import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Top extends SpriteComponent {
  Top() : super.fromSprite(1.0, BAR_SIZE, Sprite('base_top.png'));

  @override
  bool isHud() => true;

  @override
  void resize(Size size) {
    x = 0.0;
    y = sizeTop(size) - BAR_SIZE;
    width = size.width;
  }
}
