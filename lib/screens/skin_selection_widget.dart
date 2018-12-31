import 'dart:math' as math;

import 'package:flame/animation.dart' as animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

import '../components/lock.dart';
import '../components/floor.dart';
import '../constants.dart';
import '../data.dart';
import '../skin_list.dart';

math.Random rand = math.Random();

class _CoinTrace extends Component {
  static final Sprite _coin = new Sprite('coin.png', width: 16.0, height: 16.0);
  static final Position _size = new Position(32.0, 32.0);

  static const MAX_TIME = 1.0;
  static const STDEV  = 40.0;

  double clock = 0.0;
  Position start, end, _current;
  List<Position> coins = [];

  _CoinTrace(this.start, this.end) : _current = start.clone();

  Future get after => Future.delayed(Duration(milliseconds: (1000 * (MAX_TIME - clock)).round()));

  @override
  void render(Canvas c) {
    coins.forEach((p) {
      _coin.renderCentered(c, p.clone().add(_current), _size);
    });
  }

  @override
  void update(double t) {
    clock += t;
    if (clock > MAX_TIME) {
      clock = MAX_TIME;
    }
    double dx = end.x - start.x;
    double dy = end.y - start.y;
    _current.x = start.x + dx * clock / MAX_TIME;
    _current.y = start.y + dy * clock / MAX_TIME;

    if (clock <= MAX_TIME / 4) {
      if (rand.nextDouble() < 0.25) {
        coins.add(new Position(STDEV * rand.nextDouble() - STDEV/2, STDEV * rand.nextDouble() - STDEV / 2));
      }
    }
  }

  @override
  bool destroy() => clock == MAX_TIME;
}

class _SkinCardComponent extends Component with Resizable {
  static Sprite btnOn = new Sprite('store/store-ui.png', y: 37, width: 100, height: 36);
  static Sprite btnOff = new Sprite('store/store-ui.png', width: 100, height: 36);

  _SkinSelectionGame gameRef;
  Skin skin;

  _SkinCardComponent(this.gameRef);

  bool get _btnOn => gameRef.currentOwn ? Data.buy.selectedSkin != skin.file : (skin.cost != 0 && Data.buy.coins >= skin.cost);

  String get _btnText => !gameRef.currentOwn ? (skin.cost > 0 ? 'Buy for ${skin.cost}' : 'Exclusive') : (_btnOn ? 'Equip' : 'In Use');

  @override
  void render(Canvas c) {
    if (gameRef.skin.isMoving || skin == null) {
      return;
    }

    TextPainter p = Flame.util.text(skin.name, fontFamily: '5x5', fontSize: 24.0);
    p.paint(c, Offset((size.width - p.width) / 2, 32.0));

    (_btnOn ? btnOn : btnOff).renderPosition(c, Position((size.width - 200) / 2, 64.0), Position(200.0, 72.0));
    TextPainter btn = Flame.util.text(_btnText, fontFamily: '5x5', fontSize: 18.0);
    btn.paint(c, Offset((size.width - btn.width) / 2, 64.0 + (72.0 - btn.height) / 2));
  }

  @override
  void update(double t) {}
}

class _ArrowButton extends SpriteComponent {
  _SkinSelectionGame gameRef;
  bool left;

  _ArrowButton(this.gameRef, this.left) : super.fromSprite(1.0, 1.0, new Sprite('store/store-ui.png', x: left ? 0 : 15, y: 72, width: 15, height: 64));

  bool get _show => left ? gameRef.selected > 0 : gameRef.selected < gameRef.skins.length - 1;

  @override
  void render(Canvas canvas) {
    if (!_show || gameRef.hideGui) {
      return;
    }
    super.render(canvas);
  }

  @override
  void resize(Size size) {
    double frac = 2;

    width = frac * 15.0;
    height = frac * 64.0;

    x = left ? 16.0 : size.width - 16.0 - width;
    y = (size.height - height) / 2;
  }
}

class _SkinComponent extends AnimationComponent with Resizable {
  static const SPEED = 425.0;

  bool locked;
  bool left;
  bool leave = false;

  _SkinComponent(this.locked, this.left, String skin) : super(1.0, 1.0, makeAnimation(skin)) {
    x = null;
  }

  double get xGoal => (size.width - width) / 2;

