import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Lock extends Component {
  static final Sprite lock = new Sprite('lock.png', width: 40, height: 27);
  static final Sprite lockOpen = new Sprite('lock.png', width: 40, height: 27, x: 400.0 - 40);
  static final Animation lockAnimation = new Animation.sequenced('lock.png', 9, textureWidth: 40, textureX: 40, stepTime: 0.1);

  static const S = 1.2;
  static final Position mySize = Position(S * 40, S * 27);

  bool Function() isVisible;
  bool closed;
  Position p;
  Animation animation;

  Lock(this.isVisible) {
    this.p = Position.empty();
    reset();
  }

  void reset() {
    this.closed = true;
    this.animation = new Animation([], loop: false);
    lockAnimation.frames.forEach((frame) {
      this.animation.frames.add(frame);
    });
    this.animation.frames.add(new Frame(lockOpen, 0.5));
  }

  Sprite get _current => closed ? lock : animation.getSprite();

  @override
  void render(Canvas c) {
    if (!isVisible() || animation.done()) {
      return;
    }
    _current.renderCentered(c, p, size: mySize);
  }

  @override
  void resize(Size size) {
    double frac = 6;
    double skinWidth = frac * 16.0;

    p.x = (size.width - skinWidth - mySize.x) / 2;
    p.y = sizeBottom(size) - mySize.y;
  }

  @override
  void update(double t) {
    if (!closed) {
      animation.update(t);
    }
  }
}
