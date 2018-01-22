import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../score.dart';
import 'gui_commons.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;

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
                btn('Start', () => Navigator.of(context).pushNamed('/start')),
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
