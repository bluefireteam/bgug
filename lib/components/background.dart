import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../background.dart' as bg;

math.Random random = new math.Random();

class Background extends SpriteComponent {
  static const SPEED = 50.0;
  Position speed;

  @override
  void resize(Size size) {
    this.width = size.width;
    this.height = size.height;
    this.x = this.y = 0.0;
    this.speed = new Position(SPEED, 0.0).rotate(random.nextDouble() * 2 * math.pi);
    this.setImageLater();
  }

  void setImageLater() async {
    Image image = await bg.generate(this.width.toInt() ~/ 4, this.height.toInt() ~/ 4);
    this.sprite = new Sprite.fromImage(image);
  }

  @override
  void render(Canvas c) {
    if (sprite == null) {
      return;
    }
    Flame.util.drawWhere(c, new Position(x - width, y - height),
            (c) => sprite.render(c, width, height));
    Flame.util.drawWhere(
        c, new Position(x, y - height), (c) => sprite.render(c, width, height));
    Flame.util.drawWhere(
        c, new Position(x - width, y), (c) => sprite.render(c, width, height));
    super.render(c);
  }

  @override
  void update(double dt) {
    this.x += dt * speed.x;
    this.y += dt * speed.y;

    this.x = this.x % width;
    this.y = this.y % height;
  }

  @override
  bool isHud() {
    return true;
  }
}