  @override
  void render(Canvas canvas) {
    if (loaded()) {
      prepareCanvas(canvas);
      Sprite sprite = this.animation.getSprite();
      int alpha = locked ? 50 : 255;
      sprite.paint = Paint()..color = Color(0xFFFFFFFF).withAlpha(alpha);
      sprite.render(canvas, width, height);
    }
  }

  @override
  void update(double t) {
    super.update(t);

    if (leave) {
      if (left) {
        x -= SPEED * t;
      } else {
        x += SPEED * t;
      }
    } else if (isMoving) {
      if (left) {
        x += SPEED * t;
        if (x > xGoal) {
          x = xGoal;
        }
      } else {
        x -= SPEED * t;
        if (x < xGoal) {
          x = xGoal;
        }
      }
    }
  }

  bool get isMoving => leave || x != xGoal;

  void doLeave(bool left) {
    this.left = left;
    this.leave = true;
  }

  @override
  bool destroy() => x < -width || x > size.width;

  @override
  void resize(Size size) {
    super.resize(size);

    double frac = 6;

    width = frac * 16.0;
    height = frac * 18.0;

    if (x == null) {
      x = left ? -width : size.width;
    }
    y = sizeBottom(size) - height;
  }

  static animation.Animation makeAnimation(String skin) {
    return animation.Animation.sequenced('skins/$skin', 8, textureWidth: 16.0);
  }
}

class _SkinSelectionGame extends BaseGame {
  bool loading = false;
  bool buying = false;
  int selected = 0;

  _SkinComponent skin;
  _SkinCardComponent card;
  Lock lock;

  List<Skin> get skins => Data.skinList.skins;
  bool get currentOwn => Data.buy.skinsOwned.contains(skins[selected].file);
  bool get lockVisible => skin != null && !skin.isMoving && !currentOwn;
  bool get hideGui => loading || skin.isMoving || buying;

  _SkinSelectionGame() {
    add(Floor());
    add(_ArrowButton(this, true));
    add(_ArrowButton(this, false));
    add(card = _SkinCardComponent(this));
    add(this.lock = Lock(() => lockVisible));
    _updateSkin(false);
  }


  void _updateSkin(bool left) {
    this.skin?.doLeave(left);
    add(this.skin = _SkinComponent(!currentOwn, !left, skins[selected].file));
    if (!currentOwn) {
      lock.reset();
    }
    card.skin = skins[selected];
  }

  @override
  void render(Canvas canvas) {
    if (loading) {
      return;
    }
    super.render(canvas);
  }

  void tap(TapDownDetails evt) {
    double x = evt.globalPosition.dx;
    if (hideGui) {
      return;
    }
    if (x < size.width / 3) {
      if (selected > 0) {
        selected--;
        _updateSkin(true);
      }
    } else if (x > 2 * size.width / 3) {
      if (selected < skins.length - 1) {
        selected++;
        _updateSkin(false);
      }
    } else {
      if (currentOwn) {
        Data.buy.selectedSkin = skins[selected].file;
        loading = true;
        Data.buy.save().then((_) => loading = false);
      } else if (skins[selected].cost > 0 && Data.buy.coins >= skins[selected].cost) {
        buying = true;
        Position start = Position(camera.x + 20 + 32.0 / 2, camera.y + 20 + 32.0 / 2);
        Position end = Position((size.width - 200) / 2 + 200 / 2, 64.0 + 72 / 2);
        _CoinTrace trace = _CoinTrace(start, end);
        addLater(trace);
        this.lock.closed = false;
        trace.after.then((_) {
          Data.buy.coins -= skins[selected].cost;
          Data.buy.skinsOwned.add(skins[selected].file);
          Data.buy.selectedSkin = skins[selected].file;
          this.skin.locked = false;
          buying = false;
          loading = true;
          Data.buy.save().then((_) => loading = false);
        });
      }
    }
  }

  void renderComponent(Canvas canvas, Component c) {
    canvas.translate(-camera.x, -camera.y);
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }
}

class SkinSelectionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SkinSelectionWidgetState();
}

class _SkinSelectionWidgetState extends State<SkinSelectionWidget> {
  final _SkinSelectionGame game;

  _SkinSelectionWidgetState() : this.game = new _SkinSelectionGame();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void didUpdateWidget(SkinSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    RenderBox box = context.findRenderObject();
    Offset pos = box.localToGlobal(Offset.zero);
    game.camera.x = -pos.dx;
    game.camera.y = -pos.dy;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: this.game.widget,
      onTapDown: (evt) => this.game.tap(evt),
    );
  }
}
