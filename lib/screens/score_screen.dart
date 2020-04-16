import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import 'gui_commons.dart';

class ScoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return rootContainer(
      Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pad(const Text('sCoRe', style: title), 20.0),
                Data.user != null ? btn('Leaderboards', () {
                  Navigator.pushNamed(context, '/leaderboards');
                }) : Container(),
                btn('Go back', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                    child: pad(
                      ListView(
                        children: [const Text('Scores (last 10 games)', style: small_text)]..addAll(Data.stats.scores.map((s) => Text(s.toText()))),
                      ),
                      16.0,
                    ),
                    flex: 1),
                Expanded(
                    child: pad(
                        ListView(
                          children: [const Text('Stats', style: small_text)]..addAll(Data.stats.statsList().map((s) => Text(s))),
                        ),
                        16.0),
                    flex: 1),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ],
      ),
    );
  }
}
