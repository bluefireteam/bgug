import 'dart:ui';

import 'package:flame/components/component.dart';

class Tutorial extends SpriteComponent {
  static const FRAC = 192.0 / 162.0;

  bool _remove = false;

  Tutorial() : super.rectangle(1.0, 1.0, 'tutorial.png');

  @override
  void resize(Size size) {
    width = 2 * size.width / 3;
    height = width / FRAC;

    x = (size.width - width) / 2;
    y = (size.height - height) / 2;
  }

  @override
  int priority() => 12;

  @override
  bool destroy() => _remove;

  void remove() {
    _remove = true;
  }
}
