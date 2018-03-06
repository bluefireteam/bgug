import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import '../game.dart';
import '../game_mode.dart';
import '../main.dart';
import 'gui_commons.dart';

class StartGameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartGameScreenState();
}

class MyGameBinder extends MyGame {
  _StartGameScreenState screen;

  MyGameBinder(this.screen, GameMode mode) : super(mode);

  @override
  set state(GameState state) {
    super.state = state;
    if (this.screen != null) {
      (() async {
        if (state == GameState.STOPPED) {
          Data.buy.save();
          await this.screen.addToScore(score());
        }
        this.screen.redraw();
      })();
    }
  }
}

class _StartGameScreenState extends State<StartGameScreen> {
  addToScore(String newScore) async {
    Data.score.scores.add(newScore);
    Data.score.save();
  }

  redraw() {
    this.setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    if (Main.game != null) {
      if (Main.game.state != GameState.STOPPED) {
        return Main.game.widget;
      } else {
        Main.game = null;
        setState(() {});
      }
    }

    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: new Center(
        child: new Row(
          children: [
            new Column(
              children: [
                pad(new Text('pLaY', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            new Column(
              children: [
                btn('Single', () => startGame(GameMode.SINGLE)),
                btn('Endless', () => startGame(GameMode.ENDLESS)),
                btn('Playground', () => startGame(GameMode.PLAYGROUND)),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
    );
  }

  startGame(GameMode mode) async {
    Main.game = new MyGameBinder(this, mode);
    setState(() {});
  }
}
