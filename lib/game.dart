import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame_gamepad/flame_gamepad.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart' as material;
import 'package:ordered_set/ordered_set.dart';

import 'ads.dart';
import 'audio.dart';
import 'components/background.dart';
import 'components/block.dart';
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
import 'tutorial_status.dart';
import 'world_gen.dart';

math.Random random = new math.Random();

enum GameState { TUTORIAL, PAUSED, RUNNING, DEAD, END_CARD, STOPPED, AD }

const TextConfig fpsTextConfig = TextConfig();

class BgugGame extends BaseGame {
  static Options get options => Data.currentOptions;

  double _lastDt;
  bool hasPausedAlready;
  bool shouldScore;
  Button button;
  int gems, currentCoins, totalGems;
  int totalJumps, totalDives;
  int lastGeneratedSector;
  GameState state;

  QueryableOrderedSetImpl queryComponents = new QueryableOrderedSetImpl();

  Player get player => queryComponents.player();

  Hud get hud => queryComponents.hud();

  EndCard get endCard => queryComponents.endCard();

  Tutorial get tutorial => queryComponents.tutorial();

  Iterable<Shooter> get shooters => queryComponents.shooters();

  Iterable<BaseBlock> get blocks => queryComponents.blocks();

  int get uppermostOccupiedSlot => blocks.where((b) => b.upper()).fold(0, (total, b2) => math.max(total, b2.slot));

  int get uppermostFreeSlot => uppermostOccupiedSlot == 3 ? null : uppermostOccupiedSlot + 1;

  int get lowermostOccupiedSlot => blocks.where((b) => b.lower()).fold(7, (total, b2) => math.min(total, b2.slot));

  int get lowermostFreeSlot => lowermostOccupiedSlot == 4 ? null : lowermostOccupiedSlot - 1;

  int get nextFreeSlot => Block.SLOT_ORDER.firstWhere((slot) => !blocks.any((b) => b.slot == slot));

  bool get maxedOutBlocks => blocks.length == 8;

  @override
  bool debugMode() => false;

  @override
  OrderedSet<Component> get components => queryComponents;

  BgugGame(this.shouldScore, bool showTutorial) {
    _start(showTutorial ? GameState.TUTORIAL : GameState.RUNNING);
  }

  void showEndCard() {
    state = GameState.END_CARD;
    var endCard = new EndCard();
    endCard.init().then((_) {
      add(endCard);
    });
  }

  void showAd() {
    if (hasAd()) {
      state = GameState.AD;
      Ad.listener = (evt) {
        print('Ad:Event : ${evt.toString()}');
        if (evt == RewardedVideoAdEvent.rewarded) {
          endCard.seenAd = true;
        }
        state = GameState.END_CARD;
      };
      Ad.show();
    }
  }

  bool hasAd() => Ad.loaded;

  void restart() {
    components.clear();
    _start(GameState.RUNNING);
  }

  void _start(GameState state) {
    this.state = state;

    resetVariables();

    add(Background());

    add(Hud());
    add(Top());
    add(Floor());
    add(Player());

    if (options.hasGuns) {
      add(Block(nextFreeSlot, true));
      add(Block(nextFreeSlot, true));
      add(ShooterCane());
      add(Shooter('up'));
      add(Shooter('down'));
      add(button = Button());
    }

    if (this.state == GameState.TUTORIAL) {
      getFirstTutorialStatus().then((state) => add(Tutorial(state)));
    }

    Ad.loadAd();
    Audio.play(Song.GAME);
  }

  void resetVariables() {
    hasPausedAlready = false;

    gems = 0;
    totalGems = 0;
    currentCoins = 0;
    totalJumps = 0;
    totalDives = 0;
    _lastDt = 0;

    lastGeneratedSector = -1;
  }

  @override
  void preAdd(Component c) {
    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }
    super.preAdd(c);
  }

  void startInput(Position p, int dt) {
    if (state == GameState.END_CARD || state == GameState.TUTORIAL || state == GameState.PAUSED) {
      return;
    }
    if (p != null && player != null && !player.dead()) {
      if (p.x < size.width / 2) {
        hud.startGauge();
      } else {
        hud.clearGauge();
      }
    }
  }

  void diveInput() {
    totalDives++;
    player.dive();
    hud.clearGauge();
  }

  void jumpInput(int dt) {
    if (dt > Data.currentOptions.maxHoldJumpMillis) {
      dt = Data.currentOptions.maxHoldJumpMillis;
    }

    totalJumps++;
    player.jump(dt);
  }

  void blockInput() {
    int dPoint = button.click();
    if (dPoint != null) {
      gems -= dPoint;
      add(new BlockTween(button.toPosition(), nextFreeSlot));
    }
  }

  void gamepadInput(String evtType, String key, int dt) {
    if (state == GameState.PAUSED) {
      return;
    }
    if (state == GameState.END_CARD) {
      endCard?.gamepadInput(evtType, key);
      return;
    }
    if (state == GameState.TUTORIAL) {
      if (tutorial != null && tutorial.tap()) {
        state = GameState.RUNNING;
      }
      return;
    }

    if (player.dead()) {
      if (evtType == GAMEPAD_BUTTON_UP)
        showEndCard();
    } else {
      if (evtType == GAMEPAD_BUTTON_DOWN && key == GAMEPAD_BUTTON_A) {
        hud.startGauge();
      } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_BUTTON_A) {
        jumpInput(dt);
        hud.clearGauge();
      } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_DPAD_DOWN) {
        diveInput();
      } else if (evtType == GAMEPAD_BUTTON_UP && key == GAMEPAD_BUTTON_X) {
        blockInput();
      }
    }
  }

  void input(Position p, int dt) {
    if (state == GameState.PAUSED) {
      return;
    }
    if (state == GameState.END_CARD) {
      endCard?.click(p);
      return;
    }
    if (state == GameState.TUTORIAL) {
      if (tutorial != null && tutorial.tap()) {
        state = GameState.RUNNING;
      }
      return;
    }
    if (p != null && player != null) {
      hud.clearGauge();
      if (player.dead()) {
        showEndCard();
      } else {
        if (button != null && button.toRect().contains(p.toOffset())) {
          blockInput();
        } else if (p.x > size.width / 2) {
          diveInput();
        } else {
          jumpInput(dt);
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

    if (debugMode()) {
      fpsTextConfig.render(c, fps(10).toString(), Position(0, 0));
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

  void award() {
    if (shouldScore) {
      Data.buy.coins += endCard.coins;
      Data.stats.calculateStats(this);
      Data.checkAchievementsAndSkins();
      Data.saveAsync();
      print('Saved async');
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    print('Lifecyle $state, game_state: ${this.state}');
    if (this.state == GameState.AD || this.state == GameState.STOPPED || this.state == GameState.END_CARD) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      if (this.state == GameState.PAUSED) {
        Audio.enableSfx = true;
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
      Audio.enableSfx = false;
      this.state = GameState.PAUSED;
    }
  }

  Future<bool> willPop() async {
    print('Called WILL POP, state: $state');
    if (state == GameState.TUTORIAL) {
      state = GameState.RUNNING;
    } else if (this.state == GameState.RUNNING) {
      player.die();
      showEndCard();
    } else if (this.state == GameState.END_CARD) {
      endCard.doClickBack();
      return true;
    }
    return false;
  }

  void stop() {
    state = GameState.STOPPED;
  }

  void dragTo(Position lastDragPos) {
    hud.clearGauge();
  }

  void endDrag(Position lastDragPos) {
    hud.clearGauge();
  }
}
