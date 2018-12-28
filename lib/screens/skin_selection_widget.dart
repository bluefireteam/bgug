import 'package:flame/animation.dart' as animation;
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

import '../components/floor.dart';
import '../constants.dart';

class _ArrowButton extends SpriteComponent {
  bool left;

  _ArrowButton(this.left) : super.fromSprite(1.0, 1.0, new Sprite('store/store-ui.png', x: left ? 0 : 15, y: 72, width: 15, height: 64));

  @override
  void resize(Size size) {
    double frac = 2;

    width = frac * 15.0;
    height = frac * 64.0;

    x = left ? 16.0 : size.width - 16.0 - width;
    y = (size.height - height) / 2;
  }
}

class _SkinComponent extends AnimationComponent {
  _SkinComponent(String skin) : super(1.0, 1.0, animation.Animation.sequenced('skins/$skin', 8, textureWidth: 16.0));

  @override
  void resize(Size size) {
    double frac = 6;

    width = frac * 16.0;
    height = frac * 18.0;

    x = (size.width - width) / 2;
    y = size_bottom(size) - height;
  }
}

class _SkinSelectionGame extends BaseGame {
  _SkinSelectionGame() {
    add(Floor());
    add(_SkinComponent('clown.png'));
    add(_ArrowButton(true));
    add(_ArrowButton(false));
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
    return this.game.widget;
  }
}
