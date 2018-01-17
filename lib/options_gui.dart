import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'gui_commons.dart';
import 'options.dart';

class OptionsWidget extends StatefulWidget {
  @override
  State<OptionsWidget> createState() => new _OptionsState();
}

class _OptionsState extends State<OptionsWidget> {
  Options options;

  _OptionsState() {
    start();
  }

  start() async {
    options = await Options.fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (options == null) {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pad(new Text('OpTiOnS', style: title), 20.0),
              btn('Save', () {
                options.save().then((a) {
                  Navigator.of(context).pop();
                });
              }),
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
                  new Text(options.bulletSpeed.toString(), style: text),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
