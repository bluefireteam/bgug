import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'constants.dart';

math.Random random = new math.Random();

class Bullet extends AnimationComponent {
  static const double FRAC = 8.0 / 46.0;
  double speed;

  Bullet(this.speed, Size size, Position p)
      : super(16.0, 16.0, new Animation.sequenced('bullet.png', 3,
            textureWidth: 16.0, textureHeight: 16.0)
          ..stepTime = 0.075) {
    this.width = this.height = (1.0 - 2 * FRAC) * tenth(size);
    this.x = p.x - this.width + 7.0;
    this.y = p.y + FRAC * tenth(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    this.x -= speed * dt;
  }

  @override
  bool destroy() {
    return this.x < -this.width;
  }

  @override
  void resize(Size size) {
    this.width = this.height = (1.0 - 2 * FRAC) * tenth(size);
  }
}

class ShooterCane extends PositionComponent {
  static final Paint paint = new Paint()..color = const Color(0xFF626262);

  ShooterCane() {
    this.y = BAR_SIZE;
    this.width = 2.0;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    c.drawRect(new Rect.fromLTWH(0.0, 0.0, width, height), paint);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    this.x = size.width - 8.0;
    this.height = tenth(size) * 10;
  }

  @override
  bool isHud() {
    return true;
  }
}

class Shooter extends SpriteComponent {
  static const double SPEED = 120.0;

  String kind;
  double yi, yf;
  double step;
  double clock = 0.0;
  String action;
  bool down = true;
  int currentSlot;
  bool _destroy = false;

  Animation shooting = new Animation.sequenced('shooter.png', 2,
      textureWidth: 32.0, textureX: 32.0);

  Shooter(this.kind)
      : super.fromSprite(32.0, 46.0, new Sprite('shooter.png', width: 32.0));

  @override
  void render(Canvas c) {
    if (action == 'shooting') {
      if (shooting.loaded() && x != null && y != null) {
        prepareCanvas(c);
        shooting.getSprite().render(c, width, height);
      }
    } else {
      super.render(c);
    }
  }

  @override
  void update(double dt) {
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
  }

  bool shoot() {
    if (action == 'shoot') {
      action = '';
      return true;
    }
    return false;
  }

  void moveDown(double dt, double speed) {
    double currentBit = (y - yi) % step;
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
    if (action == 'shooting') {
      action = 'shoot';
      Flame.audio.play('laser_shoot.wav');
    } else if (random.nextDouble() < 0.2) {
      action = 'shooting';
      shooting.reset();
      Flame.audio.play('laser_load.wav');
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
    x = size.width - width;

    step = tenth(size);
    height = step;
    action = '';
    if (kind == 'up') {
      var minUp = Block.minUp(currentSlot);
      if (minUp == 3) {
        // TODO Flame.audio.play('?') destruction audio
        _destroy = true;
      }
      yi = BAR_SIZE + step * minUp;
      yf = BAR_SIZE + step * 3;
      y = yi;
    } else {
      var maxDown = Block.maxDown(currentSlot);
      if (maxDown == 4) {
        // TODO Flame.audio.play('?') destruction audio
        _destroy = true;
      }
      yi = BAR_SIZE + step * 4;
      yf = BAR_SIZE + step * maxDown;
      y = yf;
    }
  }

  @override
  bool isHud() {
    return true;
  }

  @override
  bool destroy() {
    return _destroy;
  }
}

class Block extends SpriteComponent {
  static int minUp(int currentSlot) {
    if (currentSlot <= 0 || currentSlot == 7) {
      return 1;
    } else if (currentSlot == 1 || currentSlot == 6) {
      return 2;
    } else {
      return 3;
    }
  }

  static int maxDown(int currentSlot) {
    if (currentSlot <= 0 || currentSlot == 7 || currentSlot == 1) {
      return 6;
    } else if (currentSlot == 6 || currentSlot == 2) {
      return 5;
    } else {
      return 4;
    }
  }

  static const int WIN = -2;

  static int nextSlot(int currentSlot) {
    const Map<int, int> MAP = const {
      -1: 0,
      0: 7,
      7: 1,
      1: 6,
      6: 2,
      2: 5,
      5: 3,
      3: 4,
      4: Block.WIN
    };
    return MAP[currentSlot];
  }

  int slot;

  Block(this.slot) : super.fromSprite(16.0, 16.0, new Sprite('block.png'));

  @override
  void resize(Size size) {
    this.width = this.height = tenth(size);
    this.x = size.width - this.width;
    this.y = this.slot * this.height + BAR_SIZE;
  }

  @override
  bool isHud() {
    return true;
  }
}
