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

  double _scaleFactor;
  double _tickTimer;
  static const double CLOCK_SPEED = 0.25;

  EndCard() : super.rectangle(1, 1, 'endgame_bg.png');

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Text.render(canvas, 'Total Distance:', const Offset(0, 32.0), fontSize: 18.0, fn: Text.center(width));
    Text.render(canvas, gameRef.hud.maxDistance.toStringAsFixed(2) + ' m', const Offset(0, 48.0), fontSize: 18.0, fn: Text.center(width));

    gem.renderCentered(canvas, Position(width / 2 - 16.0, 96.0), Position(32.0, 32.0));
    Text.render(canvas, '${gameRef.points}', Offset(width / 2 + 16.0, 96.0 - 8.0));

    coin.renderCentered(canvas, Position(width / 2 - 16.0, 142.0), Position(32.0, 32.0));
    Text.render(canvas, '${gameRef.currentCoins}', Offset(width / 2 + 16.0, 142.0 - 8.0));
  }

  void click(Position tap) {
    if (_tickTimer != null) {
      _tickTimer -= 0.2;
      return;
    }
    Rect replay = Rect.fromLTWH(24.0, 80.0, 87.0, 16.0);
    Rect doubleCoins = Rect.fromLTWH(24.0, 100.0, 87.0, 16.0);
    Rect back = Rect.fromLTWH(24.0, 120.0, 87.0, 16.0);

    Offset relativeTap = tap.minus(new Position(x, y)).times(_scaleFactor).toOffset();
    if (replay.contains(relativeTap)) {
      gameRef.restart();
    } else if (doubleCoins.contains(relativeTap)) {
      gameRef.showAd(); // TODO impl double coins later
    } else if (back.contains(relativeTap)) {
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
    _scaleFactor = 144.0 / height;

    x = (size.width - width) / 2;
    y = (size.height - height) / 2;
  }

  @override
  int priority() => 3;

  @override
  bool isHud() => true;
}
