import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../game.dart';
import '../game_mode.dart';
import '../options.dart';
import '../score.dart';
import 'gui_commons.dart';

class StartGameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StartGameScreenState();
}

class MyGameBinder extends MyGame {
  _StartGameScreenState state;

  MyGameBinder(this.state, GameMode mode, Options options)
      : super(mode, options);

  @override
  void setRunning(bool running) {
    super.setRunning(running);
    if (this.state != null) {
      (() async {
        if (!running) {
          await this.state.addToScore(score());
        }
        this.state.redraw();
      })();
    }
  }
}

class _StartGameScreenState extends State<StartGameScreen> {
  MyGame game;

  int lastTimestamp;
  Position lastPost;

  _StartGameScreenState() {
    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
      ..onTapDown = (TapDownDetails details) {
        lastPost =
            new Position(details.globalPosition.dx, details.globalPosition.dy);
        lastTimestamp = new DateTime.now().millisecondsSinceEpoch;
      }
      ..onTapUp = (TapUpDetails details) {
        if (lastTimestamp == null || lastPost == null) {
          return;
        }
        int dt = new DateTime.now().millisecondsSinceEpoch - lastTimestamp;
        if (dt > 3000) {
          dt = 3000;
        }
        if (this.game != null && this.game.isRunning()) {
          this.game.input(lastPost, dt);
          lastTimestamp = lastPost = null;
        }
      });
  }

  addToScore(String newScore) async {
    Score score = await Score.fetch();
    score.scores.add(newScore);
    score.save();
  }

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
    MyGame game = new MyGameBinder(this, mode, await Options.fetch());
    setState(() => this.game = game);
  }
}
