import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;

import '../data.dart';
import '../mixins/has_game_ref.dart';
import '../util.dart';

class Button extends PositionComponent with HasGameRef, Resizable {
  static const MARGIN = 4.0;
  static const SIZE = 84.0;
  static const CUSTOM_MARGIN = 26.0;
  int cost, incCost;

  bool get active => gameRef.gems >= cost;
  bool get ghost => gameRef.maxedOutBlocks;

  Animation activeAnimation;
  Sprite inactiveSprite;

  static Sprite gem = new Sprite('gem.png');

  Button() {
    width = height = SIZE;
    cost = Data.currentOptions.buttonCost;
    incCost = Data.currentOptions.buttonIncCost;

    activeAnimation = new Animation.sequenced('button.png', 7, textureX: 68.0, textureWidth: 68.0, textureHeight: 68.0);
    inactiveSprite = new Sprite('button.png', width: 68.0);
  }

  void update(double dt) {
    activeAnimation.update(dt);
  }

  bool canClick() {
    return !ghost && active;
  }

  int click() {
    if (canClick()) {
      int currentCost = cost;
      cost += incCost;
      return currentCost;
    }
    return null;
  }

  @override
  void render(Canvas canvas) {
    final Paint white = BasicPalette.white.paint;
    final Paint transparent = BasicPalette.black.withAlpha(120).paint;
    Sprite sprite = !ghost && active ? activeAnimation.getSprite() : inactiveSprite;
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.paint = ghost ? transparent : white;
      sprite.render(canvas, width: width, height: height);
      if (!ghost) {
        Flame.util.drawWhere(canvas, new Position(CUSTOM_MARGIN - 8, CUSTOM_MARGIN - 8.0), (c) {
          gem.renderRect(c, new Rect.fromLTWH(-8.0, -16.0, 16.0, 16.0));
          renderText(c);
        });
      }
    }
  }

  void renderText(Canvas canvas) {
    Position p = new Position(width / 2, -18.0);
    Color color = active ? material.Colors.green : const Color(0xFF404040);
    smallText.withColor(color).render(canvas, '${gameRef.gems} / $cost', p, anchor: Anchor.topCenter);
  }

  @override
  void resize(Size size) {
    x = size.width - MARGIN - width - CUSTOM_MARGIN;
    y = MARGIN + 24.0 - CUSTOM_MARGIN;
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 20;
}
