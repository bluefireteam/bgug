import 'package:flame/flame.dart';

class Sfx {
  static bool enable = true;

  static void play(String file) {
    if (enable) {
      Flame.audio.play(file);
    }
  }
}
