import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';
import '../components/player.dart';
import '../mixins/has_game_ref.dart';

class UpObstacle extends SpriteComponent with HasGameRef, Resizable {
  UpObstacle(double x)
      : super.fromSprite(48.0, 48.0, new Sprite('obstacle.png')) {
    this.x = x;
    this.y = BAR_SIZE;
  }

  @override
  void resize(Size size) {
    width = height = tenth(size);
  }

  @override
  void update(double t) {
    super.update(t);
    Player player = gameRef.player;
    if (this.toRect().overlaps(player.toRect())) {
      if (player.velocity.x.abs() >= player.velocity.y.abs()) {
        player.x = x - player.width;
      } else if (player.y > size.height / 2) {
        player.y = y - player.height;
        player.angle = math.pi / 2;
      } else {
        player.y = y + height;
        player.angle = 3 * math.pi / 2;
      }
      player.velocity = new Position(0.0, 0.0);
      player.die();
    }
  }
}

class Obstacle extends UpObstacle {
  Obstacle(double x) : super(x);

  @override
  void resize(Size size) {
    super.resize(size);
    y = size.height - height - BAR_SIZE;
  }
}
