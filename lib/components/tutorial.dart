import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import '../tutorial_status.dart';

class Tutorial extends PositionComponent {
  static const FRAC = 192.0 / 162.0;

  static final Sprite p1 = Sprite('tutorial.png');
  static final Sprite p1gp = Sprite('tutorial-gamepad.png');
  static final Sprite p2 = Sprite('tutorial-2.png');

  TutorialStatus status;

  Tutorial(this.status);

  @override
  void resize(Size size) {
    width = (2 * size.width / 3) - 10;
    height = (width / FRAC) - 5;

    x = ((size.width - width) / 2) + 5;
    y = ((size.height - height) / 2) + 5;
  }

  @override
  int priority() => 18;

  @override
  bool destroy() => status == TutorialStatus.NOT_SHOWING;

  bool tap() {
    status = getNextStatus(status);
    return destroy();
  }

  Sprite _sprite() {
    switch (status) {
      case TutorialStatus.PAGE_0_GAMEPAD:
        return p1gp;
      case TutorialStatus.PAGE_0_REGULAR:
        return p1;
      case TutorialStatus.PAGE_1:
        return p2;
      default:
        return null;
    }
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    _sprite()?.render(c, width: width, height: height);
  }
}
