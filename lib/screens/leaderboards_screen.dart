import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'gui_commons.dart';

enum _TrophyType { GOLD, SILVER, BRONZE }

class _Trophy extends StatelessWidget {
  static final Position size = Position(32.0, 32.0);
  final _TrophyType type;

  _Trophy(this.type);

  Sprite get _sprite => Sprite('trophies.png',
      height: 16.0, width: 16.0, y: 0, x: type.index * 16.0);

  @override
  Widget build(BuildContext context) {
    return EmbeddedGameWidget(
        SimpleGame(SpriteComponent.fromSprite(size.x, size.y, _sprite)),
        size: size);
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int position;
  final String name, value;

  _LeaderboardEntry(this.position, this.name, this.value);

  Widget _trophy() {
    if (position == 0) {
      return _Trophy(_TrophyType.GOLD);
    } else if (position == 1) {
      return _Trophy(_TrophyType.SILVER);
    } else if (position == 2) {
      return _Trophy(_TrophyType.BRONZE);
    }
    return Container(constraints: BoxConstraints.expand(width: _Trophy.size.x, height: _Trophy.size.y));
  }

  Widget _left() {
    Widget trophy = _trophy();
    Widget text = Text(this.name, style: small_text);
    return Row(children: [trophy, text]);
  }

  Widget _right() {
    return Text(this.value, style: small_text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _left(),
        _right(),
      ],
    );
  }
}

class LeaderboardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: pad(Text('LeAdErBoArD', style: title), 20.0)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: pad(Column(children: [
                  pad(Text('Distance', style: text), 12.0),
                  _LeaderboardEntry(0, 'entry 1', '100.0'),
                  _LeaderboardEntry(1, 'entry 2', '0.3'),
                ]), 16.0)),
                Expanded(
                    child: pad(Column(children: [
                  pad(Text('Coins', style: text), 12.0),
                  _LeaderboardEntry(0, 'entry 1', '100'),
                  _LeaderboardEntry(2, 'entry 2', '20'),
                  _LeaderboardEntry(3, 'entry 3', '10'),
                ]), 16.0)),
              ],
            ),
          ),
          btn('Go back', () {
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }
}
