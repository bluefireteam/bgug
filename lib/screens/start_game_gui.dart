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

class MyGameBinder extends BgugGame {
  _StartGameScreenState screen;

  MyGameBinder(this.screen, GameMode mode, bool showTutorial) : super(mode, showTutorial);

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

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: Row(
          children: [
            Column(
              children: [
                pad(Text('pLaY', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Column(
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
    bool showTutorial = await Data.options.getAndToggleShowTutorial();
    Main.game = new MyGameBinder(this, mode, showTutorial);
    setState(() {});
  }
}
