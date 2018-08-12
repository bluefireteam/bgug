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
    final img = Image.asset(player.type.icon);
    final txt = Text(locked ? 'Buy for ${player.type.cost} coins' : player.type.name, style: text);
    final container = Container(
      child: FittedBox(child: Column(children: [ img, txt ])),
      constraints: BoxConstraints.tight(Size(64.0, 72.0)),
      decoration: BoxDecoration(
        color: locked ? Color(0xA0202020) : null,
        border: Border.all(
          color: selected ? Colors.orange : Colors.black,
          width: 2.0,
        ),
      ),
      padding: EdgeInsets.all(8.0),
    );
    return Expanded(child: GestureDetector(
      child: container,
      onTap: onTap,
    ));
  }
}

class BuyScreen extends StatefulWidget {
  @override
  State<BuyScreen> createState() => _BuyState();
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pad(Text('CoInS', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(children: [
                    pad(Image.asset('assets/images/btns/coin.png'), 16.0),
                    pad(Text('${Data.buy.coins} available', style: text), 16.0),
                  ]),
                  Row(children: Data.buy.players().map((p) => PlayerButton(p, tap(p))).toList()),
                  Text('Buy more coins!', style: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
