import 'dart:math' as math;
import 'dart:ui';

import 'math_util.dart';

import 'package:flame/components/component.dart';
import 'package:flame/animation.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class Block extends SpriteComponent {
  Block(double x) : super.fromSprite(64.0, 64.0, new Sprite('block.png')) {
    this.x = x;
    this.y = 0.0;
  }

  Rect toRect() {
    return new Rect.fromLTWH(x, y, width, height);
  }

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
  Impulse impulse = new Impulse(20000.0/2);
  double y0, worldSize;
  double width, height;
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

  Rect toRect() {
    return new Rect.fromLTWH(x, y, width, height);
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
      velocity.y += 7500.0/4 * t; // gravity
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

    super.update(dt);

    Player player = getPlayer();

    if (player != null) {
      Rect playerRect = player.toRect();
      components.forEach((c) {
        if (c is Block) {
          Block b = c;
          if (b.toRect().overlaps(playerRect)) {
            if (player.velocity.x.abs() >= player.velocity.y.abs()) {
              player.x = b.x - player.width;
            } else {
              player.y = b.y - player.height;
              player.angle = math.PI / 2;
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
    camera.x = c.x - size.width / 2 + c.width/2;
    if (camera.x < 0.0) {
      camera.x = 0.0;
    } else if (camera.x > WORLD_SIZE - size.width) {
      camera.x = WORLD_SIZE - size.width;
    }
  }
}
