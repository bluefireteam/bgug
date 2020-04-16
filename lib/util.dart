import 'dart:ui';

import 'package:flame/text_config.dart';

class Impulse {
  double force;
  double time;

  Impulse(this.force) {
    time = 0.0;
  }

  void impulse(double dt) {
    time += dt;
  }

  double tick(double dt) {
    if (time <= 0) {
      return 0.0;
    }
    time -= dt;
    return force;
  }

  void clear() {
    time = 0.0;
  }
}

const TextConfig defaultText = const TextConfig(
  fontFamily: '5x5',
  fontSize: 28.0,
  color: const Color(0xFF404040),
);

TextConfig smallText = defaultText.withFontSize(18.0);