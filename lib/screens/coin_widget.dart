import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import '../components/coin.dart';

class _TextComponent extends Component with Resizable {
  @override
  void render(Canvas c) {
    TextPainter p = Flame.util.text(Data.buy.coins.toString(), fontFamily: '5x5');
    p.paint(c, new Offset(size.width - p.width - 4.0, (size.height - p.height) / 2));
  }

  @override
  void update(double t) {}
}

class _CoinWidgetGame extends BaseGame {
  Coin coin;

  _CoinWidgetGame() {
    add(coin = new Coin(0, 0));
    add(_TextComponent());
  }

  @override
  void resize(Size size) {
    super.resize(size);
    coin.width = coin.height = size.height;
  }
}

class CoinWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CoinWidgetState();
  }
}

class _CoinWidgetState extends State<CoinWidget> {
  final _CoinWidgetGame game = new _CoinWidgetGame();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void didUpdateWidget(CoinWidget oldWidget) {
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
    return Container(
      child: game.widget,
      constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 32.0),
    );
  }
}
