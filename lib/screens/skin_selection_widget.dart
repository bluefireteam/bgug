import 'dart:math' as math;

import 'package:flame/anchor.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/widgets.dart';

import '../components/coin.dart';
import '../components/floor.dart';
import '../components/lock.dart';
import '../constants.dart';
import '../data.dart';
import '../skin_list.dart';
import '../util.dart';

math.Random rand = math.Random();
TextConfig config = defaultText.withFontSize(24.0);

class _SkinCardComponent extends Component with Resizable {
  static Sprite btnOn = new Sprite('store/store-ui.png', y: 36, width: 100, height: 36);
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

    config.render(c, skin.name, Position(size.width / 2, 32.0), anchor: Anchor.topCenter);

    (_btnOn ? btnOn : btnOff).renderPosition(c, Position((size.width - 200) / 2, 64.0), Position(200.0, 72.0));
    config.render(c, _btnText, Position(size.width / 2, 64.0 + 72.0 / 2), anchor: Anchor.center);
  }

  @override
  void update(double t) {}
}

class _ArrowButton extends SpriteComponent {
  _SkinSelectionGame gameRef;
  bool left;

  _ArrowButton(this.gameRef, this.left) : super.fromSprite(1.0, 1.0, new Sprite('store/store-ui.png', x: left ? 0 : 16, y: 72, width: 16, height: 64));

  @override
  void render(Canvas canvas) {
    if (gameRef.hideGui) {
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
  static const SPEED = 1025.0;

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

    double frac = 5;

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
    super.render(canvas);
  }

  void tap(TapDownDetails evt) {
    double x = evt.globalPosition.dx;
    if (hideGui) {
      return;
    }
    if (x < size.width / 3) {
      selected--;
      while (selected < 0) {
        selected += skins.length;
      }
      _updateSkin(true);
    } else if (x > 2 * size.width / 3) {
      selected++;
      while (selected >= skins.length) {
        selected -= skins.length;
      }
      _updateSkin(false);
    } else {
      if (currentOwn) {
        Data.buy.selectedSkin = skins[selected].file;
        loading = true;
        Data.save().then((_) => loading = false);
      } else if (skins[selected].cost > 0 && Data.buy.coins >= skins[selected].cost) {
        buying = true;
        Position start = Position(camera.x + 20 + 32.0 / 2, camera.y + 20 + 32.0 / 2);
        Position end = Position((size.width - 200) / 2 + 200 / 2, 64.0 + 72 / 2);
        CoinTrace trace = CoinTrace(false, start, end);
        addLater(trace);
        this.lock.closed = false;
        trace.after.then((_) {
          Data.buy.coins -= skins[selected].cost;
          Data.buy.skinsOwned.add(skins[selected].file);
          Data.buy.selectedSkin = skins[selected].file;
          this.skin.locked = false;
          buying = false;
          loading = true;
          Data.checkAchievementsAndSkins();
          Data.save().then((_) => loading = false);
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
