import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../buy.dart';
import 'gui_commons.dart';

class BuyScreen extends StatefulWidget {
  @override
  State<BuyScreen> createState() => new _BuyState();
}

class _BuyState extends State<BuyScreen> {
  Buy buy;

  _BuyState() {
    start();
  }

  start() async {
    buy = await Buy.fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (buy == null) {
      return new Center(child: new Text('Loading...'));
    }
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
              child: new Text('here'),
            ),
          ),
        ],
      ),
    );
  }
}
