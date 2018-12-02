import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Floor extends SpriteComponent {
  Floor() : super.fromSprite(1.0, BAR_SIZE, new Sprite('base_bottom.png'));

  @override
  bool isHud() {
    return true;
  }

  @override
  void resize(Size size) {
    x = 0.0;
    y = size_bottom(size);
    width = size.width;
  }
}