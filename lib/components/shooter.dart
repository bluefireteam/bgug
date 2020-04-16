import 'dart:math' as math;
import 'dart:ui';

import 'package:bgug/game.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';
import '../data.dart';
import '../audio.dart';
import 'block.dart';

math.Random random = math.Random();

class Bullet extends AnimationComponent with HasGameRef<BgugGame> {
  static const double FRAC = 8.0 / 46.0;
  double speed;

  Bullet(this.speed, Size size, Position p)
      : super(16.0, 16.0, Animation.sequenced('bullet.png', 3, textureWidth: 16.0, textureHeight: 16.0)..stepTime = 0.075) {
    width = height = (1.0 - 2 * FRAC) * sizeTenth(size);
    x = p.x - width + 7.0;
    y = p.y + FRAC * sizeTenth(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;

    final player = gameRef.player;
    if (toRect().overlaps(player.toRect())) {
      player.x = x - player.width;
      player.velocity = Position(0.0, 0.0);
      player.die();
    }
  }

  @override
  bool destroy() => x < -width;

  @override
  void resize(Size size) {
    width = height = (1.0 - 2 * FRAC) * sizeTenth(size);
  }
}

class ShooterCane extends PositionComponent {
  static final Paint paint = Paint()..color = const Color(0xFF626262);

  ShooterCane() {
    width = 2.0;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    c.drawRect(Rect.fromLTWH(0.0, 0.0, width, height), paint);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    x = size.width - 8.0;
    y = sizeTop(size);
    height = sizeTenth(size) * 10;
  }

  @override
  bool isHud() => true;
}

class Shooter extends SpriteComponent with HasGameRef<BgugGame>, Resizable {
  static const double SPEED = 120.0;

  String kind;
  double yi, yf;
  double step;
  double clock = 0.0;
  String action;
  bool down = true;
  bool _hide = false;

  Animation shooting = Animation.sequenced('shooter.png', 2, textureWidth: 32.0, textureX: 32.0, textureHeight: 46.0);

  Shooter(this.kind) : super.fromSprite(32.0, 46.0, Sprite('shooter.png', width: 32.0));

  @override
  void render(Canvas c) {
    if (_hide) {
      return;
    }
    if (action == 'shooting') {
      if (shooting.loaded() && x != null && y != null) {
        prepareCanvas(c);
        shooting.getSprite().render(c, width: width, height: height);
      }
    } else {
      super.render(c);
    }
  }

  @override
  void update(double dt) {
    updateBoundaries();

    clock += dt;
    if (clock > 1.0) {
      clock -= 1.0;
      nextAction();
    }

    if (action == 'moveUp') {
      moveUp(dt, -SPEED);
    } else if (action == 'moveDown') {
      moveDown(dt, SPEED);
    }

    if (y < yi) {
      y = yi;
    } else if (y > yf) {
      y = yf;
    }

    if (shoot()) {
      gameRef.add(Bullet(Data.currentOptions.bulletSpeed, size, toPosition().add(gameRef.camera)));
    }
  }

  bool shoot() {
    if (action == 'shoot') {
      action = '';
      return true;
    }
    return false;
  }

  void moveDown(double dt, double speed) {
    final currentBit = (y - yi) % step;
    var dy = dt * speed;
    if (currentBit + dy >= step) {
      dy = step - currentBit;
      action = '';
    }
    y += dy;
  }

  void moveUp(double dt, double speed) {
    double currentBit = (y - yf) % step;
    while (currentBit > 0) {
      currentBit -= step;
    }
    var dy = dt * speed;
    if (currentBit + dy <= -step) {
      dy = -step - currentBit;
      action = '';
    }
    y += dy;
  }

  void nextAction() {
    if (_hide) {
      action = '';
      return;
    }
    if (action == 'shooting') {
      action = 'shoot';
      Audio.playSfx('laser_shoot.wav');
    } else if (yi == yf || random.nextDouble() < 0.2) {
      action = 'shooting';
      shooting.reset();
      Audio.playSfx('laser_load.wav');
    } else {
      if (y <= yi) {
        y = yi;
        down = true;
      } else if (y >= yf) {
        y = yf;
        down = false;
      }
      action = down ? 'moveDown' : 'moveUp';
    }
  }

  @override
  void resize(Size size) {
    super.resize(size);
    x = size.width - width;
    step = sizeTenth(size);
    height = step;
    action = '';
    updateBoundaries();
    if (kind == 'up') {
      y = yi;
    } else {
      y = yf;
    }
  }

  void updateBoundaries() {
    if (kind == 'up') {
      final currentSlot = gameRef.uppermostOccupiedSlot;
      final minUp = Block.minUp(currentSlot);
      if (minUp == null) {
        _hide = true;
      } else {
        _hide = false;
        yi = sizeTop(size) + step * minUp;
        yf = sizeTop(size) + step * 3;
        y = y.clamp(yi, yf);
      }
    } else {
      final currentSlot = gameRef.lowermostOccupiedSlot;
      final maxDown = Block.maxDown(currentSlot);
      if (maxDown == null) {
        _hide = true;
      } else {
        _hide = false;
        yi = sizeTop(size) + step * 4;
        yf = sizeTop(size) + step * maxDown;
        y = y.clamp(yi, yf);
      }
    }
  }

  @override
  bool isHud() => true;
}
