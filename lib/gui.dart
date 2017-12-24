import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'game.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

const title = const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0);
const text = const TextStyle(fontWeight: FontWeight.bold);

var pad = (Widget w, double p) =>
    new Container(child: w, padding: new EdgeInsets.all(p));
var btn = (String txt, VoidCallback handle) => new FlatButton(
    onPressed: handle, child: pad(new Text(txt, style: text), 10.0));

class MyGameBinder extends MyGame {
  _HomeScreenState state;

  MyGameBinder(this.state);

  @override
  void setRunning(bool running) {
    super.setRunning(running);
    print('hereeee ' + running.toString());
    if (this.state != null) {
      this.state.redraw();
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  MyGame game;

  _HomeScreenState();

  redraw() {
    this.setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    if (game != null) {
      if (game.isRunning()) {
        return this.game.widget;
      } else {
        setState(() => this.game = null);
      }
    }

    return new Center(
        child: new Column(children: [
      pad(new Text('Block Guns Using Gems', style: title), 20.0),
      btn('Start', () {
        MyGame game = new MyGameBinder(this);
        Flame.util.addGestureRecognizer(new TapGestureRecognizer()
          ..onTapUp = (TapUpDetails details) {
            game.input(details.globalPosition.dx, details.globalPosition.dy);
          });
        game.start();
        setState(() => this.game = game);
      }),
      btn('Score', () => print('clicked score')),
      btn('Exit', () => print('clicked exit'))
    ], mainAxisAlignment: MainAxisAlignment.center));
  }
}
