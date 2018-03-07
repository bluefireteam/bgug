import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../buy.dart';
import '../data.dart';
import 'gui_commons.dart';

class PlayerButton extends StatelessWidget {

  final Player player;
  final void Function() onTap;

  bool get locked => player.state == PlayerButtonState.LOCKED;
  bool get selected => player.state == PlayerButtonState.SELECTED;

  PlayerButton(this.player, this.onTap);

  @override
  Widget build(BuildContext context) {
    final img = new Image.asset(player.type.icon);
    final txt = new Text(locked ? 'Buy for ${player.type.cost} coins' : player.type.name, style: text);
    final container = new Container(
      child: new FittedBox(child: new Column(children: [ img, txt ])),
      constraints: new BoxConstraints.tight(new Size(64.0, 72.0)),
      decoration: new BoxDecoration(
        color: locked ? new Color(0xA0202020) : null,
        border: new Border.all(
          color: selected ? Colors.orange : Colors.black,
          width: 2.0,
        ),
      ),
      padding: new EdgeInsets.all(8.0),
    );
    return new Expanded(child: new GestureDetector(
      child: container,
      onTap: onTap,
    ));
  }
}

class BuyScreen extends StatefulWidget {
  @override
  State<BuyScreen> createState() => new _BuyState();
}

class _BuyState extends State<BuyScreen> {

  void Function() tap(Player player) {
    return () {
      if (player.state == PlayerButtonState.AVALIABLE) {
        Data.buy.selected = player.type;
      } else if (player.state == PlayerButtonState.LOCKED) {
        Data.buy.owned.add(player.type);
      }
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pad(new Text('CoInS', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: [
                  new Row(children: [
                    pad(new Image.asset('assets/images/btns/coin.png'), 16.0),
                    pad(new Text('${Data.buy.coins} available', style: text), 16.0),
                  ]),
                  new Row(children: Data.buy.players().map((p) => new PlayerButton(p, tap(p))).toList()),
                  new Text('Buy more coins!', style: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
