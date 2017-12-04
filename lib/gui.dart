import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  final MyGame game;

  HomeScreen(this.game);

  @override
  State<StatefulWidget> createState() => new _HomeScreenState(this.game);
}

const title = const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0);
const text = const TextStyle(fontWeight: FontWeight.bold);

var pad = (Widget w, double p) => new Container(child: w, padding: new EdgeInsets.all(p));
var btn = (String txt, VoidCallback handle) => new FlatButton(onPressed: handle, child: pad(new Text(txt, style: text), 10.0));

class _HomeScreenState extends State<HomeScreen> {
  final MyGame game;

  _HomeScreenState(this.game);

  @override
  Widget build(BuildContext context) {
    if (game.running) {
      return this.game;
    }
    return new Center(child: new Column(children: [
      pad(new Text('Block Guns Using Gems', style: title), 20.0),
      btn('Start', () => game.start()),
      btn('Score', () => print('clicked score')),
      btn('Exit', () => print('clicked exit'))
    ], mainAxisAlignment: MainAxisAlignment.center));
  }
}