import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart' as material;

String toUpperCaseNumber(String t) {
  const Map<String, String> MAP = const {
    '1': '!',
    '2': '@',
    '3': '#',
    '4': '\$',
    '5': '%',
    '6': '¨',
    '7': '&',
    '8': '*',
    '9': '(',
    '0': ')'
  };
  return t.split('').map((e) => MAP[e]).join('');
}

class Impulse {
  double force;
  double time;

  Impulse(this.force) {
    this.time = 0.0;
  }

  void impulse(double dt) {
    this.time += dt;
  }

  double tick(double dt) {
    if (time <= 0) {
      return 0.0;
    }
    time -= dt;
    return force;
  }

  void clear() {
    this.time = 0.0;
  }
}

class Text {
  static Offset left(Offset o, material.TextPainter tp) => o;

  static Offset Function(Offset, material.TextPainter) center(double size) =>
      (where, tp) => Offset(where.dx + (size - tp.width) / 2, where.dy);

  static void render(Canvas canvas, String text, Offset where, {
    double fontSize = 28.0,
    Offset Function(Offset, material.TextPainter) fn = left,
    Color color = const Color(0xFF404040),
  }) {
    material.TextPainter tp = Flame.util.text(
      text,
      fontFamily: '5x5',
      fontSize: fontSize,
      color: color,
    );
    tp.paint(canvas, fn(where, tp));
  }
}
