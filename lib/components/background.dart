import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../background.dart' as bg;

math.Random random = math.Random();

class Background extends SpriteComponent {
  static const SPEED = 50.0;
  Position speed;

  @override
  void resize(Size size) {
    width = size.width;
    height = size.height;
    x = y = 0.0;
    speed = Position(SPEED, 0.0).rotate(random.nextDouble() * 2 * math.pi);
    setImageLater();
  }

  void setImageLater() async {
    final image = await bg.generate(width.toInt() ~/ 4, height.toInt() ~/ 4);
    sprite = Sprite.fromImage(image);
  }

  @override
  void render(Canvas c) {
    if (sprite == null) {
      return;
    }
    Flame.util.drawWhere(c, Position(x - width, y - height), (c) => sprite.render(c, width: width, height: height));
    Flame.util.drawWhere(c, Position(x, y - height), (c) => sprite.render(c, width: width, height: height));
    Flame.util.drawWhere(c, Position(x - width, y), (c) => sprite.render(c, width: width, height: height));
    super.render(c);
  }

  @override
  void update(double dt) {
    x += dt * speed.x;
    y += dt * speed.y;

    x %=  width;
    y %= height;
  }

  @override
  bool isHud() {
    return true;
  }
}