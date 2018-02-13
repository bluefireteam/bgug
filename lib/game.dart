import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayer.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;

import 'background.dart' as bg;
import 'constants.dart';
import 'game_mode.dart';
import 'options.dart';
import 'shooter.dart';
import 'util.dart';
import 'ads.dart';

class Button extends SpriteComponent {
  static const MARGIN = 4.0;
  int cost, incCost;
  bool active = false;

  Button(Options options) : super.square(64.0, 'button.png') {
    cost = options.buttonCost;
    incCost = options.buttonIncCost;
  }

  void evaluate(int points) {
    active = points >= cost;
  }

  int click(int points) {
    if (active) {
      int currentCost = cost;
      cost += incCost;
      return currentCost;
    }
    return 0;
  }

  @override
  render(Canvas canvas) {
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
      material.TextPainter tp = Flame.util.text(
        toUpperCaseNumber(cost.toString()),
        fontFamily: 'Blox2',
        fontSize: 32.0,
        color: active ? material.Colors.green : material.Colors.blueGrey,
      );
      tp.paint(canvas, new Offset(32.0 - tp.width / 2, 32.0));
    }
  }

  @override
  void resize(Size size) {
    x = MARGIN;
    y = MARGIN;
  }

  @override
  bool isHud() {
    return true;
  }
}

class Background extends SpriteComponent {
  static const SPEED = 50.0;
  Position speed;

  @override
  void resize(Size size) {
    this.width = size.width;
    this.height = size.height;
    this.x = this.y = 0.0;
    this.sprite = new Sprite.fromImage(
        bg.generate(this.width.toInt() ~/ 4, this.height.toInt() ~/ 4));
    this.speed =
        new Position(SPEED, 0.0).rotate(random.nextDouble() * 2 * math.PI);
  }

