import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

import 'math_util.dart';
import 'constants.dart';
import 'shooter.dart';

class UpObstacle extends SpriteComponent {
  UpObstacle(double x) : super.fromSprite(48.0, 48.0, new Sprite('obstacle.png')) {
    this.x = x;
    this.y = BAR_SIZE;
  }

  @override
  void resize(Size size) {
    width = height = tenth(size);
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

class Floor extends SpriteComponent {
  Floor(double width) : super.fromSprite(1.0, BAR_SIZE, new Sprite('base.png')) {
    x = 0.0;
    this.width = width;
  }

  @override
  void resize(Size size) {
    y = size.height - BAR_SIZE;
  }
}

class Top extends SpriteComponent {
  Top(double width) : super.fromSprite(1.0, BAR_SIZE, new Sprite('base.png')) {
    x = 0.0;
    y = 0.0;
    this.width = width;
  }
}

const GRAVITY_IMPULSE = 1875.0;

class Player extends PositionComponent {
  Map<String, Animation> animations;
  Point velocity = new Point(320.0, 0.0);
  Impulse jumpImpulse = new Impulse(-10000.0);
  Impulse diveImpulse = new Impulse(20000.0);
  double y0, worldSize;
  String state;

  Player(double x, double y, this.worldSize) {
    this.x = x;
    this.y = y;
    y0 = 0.0;

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

    velocity.y += jumpImpulse.tick(t);
    velocity.y += diveImpulse.tick(t);
    if (falling()) {
      velocity.y += GRAVITY_IMPULSE * t;
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
    height = tenth(size);
    width = 48.0/54.0 * height;
    y0 = size.height - height - BAR_SIZE;
  }

  void jump() {
    if (!falling()) {
      jumpImpulse.impulse(0.1);
    }
  }

  void dive() {
    if (falling()) {
      diveImpulse.impulse(0.1);
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
    add(new Top(WORLD_SIZE));
    add(new Floor(WORLD_SIZE));
    add(new Player(0.0, 0.0, WORLD_SIZE));
    add(new Obstacle(450.0));
    add(new Obstacle(750.0));
    add(new UpObstacle(1000.0));
    add(new ShooterCane());
    add(new Shooter('up'));
    add(new Shooter('down'));

    add(new Block(0));
    add(new Block(7));

    _running = true;
  }

  Player getPlayer() {
    return components.firstWhere((c) => c is Player, orElse: () => null) as Player;
  }

  Set<Shooter> getShooters() {
    return components.where((c) => c is Shooter).map((c) => c as Shooter).toSet();
  }

  void input(double x, double y) {
    final player = getPlayer();
    if (player != null) {
      if (player.dead()) {
        setRunning(false);
      } else {
        if (x > size.width / 2) {
          player.jump();
        } else {
          player.dive();
        }
      }
    }
  }

  @override
  void update(double dt) {
    if (!isRunning()) {
      return;
    }

    super.update(dt);

    getShooters().forEach((shooter) {
      if (shooter.shoot()) {
        add(new Bullet(size, shooter.toPosition().add(camera)));
      }
    });

    Player player = getPlayer();
    if (player != null) {
      Rect playerRect = player.toRect();
      components.forEach((c) {
        if (c is UpObstacle || c is Bullet) {
          PositionComponent b = c as PositionComponent;
          if (b.toRect().overlaps(playerRect)) {
            if (b is Bullet || player.velocity.x.abs() >= player.velocity.y.abs()) {
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
