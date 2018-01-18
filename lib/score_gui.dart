import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'score.dart';
import 'gui_commons.dart';

class ScoreScreen extends StatefulWidget {
  @override
  State<ScoreScreen> createState() => new _ScoreState();
}

class _ScoreState extends State<ScoreScreen> {
  Score score;

  _ScoreState() {
    start();
  }

  start() async {
    score = await Score.fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (score == null) {
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
                pad(new Text('sCoRe', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: score.scores.map((s) => new Text(s)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
