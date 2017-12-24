import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'math_util.dart';

math.Random random = new math.Random();

class Bullet extends AnimationComponent {
  static const double SPEED = 1000.0;

  Bullet(Position p) : super(64.0, 64.0, new Animation.sequenced('bullet.png', 3, textureWidth: 16.0, textureHeight: 16.0)..stepTime = 0.075) {
    this.x = p.x;
    this.y = p.y;
  }

  @override
  void update(double dt) {
    this.x -= SPEED * dt;
  }
}

class ShooterCane extends PositionComponent {

  static final Paint paint = new Paint()..color = const Color(0xFF626262);

  ShooterCane() {
    this.y = 0.0;
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
    this.height = size.height;
  }

  @override
  bool isHud() {
    return true;
  }
}

class Shooter extends SpriteComponent {

  double speed;
  Size size;

  Shooter(double y) : super.fromSprite(32.0, 46.0, new Sprite('shooter.png')) {
    this.x = 0.0;
    this.y = y;
    this.speed = 240.0;
  }

  @override
  void update(double dt) {
    y += speed * dt;
    if (y < 0) {
      speed *= -1;
      y = 1.0;
    } else if (y > size.height - height) {
      speed *= -1;
      y = size.height - height - 1;
    }
  }

  @override
  void resize(Size size) {
    this.size = size;
    x = size.width - width;
  }

  @override
  bool isHud() {
    return true;
  }
}

class UpBlock extends SpriteComponent {
  UpBlock(double x) : super.fromSprite(64.0, 64.0, new Sprite('block.png')) {
    this.x = x;
    this.y = 16.0;
  }
}

class Block extends UpBlock {
  Block(double x) : super(x);

  @override
  void resize(Size size) {
    y = size.height - height - 16.0;
  }
}

class Floor extends SpriteComponent {
  Floor(double width) : super.fromSprite(1.0, 16.0, new Sprite('base.png')) {
    x = 0.0;
    this.width = width;
  }

  @override
  void resize(Size size) {
    y = size.height - 16.0;
  }
}

class Top extends SpriteComponent {
  Top(double width) : super.fromSprite(1.0, 16.0, new Sprite('base.png')) {
    x = 0.0;
    y = 0.0;
    this.width = width;
  }
}

class Player extends PositionComponent {
  Map<String, Animation> animations;
  Point velocity = new Point(240.0, 0.0);
  Impulse impulse = new Impulse(20000.0 / 2);
  double y0, worldSize;
  String state;

  Player(double x, double y, this.worldSize) {
    this.x = x;
    this.y = y;
    y0 = 0.0;
    width = 64.0;
    height = 72.0;

    animations = new Map<String, Animation>();
    animations['running'] = new Animation.sequenced('player.png', 8, textureWidth: 16.0, textureHeight: 18.0)..stepTime = 0.0375;
    animations['dead'] = new Animation.sequenced('player.png', 3, textureWidth: 16.0, textureHeight: 18.0, textureX: 16.0 * 8)..stepTime = 0.075;
    state = 'running';
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animations[state].getSprite().render(canvas, width, height);
  }

  @override
  void update(double t) {
    animations[state].update(t);

    if (dead()) {
      return;
    }

    velocity.y -= impulse.tick(t);
    if (falling()) {
      velocity.y += 7500.0 / 4 * t; // gravity
    }

    x += velocity.x * t;
    y += velocity.y * t;
    if (y > y0) {
      y = y0;
      velocity.y = 0.0;
    }
  }

  bool dead() {
    return state == 'dead';
  }

  bool falling() {
    return y < y0;
  }

  @override
  bool destroy() {
    return x > worldSize;
  }

  @override
  void resize(Size size) {
    y0 = size.height - 72.0 - 16.0;
  }

  void jump() {
    if (!falling() && !dead()) {
      impulse.impulse(0.1);
    }
  }
}

class MyGame extends BaseGame {
  static const double WORLD_SIZE = 2000.0;
  bool _running = false;

  bool isRunning() {
    return this._running;
  }

  void setRunning(bool running) {
    this._running = running;
  }

  void start() {
    components.add(new Top(WORLD_SIZE));
    components.add(new Floor(WORLD_SIZE));
    components.add(new Player(0.0, 0.0, WORLD_SIZE));
    components.add(new Block(450.0));
    components.add(new Block(750.0));
    components.add(new UpBlock(1000.0));
    components.add(new ShooterCane());
    components.add(new Shooter(200.0));

    _running = true;
  }

  Player getPlayer() {
    return components.firstWhere((c) => c is Player, orElse: () => null) as Player;
  }

  void input(double x, double y) {
    final player = getPlayer();
    if (player != null) {
      if (player.dead()) {
        setRunning(false);
      } else {
        player.jump();
      }
    }
  }

  @override
  void update(double dt) {
    if (!isRunning()) {
      return;
    }

    if (false && random.nextDouble() < dt) {
      components.add(new Bullet((components.firstWhere((c) => c is Shooter, orElse: () => null) as Shooter).toPosition()));
    }

    super.update(dt);

    Player player = getPlayer();
    if (player != null) {
      Rect playerRect = player.toRect();
      components.forEach((c) {
        if (c is UpBlock) {
          UpBlock b = c;
          if (b.toRect().overlaps(playerRect)) {
            if (player.velocity.x.abs() >= player.velocity.y.abs()) {
              player.x = b.x - player.width;
            } else if (player.velocity.y > 0) {
              player.y = b.y - player.height;
              player.angle = math.PI / 2;
            } else {
              player.y = b.y + b.height;
              player.angle = 3 * math.PI / 2;
            }
            player.velocity = new Point(0.0, 0.0);
            player.state = 'dead';
          }
        }
      });

      cameraFollow(player);
    } else {
      this.setRunning(false);
    }
  }

  void cameraFollow(Player c) {
    camera.x = c.x - size.width / 2 + c.width / 2;
    if (camera.x < 0.0) {
      camera.x = 0.0;
    } else if (camera.x > WORLD_SIZE - size.width) {
      camera.x = WORLD_SIZE - size.width;
    }
  }
}
