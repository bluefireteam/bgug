import 'dart:ui';
import 'dart:math' as math;

import 'package:bgug/game.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import '../data.dart';

import '../util.dart';
import '../constants.dart';

class Hud extends SpriteComponent with HasGameRef<BgugGame>, Resizable {
  static const SRC_WIDTH = 220.0;
  static const SRC_HEIGHT = 32.0;

  static const SCALE = 2;

  static const WIDTH = SCALE * SRC_WIDTH;
  static const HEIGHT = SCALE * SRC_HEIGHT;

  static final Position _coinPosition = Position(SCALE * 200.0, SCALE * 10.0);
  static final Position _gemPosition = Position(SCALE * 161.0, SCALE * 10.0);

  static final bgPaint = Paint()..color = const Color(0xFF626262);

  Rect bgRect;
  double gaugeStrength, clock;
  double meterPerPixel = 1.0;
  double maxDistance = 0.0;

  double get maxDistanceInMeters => maxDistance * meterPerPixel;

  Hud() : super.fromSprite(WIDTH, HEIGHT, Sprite('hud_bg.png', width: SRC_WIDTH, height: SRC_HEIGHT));

  Position get gemPosition => Position(x + SCALE * 141, y + SCALE * 7);

  @override
  void update(double t) {
    super.update(t);
    if (clock != null) {
      clock += t;
      final diff = clock;
      final max = Data.currentOptions.maxHoldJumpMillis.toDouble() / 1000.0;
      gaugeStrength = math.min(diff, max) / max;
    } else {
      gaugeStrength = null;
    }
  }

  @override
  void resize(Size size) {
    x = (size.width - WIDTH) / 2;
    y = 4.0;
    bgRect = Rect.fromLTWH(0.0, 0.0, size.width, HEIGHT);
    meterPerPixel = .75 / sizeTenth(size);
  }

  @override
  void render(Canvas canvas) {
    if (bgRect != null) {
      canvas.drawRect(bgRect, bgPaint);

      if (sprite.loaded()) {
        canvas.save();
        prepareCanvas(canvas);
        sprite.render(canvas, width: width, height: height);
        renderGems(canvas);
        renderCoins(canvas);
        renderDistance(canvas);
        renderGauge(canvas);
        canvas.restore();
      }
    }
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 1;

  void startGauge() {
    clock = 0;
  }

  void clearGauge() {
    clock = null;
  }

  void renderDistance(Canvas canvas) {
    const XI = SCALE * 78.0;
    const XF = SCALE * 123.0;
    const SIZE = XF - XI;
    const Y = SCALE * 10.0;

    final Position where = Position(XI + SIZE / 2, Y);
    if (gameRef.player.x > maxDistance) {
      maxDistance = gameRef.player.x;
    }
    final dist = maxDistanceInMeters.toStringAsFixed(1);
    defaultText.render(canvas, '$dist m', where, anchor: Anchor.topCenter);
  }

  void renderGems(Canvas canvas) {
    defaultText.render(canvas, gameRef.gems.toString(), _gemPosition);
  }

  void renderCoins(Canvas canvas) {
    defaultText.render(canvas, gameRef.currentCoins.toString(), _coinPosition);
  }

  Position getActualCoinPosition() {
    return toPosition().add(_coinPosition);
  }

  void renderGauge(Canvas canvas) {
    if (gaugeStrength == null) {
      return;
    }
    const COLORS = [Color(0XFF54A286), Color(0XFF10D594)];
    const MAX = 62;
    const GAUGE_X = 9;
    const GAUGE_Y = 17;
    const GAUGE_HEIGHT = 7;
    const STEP = 2;
    final s = SCALE.toDouble();
    final sizePxs = (gaugeStrength * MAX).round();
    for (int i = GAUGE_X, j = 0; i < sizePxs; i += STEP, j++) {
      final color = COLORS[j % 2];
      canvas.drawRect(Rect.fromLTWH(s * i, s * GAUGE_Y, s * STEP, s * GAUGE_HEIGHT), Paint()..color = color);
    }
  }
}
