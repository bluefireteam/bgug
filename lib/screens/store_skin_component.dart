import 'dart:ui';

import 'package:flame/animation.dart' as animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/sprite.dart';

import '../constants.dart';

class Place {
  static const List<Place> places = [
    Place._(-1.0 / 8, 1.0 / 8, out: true),
    Place._(1.0 / 8, 1.0 / 4),
    Place._(1.0 / 4, 1.0 / 2),
    Place._(1.0 / 2, 1.0),
    Place._(3.0 / 4, 1.0 / 2),
    Place._(7.0 / 8, 1.0 / 4),
    Place._(9.0 / 8, 1.0 / 8, out: true),
  ];

  final double x, scale;
  final bool out;

  const Place._(this.x, this.scale, {this.out = false});

  Place get prev {
    int idx = places.indexOf(this) - 1;
    return _get(idx);
  }

  Place get next {
    int idx = places.indexOf(this) + 1;
    return _get(idx);
  }

  Place _get(int idx) {
    if (idx < 0 || idx >= places.length) {
      return null;
    }
    return places[idx];
  }
}

class PlaceTween {
  static const SPEED = 2.5;

  static PlaceTween get left => new PlaceTween(Place.places.first, Place.places.first.next);

  static PlaceTween get right => new PlaceTween(Place.places.last, Place.places.last.prev);

  Place start, end;
  double progress;

  PlaceTween(this.start, this.end) : progress = 0.0;

  void update(double dt) {
    progress += SPEED * dt;
    progress = progress.clamp(0.0, 1.0);
  }

  double get x => start.x + (end.x - start.x) * progress;

  double get scale => start.scale + (end.scale - start.scale) * progress;

  bool get isMoving => progress < 1.0;

  bool get isOut => end.out && !isMoving;
}

enum StartingPlace { LEFT, RIGHT }

class StoreSkinComponent extends AnimationComponent with Resizable {
  static const FRAC = 5;

  String skin;
  PlaceTween _tween;
  bool locked;

  StoreSkinComponent(StartingPlace startingPlace, this.skin, this.locked) : super(1.0, 1.0, makeAnimation(skin)) {
    _tween = startingPlace == StartingPlace.LEFT ? PlaceTween.left : PlaceTween.right;
  }

  StoreSkinComponent.startAt(Place place, this.skin, this.locked) : super(1.0, 1.0, makeAnimation(skin)) {
    _tween = new PlaceTween(place.prev, place)..progress = 1.0;
  }

  @override
  void render(Canvas canvas) {
    if (loaded()) {
      prepareCanvas(canvas);
      Sprite sprite = this.animation.getSprite();
      int alpha = locked ? 50 : 255;
      sprite.paint = Paint()..color = Color(0xFFFFFFFF).withAlpha(alpha);
      sprite.render(canvas, width: width, height: height);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    _tween.update(t);
  }

  double get height => FRAC * 18.0 * _tween.scale;

  double get width => FRAC * 16.0 * _tween.scale;

  double get x => size.width * _tween.x - width / 2;

  double get y => sizeBottom(size) - height;

  bool get isMoving => _tween.isMoving;

  void next() {
    _tween = new PlaceTween(_tween.end, _tween.end.next);
  }

  void prev() {
    _tween = new PlaceTween(_tween.end, _tween.end.prev);
  }

  @override
  bool destroy() => _tween.isOut;

  static animation.Animation makeAnimation(String skin) {
    return animation.Animation.sequenced('skins/$skin', 8, textureWidth: 16.0, textureHeight: 18.0);
  }
}
