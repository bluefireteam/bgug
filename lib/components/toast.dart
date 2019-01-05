import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_box_component.dart';

TextBoxConfig config = TextBoxConfig(
  maxWidth: 400.0,
  margin: 8.0,
  timePerChar: 0.0,
  dismissDelay: 4,
);

class Toast extends TextBoxComponent {
  Toast(String text) : super(text, boxConfig: config) {
    anchor = Anchor.bottomCenter;
  }

  @override
  void drawBackground(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0.0, 0.0, width, height), Radius.circular(20.0)), new Paint()..color = const Color(0xFFFF00FF));
  }

  @override
  resize(Size size) {
    x = size.width / 2;
    y = size.height - 8.0;
  }

  @override
  bool destroy() => finished;

  @override
  int priority() => 20;

  @override
  bool isHud() => true;
}
