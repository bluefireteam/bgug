import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import 'gui_commons.dart';

class ScoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                children: Data.stats.scores.map((s) => Text(s.toText())).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