  @override
  void render(Canvas c) {
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

class UpObstacle extends SpriteComponent {
  UpObstacle(double x)
      : super.fromSprite(48.0, 48.0, new Sprite('obstacle.png')) {
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
  Floor() : super.fromSprite(1.0, BAR_SIZE, new Sprite('base.png'));

  @override
  bool isHud() {
    return true;
  }

  @override
  resize(Size size) {
    x = 0.0;
    y = size.height - BAR_SIZE;
    width = size.width;
  }
}

class Top extends SpriteComponent {
  Top() : super.fromSprite(1.0, BAR_SIZE, new Sprite('base.png'));

  @override
  bool isHud() {
    return true;
  }

  @override
  resize(Size size) {
    x = 0.0;
    y = 0.0;
    width = size.width;
  }
}

class Gem extends SpriteComponent {
  bool collected = false;
  double Function(Size) yGen;

  Gem(double x, this.yGen) : super.fromSprite(1.0, 1.0, new Sprite('gem.png')) {
    this.x = x;
  }

  @override
  void resize(Size size) {
    this.width = this.height = 0.8 * tenth(size);
    this.y = yGen(size);
  }

  void collect() {
    this.collected = true;
  }

  @override
  bool destroy() {
    return this.collected;
  }
}

enum GameState {
  RUNNING, DEAD, AD, STOPPED
}

class Player extends PositionComponent {
  Map<String, Animation> animations;
  Position velocity = new Position(320.0, 0.0);
  double y0, yf;
  String state;

  Options options;
  Impulse jumpImpulse;
  Impulse diveImpulse;

  Player(this.options) {
    jumpImpulse = new Impulse(-1 * options.jumpImpulse);
    diveImpulse = new Impulse(options.diveImpulse);

    animations = new Map<String, Animation>();
    animations['running'] = new Animation.sequenced('player.png', 8,
        textureWidth: 16.0, textureHeight: 18.0)
      ..stepTime = 0.0375;
    animations['dead'] = new Animation.sequenced('player.png', 3,
        textureWidth: 16.0, textureHeight: 18.0, textureX: 16.0 * 8)
      ..stepTime = 0.075;
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
      velocity.y += options.gravityImpulse * t;
    }

    x += velocity.x * t;
    y += velocity.y * t;
    if (y > y0) {
      y = y0;
      clearVerticalSpeed();
    } else if (y < yf) {
      y = yf;
      clearVerticalSpeed();
    }
  }

  void clearVerticalSpeed() {
    velocity.y = 0.0;
    jumpImpulse.clear();
    diveImpulse.clear();
  }

  bool dead() {
    return state == 'dead';
  }

  bool falling() {
    return y < y0;
  }

  @override
  void resize(Size size) {
    height = tenth(size);
    width = 48.0 / 54.0 * height;
    y = y0 = size.height - height - BAR_SIZE;
    yf = BAR_SIZE;
  }

  void jump(int dt) {
    if (!falling()) {
      jumpImpulse.impulse(options.jumpTimeMultiplier * dt);
      Flame.audio.play('jump.wav');
    }
  }

  void dive() {
    if (falling()) {
      diveImpulse.impulse(0.1);
    }
  }
}

class MyGame extends BaseGame {
  Options options;
  GameMode gameMode;

  Button button;
  bool won = false;
  int _points = 0;
  int lastGeneratedSector = 0;
  AudioPlayer music;
  int _currentSlot;
  Ad endGameAd;
  GameState _state;

  GameState get state => _state;

  set state(GameState state) {
    if (state == GameState.STOPPED) {
      music?.stop();
    }
    _state = state;
  }

  int get points => _points;

  set points(int points) {
    _points = points;
    button?.evaluate(points);
  }

  int get currentSlot => _currentSlot;

  set currentSlot(int currentSlot) {
    _currentSlot = currentSlot;
    getShooters().forEach((shooter) {
      shooter.currentSlot = currentSlot;
      if (size != null) {
        shooter.resize(size);
      }
    });
  }

  MyGame(this.gameMode, this.options) {
    _start();
  }

  void quitGame() {
    print(endGameAd.loaded);
    if (endGameAd.loaded) {
      state = GameState.AD;
      endGameAd.listener = (evt) {
        print('Event : ${evt.toString()}');
        if (evt == MobileAdEvent.closed) {
          state = GameState.STOPPED;
        }
      };
      endGameAd.show();
    } else {
      state = GameState.STOPPED;
    }
  }

  void _start() {
    add(new Background());

    add(new Top());
    add(new Floor());
    add(new Player(options));

    if (gameMode.hasGuns) {
      add(new ShooterCane());
      add(new Shooter('up'));
      add(new Shooter('down'));
      add(new Block(currentSlot = Block.nextSlot(-1)));
      add(new Block(currentSlot = Block.nextSlot(currentSlot)));
    }

    // sector 0 pre-gen
    add(new Gem(500.0, (size) => size.height - BAR_SIZE - 0.9 * tenth(size)));

    if (gameMode != GameMode.PLAYGROUND) {
      add(button = new Button(options));
    }

    state = GameState.RUNNING;
    Flame.audio.loop('music.wav').then((player) => music = player);
    endGameAd = Ad.loadAd();
  }

  generateSector(int sector) {
    double start = sector * SECTOR_LENGTH;

    List<SpriteComponent> stuffSoFar = new List();
    for (int i = random.nextInt(4); i > 0; i--) {
      var x = start + random.nextInt(1000);
      var obstacle = random.nextBool() ? new Obstacle(x) : new UpObstacle(x);
      if (stuffSoFar.any((box) =>
          box.toRect().overlaps(obstacle.toRect()) ||
          (box.x - obstacle.x).abs() < 20.0)) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      stuffSoFar.add(obstacle);
      add(obstacle);
    }
    for (int i = random.nextInt(6); i > 0; i--) {
      var x = start + random.nextInt(1000);
      var gem =
          new Gem(x, (size) => BAR_SIZE + random.nextInt(8) * tenth(size));
      if (stuffSoFar.any((box) => box.toRect().overlaps(gem.toRect()))) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      stuffSoFar.add(gem);
      add(gem);
    }
  }

  Player getPlayer() {
    return components.firstWhere((c) => c is Player, orElse: () => null)
        as Player;
  }

  Set<Shooter> getShooters() {
    return components
        .where((c) => c is Shooter)
        .map((c) => c as Shooter)
        .toSet();
  }

  void input(Position p, int dt) {
    if (dt > options.maxHoldJumpMillis) {
      dt = options.maxHoldJumpMillis;
    }
    final player = getPlayer();
    if (p != null && player != null) {
      if (player.dead()) {
        quitGame();
      } else {
        if (button != null && button.toRect().contains(p.toOffset())) {
          int dPoint = button.click(points);
          if (dPoint != 0) {
            points -= dPoint;
            currentSlot = Block.nextSlot(currentSlot);
            if (currentSlot == Block.WIN && !gameMode.gunRespawn) {
              won = true;
              quitGame();
            } else {
              add(new Block(currentSlot));
            }
          }
        } else if (p.x > size.width / 2) {
          player.jump(dt);
        } else {
          player.dive();
        }
      }
    }
  }

  @override
  void render(Canvas c) {
    if (state == GameState.RUNNING || state == GameState.DEAD) {
      super.render(c);
      renderPoints(c);
    } else {
      c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), new Paint()..color = material.Colors.black);
    }
  }

