import 'dart:io';
import 'package:flame_gamepad/flame_gamepad.dart';

enum TutorialStatus { NOT_SHOWING, PAGE_0_REGULAR, PAGE_0_GAMEPAD, PAGE_1 }

Future<TutorialStatus> getFirstTutorialStatus() async {
  final gamepad = Platform.isAndroid && await FlameGamepad.isGamepadConnected;
  return gamepad ? TutorialStatus.PAGE_0_GAMEPAD : TutorialStatus.PAGE_0_REGULAR;
}

TutorialStatus getNextStatus(TutorialStatus current) {
  if (current == TutorialStatus.PAGE_0_GAMEPAD || current == TutorialStatus.PAGE_0_REGULAR) {
    return TutorialStatus.PAGE_1;
  } else {
    return TutorialStatus.NOT_SHOWING;
  }
}
