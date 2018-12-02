import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart' as material;
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/sprite.dart';

import '../mixins/has_game_ref.dart';

class Hud extends SpriteComponent with HasGameRef, Resizable {
  static const SRC_WIDTH = 220.0;
  static const SRC_HEIGHT = 32.0;

  static const SCALE = 2;

  static const WIDTH = SCALE * SRC_WIDTH;
  static const HEIGHT = SCALE * SRC_HEIGHT;

  static final bgPaint = new Paint()..color = const Color(0xFF828588);

  Rect bgRect;

  Hud()
      : super.fromSprite(WIDTH, HEIGHT,
            new Sprite('hud_bg.png', width: SRC_WIDTH, height: SRC_HEIGHT));

  @override
  void resize(Size size) {
    this.x = (size.width - WIDTH) / 2;
    this.y = 0.0;
    this.bgRect = new Rect.fromLTWH(0.0, 0.0, size.width, HEIGHT);
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
        canvas.restore();
      }
    }
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 1;

  void renderGems(Canvas canvas) {
    const where = Offset(SCALE * 161.0, SCALE * 10.0);
    renderText(canvas, gameRef.points.toString(), where);
  }

  void renderCoins(Canvas canvas) {
    const where = Offset(SCALE * 200.0, SCALE * 10.0);
    renderText(canvas, gameRef.currentCoins.toString(), where);
  }

  void renderText(Canvas canvas, String text, Offset where) {
    material.TextPainter tp = Flame.util.text(
      text,
      fontFamily: '5x5',
      fontSize: 28.0,
      color: const Color(0xFF404040),
    );
    tp.paint(canvas, where);
  }
}
