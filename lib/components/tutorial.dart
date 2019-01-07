import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

class Tutorial extends PositionComponent {
  static const FRAC = 192.0 / 162.0;

  static final Sprite p1 = new Sprite('tutorial.png');
  static final Sprite p2 = new Sprite('tutorial-2.png');

  int status = 0; // 0, 1 pages ; 2+ hide

  @override
  void resize(Size size) {
    width = (2 * size.width / 3) - 10;
    height = (width / FRAC) -5;

    x = ((size.width - width) / 2) + 5;
    y = ((size.height - height) / 2) + 5;
  }

  @override
  int priority() => 12;

  @override
  bool destroy() => status >= 2;

  bool tap() {
    status++;
    return destroy();
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    (status == 0 ? p1 : p2).render(c, width, height);
  }

  @override
  void update(double t) {}
}
