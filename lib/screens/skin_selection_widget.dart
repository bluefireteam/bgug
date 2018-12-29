import 'package:flame/animation.dart' as animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import '../skin_list.dart';
import '../components/floor.dart';
import '../constants.dart';

class _SkinCardComponent extends Component with Resizable {
  static Sprite btnOn = new Sprite('store/store-ui.png', y: 37, width: 100, height: 36);
  static Sprite btnOff = new Sprite('store/store-ui.png', width: 100, height: 36);

  _SkinSelectionGame gameRef;
  Skin skin;

  _SkinCardComponent(this.gameRef);

  // TODO buy options??
  bool get _on => Data.buy.selectedSkin != skin.file;
  String get _text => _on ? 'Equip' : 'In Use';

  @override
  void render(Canvas c) {
    if (gameRef.skin.isMoving || skin == null) {
      return;
    }

    TextPainter p = Flame.util.text(skin.name, fontFamily: 'Squared Display', fontSize: 32.0);
    p.paint(c, Offset((size.width - p.width) / 2, 32.0));

    (_on ? btnOn : btnOff).renderPosition(c, Position((size.width - 200) / 2, 64.0), Position(200.0, 72.0));
    TextPainter btn = Flame.util.text(_text, fontFamily: 'Squared Display', fontSize: 32.0);
    btn.paint(c, Offset((size.width - btn.width) / 2, 64.0 + (72.0 - btn.height) / 2));
  }

  @override
  void update(double t) {}
}

class _ArrowButton extends SpriteComponent {
  _SkinSelectionGame gameRef;
  bool left;

  _ArrowButton(this.gameRef, this.left) : super.fromSprite(1.0, 1.0, new Sprite('store/store-ui.png', x: left ? 0 : 15, y: 72, width: 15, height: 64));

  @override
  void render(Canvas canvas) {
    if (gameRef.skin.isMoving) {
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
  static const SPEED = 300.0;

  bool leave = false;

  _SkinComponent(String skin) : super(1.0, 1.0, makeAnimation(skin));

  double get xGoal => (size.width - width) / 2;

  @override
  void update(double t) {
    super.update(t);

    if (x < xGoal) {
      x += SPEED * t;
      if (x > xGoal) {
        x = xGoal;
      }
    } else if (leave) {
      x += SPEED * t;
    }
  }

  bool get isMoving => leave || x < xGoal;

  void doLeave() {
    leave = true;
  }

  @override
  bool destroy() => x > size.width;

  @override
  void resize(Size size) {
    super.resize(size);

    double frac = 6;

    width = frac * 16.0;
    height = frac * 18.0;

    if (x == 0.0) {
      x = -width;
    }
    y = size_bottom(size) - height;
  }

  static animation.Animation makeAnimation(String skin) {
    return animation.Animation.sequenced('skins/$skin', 8, textureWidth: 16.0);
  }
}

class _SkinSelectionGame extends BaseGame {
  bool loading = false;
  int selected = 0;
  List<Skin> get skins => Data.skinList.skins;

  _SkinComponent skin;
  _SkinCardComponent card;

  _SkinSelectionGame() {
    add(Floor());
    add(_ArrowButton(this, true));
    add(_ArrowButton(this, false));
    add(card = _SkinCardComponent(this));
    _updateSkin();
  }

  void _updateSkin() {
    this.skin?.doLeave();
    add(this.skin = _SkinComponent(skins[selected].file));
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
    if (loading || this.skin.isMoving) {
      return;
    }
    if (x < size.width / 3) {
      if (selected > 0) {
        selected--;
        _updateSkin();
      }
    } else if (x > 2 * size.width / 3) {
      if (selected < skins.length - 1) {
        selected++;
        _updateSkin();
      }
    } else {
      Data.buy.selectedSkin = skins[selected].file;
      loading = true;
      Data.buy.save().then((_) => loading = false);
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
