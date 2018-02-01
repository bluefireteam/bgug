import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const title = const TextStyle(fontSize: 64.0, fontFamily: 'Blox2');
const text = const TextStyle(fontSize: 32.0, fontFamily: 'Squared Display');
const small_text = const TextStyle(fontSize: 16.0, fontFamily: 'Squared Display');

final rootContainer = (Widget child) => new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );

final pad = (Widget w, double p) =>
    new Container(child: w, padding: new EdgeInsets.all(p));
final btn = (String txt, VoidCallback handle) => new FlatButton(
    onPressed: handle, child: pad(new Text(txt, style: text), 10.0));

final TextFormField Function(
        String, FormFieldValidator<String>, String, Function(String))
    textField = (String label, FormFieldValidator<String> validator,
        String initialValue, Function(String) setter) {
  TextEditingController controller = new TextEditingController();
  controller.addListener(() {
    if (validator(controller.text) == null) {
      setter(controller.text);
    }
  });
  return new TextFormField(
    decoration: new InputDecoration(labelText: label),
    controller: controller,
    validator: validator,
    initialValue: initialValue,
  );
};

final doubleValidator =
    (v) => double.parse(v, (v) => null) == null ? 'Must be a double!' : null;

final intValidator = (v) =>
    int.parse(v, onError: (v) => null) == null ? 'Must be an integer!' : null;
