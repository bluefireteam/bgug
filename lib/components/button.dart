import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:flame/flame.dart';
import 'package:flame/components/component.dart';

import '../data.dart';
import '../util.dart';

class Button extends SpriteComponent {
  static const MARGIN = 4.0;
  int cost, incCost;
  bool active = false;

  Button() : super.square(64.0, 'button.png') {
    cost = Data.options.buttonCost;
    incCost = Data.options.buttonIncCost;
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
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
      material.TextPainter tp = Flame.util.text(
        toUpperCaseNumber(cost.toString()),
        fontFamily: 'Blox2',
        fontSize: 32.0,
        color: active ? material.Colors.green : material.Colors.blueGrey,
      );
      tp.paint(canvas, new Offset(32.0 - tp.width / 2, 32.0));
    }
  }

  @override
  void resize(Size size) {
    x = MARGIN;
    y = MARGIN;
  }

  @override
  bool isHud() => true;
}