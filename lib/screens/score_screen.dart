import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../score.dart';
import 'gui_commons.dart';

class ScoreScreen extends StatefulWidget {
  @override
  State<ScoreScreen> createState() => new _ScoreState();
}

class _ScoreState extends State<ScoreScreen> {
  Score score;

  _ScoreState() {
    _start();
  }

  _start() async {
    Score scr = await Score.fetch();
    setState(() => score = scr);
  }

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Center(child: Text('Loading...'));
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pad(Text('sCoRe', style: title), 20.0),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: score.scores.map((s) => Text(s)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
