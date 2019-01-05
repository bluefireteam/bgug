import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart' as material;
import 'package:ordered_set/ordered_set.dart';

import 'ads.dart';
import 'components/background.dart';
import 'components/button.dart';
import 'components/end_card.dart';
import 'components/floor.dart';
import 'components/hud.dart';
import 'components/player.dart';
import 'components/shooter.dart';
import 'components/toast.dart';
import 'components/top.dart';
import 'components/tutorial.dart';
import 'constants.dart';
import 'data.dart';
import 'mixins/has_game_ref.dart';
import 'options.dart';
import 'queryable_ordered_set.dart';
import 'sfx.dart';
import 'world_gen.dart';

math.Random random = new math.Random();

enum GameState { TUTORIAL, PAUSED, RUNNING, DEAD, END_CARD, STOPPED, AD }

class BgugGame extends BaseGame {
  static Options get options => Data.currentOptions;

  double _lastDt;
  bool hasPausedAlready = false;
  bool shouldScore;
  Button button;
  bool won = false;
  int _points = 0,
      currentCoins = 0;
  int totalJumps = 0,
      totalDives = 0;
  int lastGeneratedSector = -1;
  Future<AudioPlayer> music;
  int _currentSlot;
  Ad endGameAd;
  GameState state;

  QueryableOrderedSetImpl queryComponents = new QueryableOrderedSetImpl();

  Player get player => queryComponents.player();

  Hud get hud => queryComponents.hud();

  EndCard get endCard => queryComponents.endCard();

  Tutorial get tutorial => queryComponents.tutorial();

  Iterable<Shooter> get shooters => queryComponents.shooters();

  @override
  OrderedSet<Component> get components => queryComponents;

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
    hasPausedAlready = false;

    _points = 0;
    currentCoins = 0;
    totalJumps = 0;
    totalDives = 0;
    _lastDt = 0;

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
    if (state == GameState.END_CARD || state == GameState.TUTORIAL || state == GameState.PAUSED) {
      return;
    }
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
    if (state == GameState.PAUSED) {
      return;
    }
    if (state == GameState.END_CARD) {
      endCard.click(p);
      return;
    }
    if (state == GameState.TUTORIAL) {
      if (tutorial.tap()) {
        state = GameState.RUNNING;
      }
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
          totalJumps++;
          player.jump(dt);
        } else {
          totalDives++;
          player.dive();
        }
      }
    }
  }

  @override
  void render(Canvas c) {
    if (state == GameState.TUTORIAL || state == GameState.RUNNING || state == GameState.DEAD || state == GameState.END_CARD || state == GameState.PAUSED) {
      super.render(c);
    } else {
      c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), new Paint()..color = material.Colors.black);
    }
  }

  @override
  void update(double dt) {
    if (_lastDt == null) {
      _lastDt = dt;
      return;
    } else {
      _lastDt = dt;
    }

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

  bool handlingClick() {
    return state == GameState.TUTORIAL || state == GameState.RUNNING || state == GameState.END_CARD;
  }

  void award() async {
    if (shouldScore) {
      Data.buy.coins += endCard.coins;
      Data.score.score(this);
      Data.checkAchievementsAndSkins();
      await Data.save();
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (this.state == GameState.PAUSED) {
        music.then((m) => m?.resume());
        Sfx.enable = true;
        this.state = GameState.RUNNING;
        if (hasPausedAlready) {
          player.die();
        } else {
          hasPausedAlready = true;
          addLater(Toast('Beware! You can no longer pause this game!'));
        }
      }
    } else {
      _lastDt = null;
      music.then((m) => m?.pause());
      Sfx.enable = false;
      this.state = GameState.PAUSED;
    }
  }

  Future<bool> willPop() async {
    if (state == GameState.TUTORIAL) {
      state = GameState.RUNNING;
    } else if (this.state == GameState.RUNNING) {
      if (player.dead()) {
        showEndCard();
      } else {
        player.die();
      }
    } else if (this.state == GameState.END_CARD) {
      endCard.doClickBack();
      return true;
    }
    return false;
  }

  void stop() {
    state = GameState.STOPPED;
    music?.then((p) => p?.release());
  }
}
