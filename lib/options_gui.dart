import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'gui_commons.dart';

class OptionsWidget extends StatefulWidget {
  @override
  State<OptionsWidget> createState() => new _OptionsState();
}

class _OptionsState extends State<OptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pad(new Text('OpTiOnS', style: title), 20.0),
                btn('Save', () {}),
                btn('Cancel', () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Row(
                  children: [
                    new Text('Bullet Speed', style: text),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
