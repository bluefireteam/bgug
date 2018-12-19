import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../util.dart';
import '../game.dart';
import '../mixins/has_game_ref.dart';

class EndCard extends SpriteComponent with HasGameRef {
  static const FRAC = 112 / 144;
  static final Sprite gem = new Sprite('gem.png');
  static final Sprite coin = new Sprite('coin.png', width: 16.0);

  static final Sprite buttonReplay = new Sprite('endgame_buttons.png', height: 16.0);
  static final Sprite buttonX2Coins = new Sprite('endgame_buttons.png', height: 16.0, y: 16.0);
  static final Sprite buttonGoBack = new Sprite('endgame_buttons.png', height: 16.0, y: 32.0);

  bool doubleCoins = false; // TODO allow Player to buy this!
  double _tickTimer;
  static const double CLOCK_SPEED = 0.25;

  int get coins => (doubleCoins ? 2 : 1) * gameRef.currentCoins;
  double get _scaleFactor => height / 144.0;

  bool get _showAdButton => gameRef.hasAd() && !doubleCoins;
  Position get _buttonSize => new Position(_scaleFactor * 64.0, _scaleFactor * 16.0);

  Position get _replayPosition => new Position((width - _buttonSize.x) / 2, _scaleFactor * 80);
  Position get _x2Position => new Position((width - _buttonSize.x) / 2, _scaleFactor * 100);
  Position get _goBackPosition => new Position((width - _buttonSize.x) / 2, _scaleFactor * 120);

  EndCard() : super.rectangle(1, 1, 'endgame_bg.png');

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Text.render(canvas, 'Total Distance:', const Offset(0, 32.0), fontSize: 18.0, fn: Text.center(width));
    Text.render(canvas, gameRef.hud.maxDistanceInMeters.toStringAsFixed(2) + ' m', const Offset(0, 48.0), fontSize: 18.0, fn: Text.center(width));

    gem.renderCentered(canvas, Position(width / 2 - 16.0, 96.0), Position(32.0, 32.0));
    Text.render(canvas, '${gameRef.points}', Offset(width / 2 + 16.0, 96.0 - 8.0));

    coin.renderCentered(canvas, Position(width / 2 - 16.0, 142.0), Position(32.0, 32.0));
    Color color = doubleCoins ? const Color(0xFF10D594) : const Color(0xFF404040);
    Text.render(canvas, '$coins', Offset(width / 2 + 16.0, 142.0 - 8.0), color: color);

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
    Rect replay = Position.rectFrom(_replayPosition, _buttonSize);
    Rect doubleCoins = Position.rectFrom(_x2Position, _buttonSize);
    Rect back = Position.rectFrom(_goBackPosition, _buttonSize);

    Offset relativeTap = tap.minus(new Position(x, y)).toOffset();
    if (replay.contains(relativeTap)) {
      gameRef.award(coins);
      gameRef.restart();
    } else if (_showAdButton && doubleCoins.contains(relativeTap)) {
      gameRef.showAd();
    } else if (back.contains(relativeTap)) {
      gameRef.award(coins);
      gameRef.state = GameState.STOPPED;
    }
  }

  @override
  void update(double dt) {
    if (_tickTimer != null) {
      _tickTimer -= dt;
      while (_tickTimer != null && _tickTimer <= 0) {
        gameRef.points--;
        gameRef.currentCoins++;
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
