import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../options.dart';
import 'gui_commons.dart';

final optionLine = (String label, String value, VoidCallback onTap) => pad(
      new GestureDetector(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(label + ': ', style: small_text),
            new Text(value, style: small_text),
          ],
        ),
        onTap: onTap,
      ),
      12.0,
    );

class OptionsScreen extends StatefulWidget {
  @override
  State<OptionsScreen> createState() => new _OptionsState();
}

class _OptionsState extends State<OptionsScreen> {
  Options options;
  TextFormField currentTextField;

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
    if (currentTextField != null) {
      return rootContainer(new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          currentTextField,
          btn('Go back', () => setState(() => currentTextField = null)),
        ],
      ));
    }
    return rootContainer(
      new Row(
        children: [
          new Expanded(
              child: new Column(
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
          )),
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Form(
                child: new ListView(
                  children: [
                    optionLine('Bullet Speed', options.bulletSpeed.toString(),
                        () {
                      this.setState(() => currentTextField = textField(
                            'Bullet Speed',
                            doubleValidator,
                            options.bulletSpeed.toString(),
                            (newValue) =>
                                options.bulletSpeed = double.parse(newValue),
                          ));
                    }),
                    optionLine('Block Button Starting Cost',
                        options.buttonCost.toString(), () {
                      this.setState(() => currentTextField = textField(
                            'Block Button Starting Cost',
                            doubleValidator,
                            options.buttonCost.toString(),
                            (newValue) =>
                                options.buttonCost = int.parse(newValue),
                          ));
                    }),
                    optionLine('Block Button Inc Cost',
                        options.buttonIncCost.toString(), () {
                      this.setState(() => currentTextField = textField(
                            'Block Button Inc Cost',
                            doubleValidator,
                            options.buttonIncCost.toString(),
                            (newValue) =>
                                options.buttonIncCost = int.parse(newValue),
                          ));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