  void renderPoints(Canvas c) {
    material.TextPainter tp = Flame.util.text(
      points.toString(),
      fontFamily: 'Blox2',
      fontSize: 32.0,
      color: material.Colors.green,
    );
    var where = new Offset(
      size.width - tp.width - 8.0,
      size.height - tp.height - 8.0,
    );
    tp.paint(c, where);
  }

  @override
  void update(double dt) {
    if (state != GameState.RUNNING) {
      return;
    }

    Player player = getPlayer();

    while (
        player.x + 2 * SECTOR_LENGTH >= SECTOR_LENGTH * lastGeneratedSector) {
      lastGeneratedSector++;
      generateSector(lastGeneratedSector);
    }

    super.update(dt);

    getShooters().forEach((shooter) {
      if (shooter.shoot()) {
        add(new Bullet(
            options.bulletSpeed, size, shooter.toPosition().add(camera)));
      }
    });

    if (player != null) {
      Rect playerRect = player.toRect();
      components.forEach((c) {
        if (c is Gem) {
          if (c.toRect().overlaps(playerRect)) {
            c.collect();
            points++;
            Flame.audio.play('gem_collect.wav');
          }
        } else if (c is UpObstacle || c is Bullet) {
          PositionComponent b = c as PositionComponent;
          if (b.toRect().overlaps(playerRect)) {
            if (b is Bullet ||
                player.velocity.x.abs() >= player.velocity.y.abs()) {
              player.x = b.x - player.width;
            } else if (player.y > size.height / 2) {
              player.y = b.y - player.height;
              player.angle = math.PI / 2;
            } else {
              player.y = b.y + b.height;
              player.angle = 3 * math.PI / 2;
            }
            player.velocity = new Position(0.0, 0.0);
            if (!player.dead()) {
              player.state = 'dead';
              Flame.audio.play('death.wav');
            }
          }
        }
      });

      cameraFollow(player);

      if (gameMode.hasLimit && player.x >= gameMode.mapSize) {
        won = true;
        quitGame();
      }
    } else {
      quitGame();
    }
  }

  void cameraFollow(Player c) {
    camera.x = c.x - size.width / 2 + c.width / 2 + size.width / 4;
    if (camera.x < 0.0) {
      camera.x = 0.0;
    } else if (gameMode.hasLimit && camera.x > gameMode.mapSize - size.width) {
      camera.x = gameMode.mapSize - size.width;
    }
  }

  String score() {
    return gameMode.score(points, won);
  }
}
