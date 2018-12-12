import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../util.dart';

class EndCard extends SpriteComponent {
  static const FRAC =  112 / 144;
  static final Sprite gem = new Sprite('gem.png');
  static final Sprite coin = new Sprite('coin.png', width: 16.0);

  double totalDistance;
  int points, coins;

  double _scaleFactor;

  EndCard(this.totalDistance, this.points, this.coins) : super.rectangle(1, 1, 'endgame_bg.png');

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Text.render(canvas, 'Total Distance:', const Offset(0, 32.0), fontSize: 18.0, fn: Text.center(width));
    Text.render(canvas, totalDistance.toStringAsFixed(2), const Offset(0, 48.0), fontSize: 18.0, fn: Text.center(width));

    gem.renderCentered(canvas, Position(width / 2 - 16.0, 96.0), Position(32.0, 32.0));
    Text.render(canvas, '$points', Offset(width / 2 + 16.0, 96.0 - 8.0));

    coin.renderCentered(canvas, Position(width / 2 - 16.0, 142.0), Position(32.0, 32.0));
    Text.render(canvas, '$coins', Offset(width / 2 + 16.0, 142.0 - 8.0));
  }

  int click(Position tap) {
    Rect replay = Rect.fromLTWH(24.0, 80.0, 87.0, 16.0);
    Rect doubleCoins = Rect.fromLTWH(24.0, 100.0, 87.0, 16.0);
    Rect back = Rect.fromLTWH(24.0, 120.0, 87.0, 16.0);

    Offset relativeTap = tap.minus(new Position(x, y)).times(_scaleFactor).toOffset();
    if (replay.contains(relativeTap)) {
      return 0;
    } else if (doubleCoins.contains(relativeTap)) {
      return 1;
    } else if (back.contains(relativeTap)) {
      return 2;
    }

    return -1;
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
