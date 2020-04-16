import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame_gamepad/flame_gamepad.dart';

import '../game.dart';
import '../iap.dart';
import '../util.dart';

class EndCard extends SpriteComponent with HasGameRef<BgugGame> {
  static const COIN_TO_GEM_RATIO = 4;
  static const FRAC = 112 / 144;
  static const CLOCK_SPEED = 0.25;

  static final Sprite gem = Sprite('gem.png');
  static final Sprite coin = Sprite('coin.png', width: 16.0);

  static final Sprite buttonReplayNormal = Sprite('endgame_buttons.png', height: 16.0);
  static final Sprite buttonGoBackNormal = Sprite('endgame_buttons.png', height: 16.0, y: 32.0);
  static final Sprite buttonX2CoinsNormal = Sprite('endgame_buttons.png', height: 16.0, y: 16.0);

  static final Sprite buttonReplayGamepad = Sprite('endgame_buttons_gamepad.png', height: 16.0);
  static final Sprite buttonGoBackGamepad = Sprite('endgame_buttons_gamepad.png', height: 16.0, y: 32.0);
  static final Sprite buttonX2CoinsGamepad = Sprite('endgame_buttons_gamepad.png', height: 16.0, y: 16.0);

  bool isGamepadConnected = false;

  Sprite get buttonReplay => isGamepadConnected ? buttonReplayGamepad : buttonReplayNormal;
  Sprite get buttonGoBack => isGamepadConnected ? buttonGoBackGamepad : buttonGoBackNormal;
  Sprite get buttonX2Coins => isGamepadConnected ? buttonX2CoinsGamepad : buttonX2CoinsNormal;

  bool get doubleCoins => seenAd || IAP.pro;
  bool seenAd = false;

  double _tickTimer;

  int get coins => (doubleCoins ? 2 : 1) * gameRef.currentCoins;

  double get _scaleFactor => height / 144.0;

  bool get _showAdButton => !doubleCoins && gameRef.hasAd();

  Position get _buttonSize => Position(_scaleFactor * 64.0, _scaleFactor * 16.0);

  Position get _replayPosition => Position((width - _buttonSize.x) / 2, _scaleFactor * 80);

  Position get _goBackPosition => Position((width - _buttonSize.x) / 2, _scaleFactor * 100);

  Position get _x2Position => Position((width - _buttonSize.x) / 2, _scaleFactor * 120);

  EndCard() : super.rectangle(1, 1, 'endgame_bg.png');

  Future<void> init() async {
    isGamepadConnected = await FlameGamepad.isGamepadConnected;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    smallText.render(canvas, 'Total Distance:', Position(width / 2, 32.0), anchor: Anchor.topCenter);
    smallText.render(canvas, gameRef.hud.maxDistanceInMeters.toStringAsFixed(2) + ' m', Position(width / 2, 48.0), anchor: Anchor.topCenter);

    gem.renderCentered(canvas, Position(width / 2 - 16.0, 96.0), size: Position(32.0, 32.0));
    defaultText.render(canvas, '${gameRef.gems}', Position(width / 2 + 16.0, 96.0 - 8.0));

    coin.renderCentered(canvas, Position(width / 2 - 16.0, 142.0), size: Position(32.0, 32.0));
    final lastTicks = _tickTimer != null && _tickTimer < CLOCK_SPEED / 3;
    final color = doubleCoins || lastTicks ? const Color(0xFF10D594) : const Color(0xFF404040);
    defaultText.withColor(color).render(canvas, '$coins', Position(width / 2 + 16.0, 142.0 - 8.0));

    buttonReplay.renderPosition(canvas, _replayPosition, size: _buttonSize);
    buttonGoBack.renderPosition(canvas, _goBackPosition, size: _buttonSize);

    if (_showAdButton) {
      buttonX2Coins.renderPosition(canvas, _x2Position, size: _buttonSize);
    }
  }

  void gamepadInput(String evtType, String key) {
    if (evtType == GAMEPAD_BUTTON_UP) {
      if (key == GAMEPAD_BUTTON_A) {
        doClickReplay();
      } else if (key == GAMEPAD_BUTTON_Y) {
        doClickShowAd();
      } else if (key == GAMEPAD_BUTTON_B) {
        doClickBack();
      }
    }
  }

  void click(Position tap) {
    if (_tickTimer != null) {
      _tickTimer -= 0.2;
      return;
    }

    final replay = Position.rectFrom(_replayPosition, _buttonSize);
    final doubleCoins = Position.rectFrom(_x2Position, _buttonSize);
    final back = Position.rectFrom(_goBackPosition, _buttonSize);

    final relativeTap = tap.minus(Position(x, y)).toOffset();
    if (replay.contains(relativeTap)) {
      doClickReplay();
    } else if (_showAdButton && doubleCoins.contains(relativeTap)) {
      doClickShowAd();
    } else if (back.contains(relativeTap)) {
      doClickBack();
    }
  }

  void doClickReplay() {
    print('Clicked replay');
    gameRef.award();
    gameRef.restart();
    print('Restarted');
  }

  void doClickShowAd() {
    print('Clicked ad');
    gameRef.showAd();
    print('Shown ad');
  }

  void doClickBack() {
    print('Clicked go back');
    gameRef.award();
    gameRef.stop();
    print('Stopped');
  }

  @override
  void update(double dt) {
    if (_tickTimer != null) {
      _tickTimer -= dt;
      while (_tickTimer != null && _tickTimer <= 0) {
        if (gameRef.gems >= COIN_TO_GEM_RATIO) {
          gameRef.gems -= COIN_TO_GEM_RATIO;
          gameRef.currentCoins++;
        } else {
          gameRef.gems = 0;
        }

        if (gameRef.gems == 0) {
          _tickTimer = null;
        } else {
          _tickTimer += CLOCK_SPEED;
        }
      }
    } else if (gameRef.gems > 0) {
      _tickTimer = CLOCK_SPEED;
    }
  }

  @override
  void resize(Size size) {
    height = size.height * 0.8;
    width = FRAC * height;

    x = (size.width - width) / 2;
    y = (size.height - height) / 2;
  }

  @override
  int priority() => 3;

  @override
  bool isHud() => true;
}
