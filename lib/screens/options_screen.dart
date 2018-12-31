import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../options.dart';
import 'gui_commons.dart';

final optionLine = (String label, String value, VoidCallback onTap) => pad(
      GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label + ': ', style: small_text),
            Text(value, style: small_text),
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
    _start();
  }

  _start() async {
    Options opt = await Options.fetch();
    setState(() => options = opt);
  }

  @override
  Widget build(BuildContext context) {
    if (options == null) {
      return Center(child: Text('Loading...'));
    }
    if (currentTextField != null) {
      return rootContainer(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          currentTextField,
          btn('Go back', () => setState(() => currentTextField = null)),
        ],
      ));
    }
    final optionItemBuilder = (String title, String value, Validator validator, void Function(String) setter) => optionLine(title, value, () {
          this.setState(() => currentTextField = textField(title, validator, value, setter));
        });
    final intItemBuilder = (String title, int value, void Function(int) setter) {
      return optionItemBuilder(title, value.toString(), intValidator, (str) => setter(int.parse(str)));
    };
    final doubleItemBuilder = (String title, double value, void Function(double) setter) {
      return optionItemBuilder(title, value.toString(), doubleValidator, (str) => setter(double.parse(str)));
    };
    return rootContainer(
      Row(
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pad(Text('OpTiOnS', style: title), 20.0),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: ListView(
                  children: [
                    doubleItemBuilder(
                      'Bullet Speed',
                      options.bulletSpeed,
                      (v) => options.bulletSpeed = v,
                    ),
                    intItemBuilder(
                      'Block Button Starting Cost',
                      options.buttonCost,
                      (v) => options.buttonCost = v,
                    ),
                    intItemBuilder(
                      'Block Button Inc Cost',
                      options.buttonIncCost,
                      (v) => options.buttonIncCost = v,
                    ),
                    intItemBuilder(
                      'Max Hold Jump (millis)',
                      options.maxHoldJumpMillis,
                      (v) => options.maxHoldJumpMillis = v,
                    ),
                    doubleItemBuilder(
                      'Gravity Impulse',
                      options.gravityImpulse,
                      (v) => options.gravityImpulse = v,
                    ),
                    doubleItemBuilder(
                      'Jump Impulse',
                      options.jumpImpulse,
                      (v) => options.jumpImpulse = v,
                    ),
                    doubleItemBuilder(
                      'Dive Impulse',
                      options.diveImpulse,
                      (v) => options.diveImpulse = v,
                    ),
                    doubleItemBuilder(
                      'Jump Time Multiplier',
                      options.jumpTimeMultiplier,
                      (v) => options.jumpTimeMultiplier = v,
                    ),
                    // TODO new options
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
