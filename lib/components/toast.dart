import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/text_config.dart';

import '../palette.dart';

TextBoxConfig boxConfig = const TextBoxConfig(
  maxWidth: 400.0,
  margin: 8.0,
  timePerChar: 0.0,
  dismissDelay: 3.0,
);

TextConfig textConfig = TextConfig(
  fontFamily: '5x5',
  fontSize: 16.0,
  color: Palette.text.color,
);

class Toast extends TextBoxComponent {
  Toast(String text) : super(text, config: textConfig, boxConfig: boxConfig) {
    anchor = Anchor.topCenter;
  }

  @override
  void drawBackground(Canvas c) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(0.0, 0.0, width, height), const Radius.circular(20.0));
    c.drawRRect(rect, Palette.bg.paint);
  }

  @override
  void resize(Size size) {
    x = size.width / 2;
    y = 8.0;
  }

  @override
  bool destroy() => finished;

  @override
  int priority() => 20;

  @override
  bool isHud() => true;
}
