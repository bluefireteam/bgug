import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:ordered_set/ordered_set.dart';

import 'components/background.dart';
import 'components/button.dart';
import 'components/coin.dart';
import 'components/floor.dart';
import 'components/gem.dart';
import 'components/obstacle.dart';
import 'components/top.dart';
import 'components/shooter.dart';
import 'components/player.dart';

import 'queryable_ordered_set.dart';
import 'constants.dart';
import 'game_mode.dart';
import 'ads.dart';
import 'data.dart';

math.Random random = new math.Random();

enum GameState {
  RUNNING, DEAD, AD, STOPPED
}

class MyGame extends BaseGame {
  GameMode gameMode;
  Button button;
  bool won = false;
  int _points = 0;
  int lastGeneratedSector = 0;
  Future<AudioPlayer> music;
  int _currentSlot;
  Ad endGameAd;
  GameState _state;

  QueryableOrderedSetImpl queryComponents = new QueryableOrderedSetImpl();

  @override
  OrderedSet<Component> get components => queryComponents;

  GameState get state => _state;

  set state(GameState state) {
    if (state == GameState.STOPPED) {
      if (music != null) {
        music.then((p) => p.release());
      }
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
    queryComponents.shooters().forEach((shooter) {
      shooter.currentSlot = currentSlot;
      if (size != null) {
        shooter.resize(size);
      }
    });
  }

  MyGame(this.gameMode) {
    _start();
  }

  void quitGame() {
    if (endGameAd != null && endGameAd.loaded) {
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
    add(new Player());

    if (gameMode.hasGuns) {
      add(new ShooterCane());
      add(new Shooter('up'));
      add(new Shooter('down'));
      add(new Block(currentSlot = Block.nextSlot(-1)));
      add(new Block(currentSlot = Block.nextSlot(currentSlot)));
    }

    // sector 0 pre-gen
    add(new Gem(500.0, (size) => size.height - BAR_SIZE - 0.9 * tenth(size)));
    add(new Coin(500.0, 200.0));

    if (gameMode != GameMode.PLAYGROUND) {
      add(button = new Button());
    }

    state = GameState.RUNNING;
    music = Flame.audio.loop('music.wav');
    endGameAd = random.nextDouble() < 0.25 ? Ad.loadAd() : null;
  }

  void generateSector(int sector) {
    double start = sector * SECTOR_LENGTH;

    List<SpriteComponent> stuffSoFar = new List();
    for (int i = random.nextInt(4); i > 0; i--) {
      double x = start + random.nextInt(1000);
      Obstacle obstacle = random.nextBool() ? new Obstacle(x) : new UpObstacle(x);
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
      double x = start + random.nextInt(1000);
      Gem gem = new Gem(x, (size) => BAR_SIZE + random.nextInt(8) * tenth(size));
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

  void input(Position p, int dt) {
    if (dt > Data.options.maxHoldJumpMillis) {
      dt = Data.options.maxHoldJumpMillis;
    }
    final player = queryComponents.player();
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
    final where = new Offset(
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

    Player player = queryComponents.player();

    while (
        player.x + 2 * SECTOR_LENGTH >= SECTOR_LENGTH * lastGeneratedSector) {
      lastGeneratedSector++;
      generateSector(lastGeneratedSector);
    }

    super.update(dt);

    queryComponents.shooters().forEach((shooter) {
      if (shooter.shoot()) {
        add(new Bullet(
            Data.options.bulletSpeed, size, shooter.toPosition().add(camera)));
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
        } else if (c is Coin) {
          if (c.toRect().overlaps(playerRect)) {
            c.collected = true;
            Data.buy.coins++;
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
              player.angle = math.pi / 2;
            } else {
              player.y = b.y + b.height;
              player.angle = 3 * math.pi / 2;
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
