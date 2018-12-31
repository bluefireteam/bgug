import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:bgug/world_gen.dart';
import 'package:flutter/material.dart' as material;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:ordered_set/ordered_set.dart';

import 'components/hud.dart';
import 'components/tutorial.dart';
import 'components/background.dart';
import 'components/button.dart';
import 'components/floor.dart';
import 'components/top.dart';
import 'components/shooter.dart';
import 'components/player.dart';
import 'components/end_card.dart';

import 'mixins/has_game_ref.dart';

import 'queryable_ordered_set.dart';
import 'constants.dart';
import 'options.dart';
import 'ads.dart';
import 'data.dart';

math.Random random = new math.Random();

enum GameState { TUTORIAL, RUNNING, DEAD, END_CARD, STOPPED, AD }

class BgugGame extends BaseGame {

  static Options get options => Data.currentOptions;

  bool shouldScore;
  Button button;
  bool won = false;
  int _points = 0, currentCoins = 0;
  int lastGeneratedSector = -1;
  Future<AudioPlayer> music;
  int _currentSlot;
  Ad endGameAd;
  GameState _state;

  QueryableOrderedSetImpl queryComponents = new QueryableOrderedSetImpl();

  Player get player => queryComponents.player();

  Hud get hud => queryComponents.hud();

  EndCard get endCard => queryComponents.endCard();

  Tutorial get tutorial => queryComponents.tutorial();

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

  BgugGame(this.shouldScore, bool showTutorial) {
    _start(showTutorial ? GameState.TUTORIAL : GameState.RUNNING);
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
    lastGeneratedSector = -1;

    currentSlot = 0;

    _start(GameState.RUNNING);
  }

  void _start(GameState state) {
    add(new Background());

    add(new Hud());
    add(new Top());
    add(new Floor());
    add(new Player());

    if (options.hasGuns) {
      add(new ShooterCane());
      add(new Shooter('up', currentSlot));
      add(new Shooter('down', currentSlot));
      add(new Block(currentSlot = Block.nextSlot(-1)));
      add(new Block(currentSlot = Block.nextSlot(currentSlot)));
      add(button = new Button());
    }

    this.state = state;
    if (this.state == GameState.TUTORIAL) {
      add(new Tutorial());
    }

    if (music != null) {
      music.then((p) => p.release());
    }
    music = Flame.audio.loop('music.wav');
    endGameAd = Ad.loadAd();
  }

  @override
  void preAdd(Component c) {
    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }
    if (size != null) {
      c.resize(size);
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
    if (dt > Data.currentOptions.maxHoldJumpMillis) {
      dt = Data.currentOptions.maxHoldJumpMillis;
    }
    if (state == GameState.END_CARD) {
      endCard.click(p);
      return;
    }
    if (state == GameState.TUTORIAL) {
      state = GameState.RUNNING;
      tutorial.remove();
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
            if (currentSlot == Block.WIN && !options.gunRespawn) {
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
    if (state == GameState.TUTORIAL || state == GameState.RUNNING || state == GameState.DEAD || state == GameState.END_CARD) {
      super.render(c);
    } else {
      c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), new Paint()..color = material.Colors.black);
    }
  }

  @override
  void update(double dt) {
    if (state != GameState.RUNNING && state != GameState.END_CARD) {
      return;
    }

    while (player.x + 2 * SECTOR_LENGTH >= SECTOR_LENGTH * lastGeneratedSector) {
      lastGeneratedSector++;
      WorldGen.generateSector(size, lastGeneratedSector).forEach(addLater);
    }

    super.update(dt);

    if (player != null) {
      cameraFollow(player);

      if (options.hasLimit && player.x >= options.mapSize) {
        won = true;
        player.velocity.x = 0;
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
    } else if (options.hasLimit && camera.x > options.mapSize - size.width) {
      camera.x = options.mapSize - size.width;
    }
  }

  String score() {
    return 'Scored ${hud.maxDistance.toStringAsFixed(2)} meters earning $currentCoins coins.';
  }

  bool handlingClick() {
    return state == GameState.TUTORIAL || state == GameState.RUNNING || state == GameState.END_CARD;
  }

  void award(int coins) {
    if (shouldScore) {
      Data.buy.coins += coins;
    }
  }
}
