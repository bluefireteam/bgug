import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../iap.dart';
import '../mixins/has_game_ref.dart';
import '../util.dart';

class EndCard extends SpriteComponent with HasGameRef {
  static const COIN_TO_GEM_RATIO = 4;
  static const FRAC = 112 / 144;
  static const CLOCK_SPEED = 0.25;

  static final Sprite gem = new Sprite('gem.png');
  static final Sprite coin = new Sprite('coin.png', width: 16.0);

  static final Sprite buttonReplay = new Sprite('endgame_buttons.png', height: 16.0);
  static final Sprite buttonGoBack = new Sprite('endgame_buttons.png', height: 16.0, y: 32.0);
  static final Sprite buttonX2Coins = new Sprite('endgame_buttons.png', height: 16.0, y: 16.0);

  bool get doubleCoins => IAP.pro;
  double _tickTimer;
  bool loading = false;

  int get coins => (doubleCoins ? 2 : 1) * gameRef.currentCoins;

  double get _scaleFactor => height / 144.0;

  bool get _showAdButton => gameRef.hasAd() && !doubleCoins;

  Position get _buttonSize => new Position(_scaleFactor * 64.0, _scaleFactor * 16.0);

  Position get _replayPosition => new Position((width - _buttonSize.x) / 2, _scaleFactor * 80);

  Position get _goBackPosition => new Position((width - _buttonSize.x) / 2, _scaleFactor * 100);

  Position get _x2Position => new Position((width - _buttonSize.x) / 2, _scaleFactor * 120);

  EndCard() : super.rectangle(1, 1, 'endgame_bg.png');

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (loading) {
      smallText.render(canvas, 'Loading...', Position(width / 2, height / 2), anchor: Anchor.center);
      return;
    }

    smallText.render(canvas, 'Total Distance:', Position(width / 2, 32.0), anchor: Anchor.topCenter);
    smallText.render(canvas, gameRef.hud.maxDistanceInMeters.toStringAsFixed(2) + ' m', Position(width / 2, 48.0), anchor: Anchor.topCenter);

    gem.renderCentered(canvas, Position(width / 2 - 16.0, 96.0), Position(32.0, 32.0));
    defaultText.render(canvas, '${gameRef.points}', Position(width / 2 + 16.0, 96.0 - 8.0));

    coin.renderCentered(canvas, Position(width / 2 - 16.0, 142.0), Position(32.0, 32.0));
    bool lastTicks = _tickTimer != null && _tickTimer < CLOCK_SPEED / 3;
    Color color = doubleCoins || lastTicks ? const Color(0xFF10D594) : const Color(0xFF404040);
    defaultText.withColor(color).render(canvas, '$coins', Position(width / 2 + 16.0, 142.0 - 8.0));

    buttonReplay.renderPosition(canvas, _replayPosition, _buttonSize);
    buttonGoBack.renderPosition(canvas, _goBackPosition, _buttonSize);

    if (_showAdButton) {
      buttonX2Coins.renderPosition(canvas, _x2Position, _buttonSize);
    }
  }

  void click(Position tap) {
    if (_tickTimer != null) {
      _tickTimer -= 0.2;
      return;
    }

    if (loading) {
      return;
    }

    Rect replay = Position.rectFrom(_replayPosition, _buttonSize);
    Rect doubleCoins = Position.rectFrom(_x2Position, _buttonSize);
    Rect back = Position.rectFrom(_goBackPosition, _buttonSize);

    Offset relativeTap = tap.minus(new Position(x, y)).toOffset();
    if (replay.contains(relativeTap)) {
      doClickReplay();
    } else if (_showAdButton && doubleCoins.contains(relativeTap)) {
      doClickShowAd();
    } else if (back.contains(relativeTap)) {
      doClickBack();
    }
  }

  void doClickReplay() async {
    loading = true;
    await gameRef.award();
    gameRef.restart();
    loading = false;
  }

  void doClickShowAd() {
    loading = true;
    gameRef.showAd();
    loading = false;
  }

  Future doClickBack() async {
    loading = true;
    await gameRef.award();
    gameRef.stop();
    loading = false;
  }

  @override
  void update(double dt) {
    if (_tickTimer != null) {
      _tickTimer -= dt;
      while (_tickTimer != null && _tickTimer <= 0) {
        if (gameRef.points >= COIN_TO_GEM_RATIO) {
          gameRef.points -= COIN_TO_GEM_RATIO;
          gameRef.currentCoins++;
        } else {
          gameRef.points = 0;
        }

        if (gameRef.points == 0) {
          _tickTimer = null;
        } else {
          _tickTimer += CLOCK_SPEED;
        }
      }
    } else if (gameRef.points > 0) {
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
