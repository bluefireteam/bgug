import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import 'gui_commons.dart';
import 'coin_widget.dart';
import 'skin_selection_widget.dart';

class SkinScreen extends StatefulWidget {
  @override
  State<SkinScreen> createState() => _SkinScreenState();
}

class _SkinScreenState extends State<SkinScreen> {
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
            Center(child: pad(Text('sKiNs', style: TextStyle(fontSize: 64.0, fontFamily: 'Blox2')), 20.0)),
            Positioned(child: CoinWidget(Data.buy.coins, doClick: false), top: 20.0, left: 20.0),
            Positioned(child: btn('go back', () => this.back()), top: 20.0, right: 20.0),
          ]),
          Expanded(
            child: SkinSelectionWidget(),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
