import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const title = const TextStyle(fontSize: 64.0, fontFamily: 'Blox2');
const text = const TextStyle(fontSize: 32.0, fontFamily: 'Squared Display');
const small_text = const TextStyle(fontSize: 16.0, fontFamily: 'Squared Display');

final rootContainer = (Widget child) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );

final pad = (Widget w, double p) =>
    Container(child: w, padding: EdgeInsets.all(p));
final btn = (String txt, VoidCallback handle, { TextStyle style = text }) => FlatButton(
    onPressed: handle, child: pad(Text(txt, style: style), 10.0));

final TextFormField Function(
        String, FormFieldValidator<String>, String, Function(String))
    textField = (String label, FormFieldValidator<String> validator,
        String initialValue, Function(String) setter) {
  TextEditingController controller = TextEditingController(text: initialValue);
  controller.addListener(() {
    if (validator(controller.text) == null) {
      setter(controller.text);
    }
  });
  return TextFormField(
    decoration: InputDecoration(labelText: label),
    controller: controller,
    validator: validator,
  );
};

typedef String Validator(String value);

final Validator doubleValidator =
    (v) => double.tryParse(v) == null ? 'Must be a double!' : null;

final Validator intValidator = (v) =>
    int.tryParse(v) == null ? 'Must be an integer!' : null;
