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
import 'components/hud.dart';

import 'components/background.dart';
import 'components/button.dart';
import 'components/coin.dart';
import 'components/floor.dart';
import 'components/gem.dart';
import 'components/obstacle.dart';
import 'components/top.dart';
import 'components/shooter.dart';
import 'components/player.dart';
import 'components/end_card.dart';

import 'mixins/has_game_ref.dart';

import 'queryable_ordered_set.dart';
import 'constants.dart';
import 'game_mode.dart';
import 'ads.dart';
import 'data.dart';

math.Random random = new math.Random();

enum GameState { RUNNING, DEAD, END_CARD, STOPPED, AD }

class BgugGame extends BaseGame {
  GameMode gameMode;
  Button button;
  bool won = false;
  int _points = 0, currentCoins = 0;
  int lastGeneratedSector = 0;
  Future<AudioPlayer> music;
  int _currentSlot;
  Ad endGameAd;
  GameState _state;

  QueryableOrderedSetImpl queryComponents = new QueryableOrderedSetImpl();

  Player get player => queryComponents.player();

  Hud get hud => queryComponents.hud();

  EndCard get endCard => queryComponents.endCard();

  Iterable<Shooter> get shooters => queryComponents.shooters();

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
    button?.points = points;
  }

  int get currentSlot => _currentSlot;

  set currentSlot(int currentSlot) {
    _currentSlot = currentSlot;
    shooters.forEach((shooter) {
      shooter.currentSlot = currentSlot;
      if (size != null) {
        shooter.resize(size);
      }
    });
  }

  BgugGame(this.gameMode) {
    _start();
  }

  void showEndCard() {
    state = GameState.END_CARD;
    add(new EndCard());
  }

  bool hasAd() {
    return endGameAd != null && endGameAd.loaded;
  }

  void showAd() {
    if (hasAd()) {
      state = GameState.AD;
      endGameAd.listener = (evt) {
        print('Event : ${evt.toString()}');
        if (evt == MobileAdEvent.closed) {
          endCard.doubleCoins = true;
          state = GameState.END_CARD;
        }
      };
      endGameAd.show();
    }
  }

  void restart() {
    components.clear();
    won = false;
    _points = 0;
    currentCoins = 0;
    lastGeneratedSector = 0;

    currentSlot = 0;

    _start();
  }

  void _start() {
    add(new Background());

    add(new Hud());
    add(new Top());
    add(new Floor());
    add(new Player());

    if (gameMode.hasGuns) {
      add(new ShooterCane());
      add(new Shooter('up', currentSlot));
      add(new Shooter('down', currentSlot));
      add(new Block(currentSlot = Block.nextSlot(-1)));
      add(new Block(currentSlot = Block.nextSlot(currentSlot)));
    }

    // sector 0 pre-gen
    add(new Gem(500.0, (size) => size_bottom(size) - 1.2 * size_tenth(size)));
    add(new Coin(500.0, 200.0));

    if (gameMode != GameMode.PLAYGROUND) {
      add(button = new Button());
    }

    state = GameState.RUNNING;
    music = Flame.audio.loop('music.wav');
    endGameAd = random.nextDouble() < 0.25 ? Ad.loadAd() : null;
  }

  @override
  void add(Component c) {
    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }
    super.add(c);
  }

  void generateSector(int sector) {
    double start = sector * SECTOR_LENGTH;

    List<SpriteComponent> stuffSoFar = new List();
    for (int i = random.nextInt(4); i > 0; i--) {
      double x = start + random.nextInt(1000);
      UpObstacle obstacle =
          random.nextBool() ? new Obstacle(x) : new UpObstacle(x);
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
      Gem gem = new Gem(
          x,
          (size) =>
              size_bottom(size) - (1 + random.nextInt(8)) * size_tenth(size));
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

  void startInput(Position p, int dt) {
    if (p != null && player != null && !player.dead()) {
      if (p.x > size.width / 2) {
        queryComponents.hud().startGauge();
      }
    }
  }

  void input(Position p, int dt) {
    if (dt > Data.options.maxHoldJumpMillis) {
      dt = Data.options.maxHoldJumpMillis;
    }
    if (state == GameState.END_CARD) {
      endCard.click(p);
      return;
    }
    if (p != null && player != null) {
      queryComponents.hud().clearGauge();
      if (player.dead()) {
        showEndCard();
      } else {
        if (button != null && button.toRect().contains(p.toOffset())) {
          int dPoint = button.click(points);
          if (dPoint != 0) {
            points -= dPoint;
            currentSlot = Block.nextSlot(currentSlot);
            if (currentSlot == Block.WIN && !gameMode.gunRespawn) {
              won = true;
              showEndCard();
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
    if (state == GameState.RUNNING ||
        state == GameState.DEAD ||
        state == GameState.END_CARD) {
      super.render(c);
    } else {
      c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          new Paint()..color = material.Colors.black);
    }
  }

  @override
  void update(double dt) {
    if (state != GameState.RUNNING && state != GameState.END_CARD) {
      return;
    }

    while (
        player.x + 2 * SECTOR_LENGTH >= SECTOR_LENGTH * lastGeneratedSector) {
      lastGeneratedSector++;
      generateSector(lastGeneratedSector);
    }

    super.update(dt);

    if (player != null) {
      cameraFollow(player);

      if (gameMode.hasLimit && player.x >= gameMode.mapSize) {
        won = true;
        showEndCard();
      }
    } else {
      showEndCard();
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

  bool handlingClick() {
    return state == GameState.RUNNING || state == GameState.END_CARD;
  }

  void award(int coins) {
    Data.buy.coins += coins;
  }
}
