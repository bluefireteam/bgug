import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart' as material;
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/sprite.dart';

import '../data.dart';
import '../constants.dart';
import '../mixins/has_game_ref.dart';

class Hud extends SpriteComponent with HasGameRef, Resizable {
  static const SRC_WIDTH = 220.0;
  static const SRC_HEIGHT = 32.0;

  static const SCALE = 2;

  static const WIDTH = SCALE * SRC_WIDTH;
  static const HEIGHT = SCALE * SRC_HEIGHT;

  static final bgPaint = new Paint()..color = const Color(0xFF828588);

  Rect bgRect;
  double gaugeStrength, clock;
  double meterPerPixel = 1.0;
  double maxDistance = 0.0;

  Hud()
      : super.fromSprite(WIDTH, HEIGHT,
            new Sprite('hud_bg.png', width: SRC_WIDTH, height: SRC_HEIGHT));

  @override
  void update(double t) {
    super.update(t);
    if (clock != null) {
      clock += t;
      double diff = clock;
      double max = Data.options.maxHoldJumpMillis.toDouble() / 1000.0;
      gaugeStrength = math.min(diff, max) / max;
    } else {
      gaugeStrength = null;
    }
  }

  @override
  void resize(Size size) {
    this.x = (size.width - WIDTH) / 2;
    this.y = 0.0;
    this.bgRect = new Rect.fromLTWH(0.0, 0.0, size.width, HEIGHT);
    this.meterPerPixel = .75 / size_tenth(size);
  }

  @override
  void render(Canvas canvas) {
    if (bgRect != null) {
      canvas.drawRect(bgRect, bgPaint);

      if (sprite.loaded()) {
        canvas.save();
        prepareCanvas(canvas);
        sprite.render(canvas, width, height);
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
    this.clock = 0;
  }

  void clearGauge() {
    this.clock = null;
  }

  void renderDistance(Canvas canvas) {
    const XI = SCALE * 78.0;
    const XF = SCALE * 123.0;
    const SIZE = XF - XI;
    const Y = SCALE * 10.0;
    const where = Offset(XI, Y);
    if (gameRef.player.x > maxDistance) {
      maxDistance = gameRef.player.x;
    }
    String dist = (maxDistance * this.meterPerPixel).toStringAsFixed(1);
    renderText(canvas, '$dist m', where, fn: _center(SIZE));
  }

  void renderGems(Canvas canvas) {
    const where = Offset(SCALE * 161.0, SCALE * 10.0);
    renderText(canvas, gameRef.points.toString(), where);
  }

  void renderCoins(Canvas canvas) {
    const where = Offset(SCALE * 200.0, SCALE * 10.0);
    renderText(canvas, gameRef.currentCoins.toString(), where);
  }

  static Offset _identity(Offset o, material.TextPainter tp) => o;
  static Offset Function(Offset, material.TextPainter) _center(double size) => (where, tp) => Offset(where.dx + (size - tp.width) / 2, where.dy);

  void renderText(Canvas canvas, String text, Offset where, { Offset Function(Offset, material.TextPainter) fn = _identity }) {
    material.TextPainter tp = Flame.util.text(
      text,
      fontFamily: '5x5',
      fontSize: 28.0,
      color: const Color(0xFF404040),
    );
    tp.paint(canvas, fn(where, tp));
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
    double s = SCALE.toDouble();
    int sizePxs = (gaugeStrength * MAX).round();
    for (int i = GAUGE_X, j = 0; i < sizePxs; i += STEP, j++) {
      Color color = COLORS[j % 2];
      canvas.drawRect(Rect.fromLTWH(s * i, s * GAUGE_Y, s * STEP, s * GAUGE_HEIGHT), new Paint()..color = color);
    }
  }
}
