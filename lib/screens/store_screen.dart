import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../buy.dart';
import '../data.dart';
import 'gui_commons.dart';
import 'coin_widget.dart';
import 'skin_widget.dart';

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
      child: FittedBox(child: Column(children: [img, txt])),
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
    return Expanded(
        child: GestureDetector(
      child: container,
      onTap: onTap,
    ));
  }
}

class StoreScreen extends StatefulWidget {
  @override
  State<StoreScreen> createState() => _StoreState();
}

class _StoreState extends State<StoreScreen> {
  // TODO rethink this
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

  void back() {
    Navigator.of(context).pop();
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
      child: Column(
        children: [
          Stack(children: [
            Center(child: pad(Text('StOrE', style: TextStyle(fontSize: 64.0, fontFamily: 'Blox2')), 20.0)),
            Positioned(child: CoinWidget(Data.buy.coins, doClick: false), top: 20.0, left: 20.0),
            Positioned(child: btn('go back', () => this.back()), top: 20.0, right: 20.0),
          ]),
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: pad(
                    Stack(
                      children: [
                        Image.asset('assets/images/store/times_2_panel.png', fit: BoxFit.contain, filterQuality: FilterQuality.none),
                        Align(
                            alignment: Alignment.center,
                            child: SizedBox(child: SkinWidget('gold.png'), width: 64.0, height: 64.0),
                        ),
                      ],
                      fit: StackFit.expand,
                    ),
                    32.0),
              ),
              Expanded(child: pad(Image.asset('assets/images/store/skins_panel.png', fit: BoxFit.contain, filterQuality: FilterQuality.none), 32.0)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          )),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
