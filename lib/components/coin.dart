import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import '../audio.dart';
import '../constants.dart';
import '../mixins/has_game_ref.dart';

class _BaseCoin extends AnimationComponent {
  _BaseCoin(double x, double y) : super.sequenced(1.0, 1.0, 'coin.png', 10, textureWidth: 16.0, textureHeight: 16.0) {
    this.x = x;
    this.y = y;
  }

  @override
  void resize(Size size) {
    width = height = 0.8 * sizeTenth(size);
  }
}

class _ExcitedCoin extends _BaseCoin {
  _ExcitedCoin(double x, double y) : super(x, y) {
    animation.stepTime = .005;
    final List<Frame> newFrames = [];
    for (int i = 0; i < 5; i++) {
      newFrames.addAll(animation.frames);
    }
    animation.frames = newFrames;
    animation.loop = false;
  }

  @override
  bool destroy() => animation.done();
}

class Coin extends _BaseCoin with HasGameRef {
  bool collected = false;

  Coin(double x, double y) : super(x, y);

  @override
  void update(double t) {
    super.update(t);

    if (gameRef != null && toRect().overlaps(gameRef.player.toRect())) {
      collected = true;
      gameRef.currentCoins++;
      Audio.playSfx('gem_collect.wav');
      gameRef.addLater(_ExcitedCoin(x, y));
    }
  }

  @override
  bool destroy() => collected;
}

class CoinTrace extends Component {
  static final Sprite _coin = Sprite('coin.png', width: 16.0, height: 16.0);
  static final Position _size = Position(32.0, 32.0);

  static final math.Random rand = math.Random();

  static const MAX_TIME = 0.8;
  static const STDEV = 40.0;

  double clock = 0.0;
  Position start, end;
  final Position _current;
  List<Position> coins = [];
  bool hud;

  Function doAfter;

  static void _nothing() {}

  CoinTrace(this.hud, this.start, this.end, {this.doAfter = _nothing}) : _current = start.clone();

  Future get after => Future.delayed(Duration(milliseconds: (1000 * (MAX_TIME - clock)).round()));

  @override
  void render(Canvas c) {
    coins.forEach((p) {
      _coin.renderCentered(c, p.clone().add(_current), size: _size);
    });
  }

  @override
  void update(double t) {
    clock += t;
    if (clock >= MAX_TIME) {
      clock = MAX_TIME;
      doAfter();
    }
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    _current.x = start.x + dx * clock / MAX_TIME;
    _current.y = start.y + dy * clock / MAX_TIME;

    if (clock <= MAX_TIME / 4) {
      if (rand.nextDouble() < 0.25) {
        coins.add(Position(STDEV * rand.nextDouble() - STDEV / 2, STDEV * rand.nextDouble() - STDEV / 2));
      }
    }
  }

  @override
  bool destroy() => clock == MAX_TIME;

  @override
  bool isHud() => hud;

  @override
  int priority() => 24;
}
