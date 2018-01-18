import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../options.dart';
import '../score.dart';
import '../game.dart';
import 'gui_commons.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class MyGameBinder extends MyGame {
  _HomeScreenState state;

  MyGameBinder(this.state, Options options) : super(options);

  @override
  void setRunning(bool running) {
    super.setRunning(running);
    if (this.state != null) {
      (() async {
        if (!running) {
          await this.state.addToScore('Score: ' + points.toString());
        }
        this.state.redraw();
      })();
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  MyGame game;

  bool loading = true;
  int lastTimestamp;
  Position lastPost;

  _HomeScreenState() {
    var ps = [
      Flame.audio.loadAll([
        'death.wav',
        'gem_collect.wav',
        'jump.wav',
        'laser_load.wav',
        'laser_shoot.wav',
        'music.wav'
      ]).then((audios) =>
          print('Done loading ' + audios.length.toString() + ' audios.')),
      Flame.images.loadAll([
        'base.png',
        'bg.png',
        'block.png',
        'bullet.png',
        'gem.png',
        'obstacle.png',
        'player.png',
        'shooter.png'
      ]).then((images) =>
          print('Done loading ' + images.length.toString() + ' images.')),
    ];
    Future.wait(ps).then((rs) => this.setState(() => loading = false));

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
    if (loading) {
      return new Center(child: new Text('Loading...'));
    }

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
                pad(new Text('BLOCK', style: title), 2.0),
                pad(new Text('guns', style: title), 2.0),
                pad(new Text('USING', style: title), 2.0),
                pad(new Text('gems', style: title), 2.0),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            new Column(
              children: [
                btn('Start', () async {
                  MyGame game = new MyGameBinder(this, await Options.fetch());
                  game.start();
                  setState(() => this.game = game);
                }),
                btn('Score', () => Navigator.of(context).pushNamed('/score')),
                btn('Options',
                    () => Navigator.of(context).pushNamed('/options')),
                btn('Exit', () => SystemNavigator.pop()),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
    );
  }
}
