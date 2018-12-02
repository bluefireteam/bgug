import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;
import 'package:flame/flame.dart';

import '../data.dart';
import '../util.dart';

class Button extends PositionComponent with Resizable {
  static const MARGIN = 4.0;
  static const SIZE = 48.0;
  int cost, incCost;
  bool active = false;

  Animation activeAnimation;
  Sprite inactiveSprite;

  Button() {
    width = height = SIZE;
    cost = Data.options.buttonCost;
    incCost = Data.options.buttonIncCost;

    activeAnimation = new Animation.sequenced('button.png', 4, textureX: 40.0, textureWidth: 40.0);
    inactiveSprite = new Sprite('button.png', width: 40.0);
  }

  void update(double dt) {
    activeAnimation.update(dt);
  }

  void evaluate(int points) {
    active = points >= cost;
  }

  int click(int points) {
    if (active) {
      int currentCost = cost;
      cost += incCost;
      return currentCost;
    }
    return 0;
  }

  @override
  void render(Canvas canvas) {
    Sprite sprite = active ? activeAnimation.getSprite() : inactiveSprite;
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
      renderText(canvas);
    }
  }

  void renderText(Canvas canvas) {
    material.TextPainter tp = Flame.util.text(
      toUpperCaseNumber(cost.toString()),
      fontFamily: '5x5',
      fontSize: 32.0,
      color: active ? material.Colors.green : material.Colors.blueGrey,
    );
    tp.paint(canvas, new Offset(32.0 - tp.width / 2, 32.0));
  }

  @override
  void resize(Size size) {
    x = size.width - MARGIN - width;
    y = MARGIN + 16.0;
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 2;
}