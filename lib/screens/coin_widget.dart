import 'package:flame/animation.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart' hide Animation;

import '../data.dart';
import 'gui_commons.dart';

class CoinWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CoinWidgetState();
  }
}

class _CoinWidgetState extends State<CoinWidget> {
  @override
  Widget build(BuildContext context) {
    final animation = Animation.sequenced('coin.png', 10, textureWidth: 16.0, textureHeight: 16.0);
    final coinCounter = Data.hasData ? Data.buy.coins.toString() : '';
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(coinCounter, style: text),
          Flame.util.animationAsWidget(Position(32.0, 32.0), animation),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 100.0, maxHeight: 32.0),
    );
  }
}
