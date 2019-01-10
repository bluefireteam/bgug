import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const title = const TextStyle(fontSize: 64.0, fontFamily: 'Blox2');
const text = const TextStyle(fontSize: 28.0, fontFamily: '5x5');
const small_text = const TextStyle(fontSize: 12.0, fontFamily: '5x5');

const black_medium_text = const TextStyle(fontSize: 16.0, fontFamily: '5x5', color: Colors.black);
const medium_link = const TextStyle(fontSize: 16.0, fontFamily: '5x5', color: Colors.blue);

final rootContainer = (Widget child) =>
    Container(
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
final btn = (String txt, VoidCallback handle, { TextStyle style = text }) =>
    FlatButton(
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

class StatefulCheckbox extends StatefulWidget {

  final bool value;
  final void Function(bool) onChanged;

  StatefulCheckbox({ this.value, this.onChanged });

  @override
  State<StatefulWidget> createState() {
    return _StatefulCheckboxState(this.value, this.onChanged);
  }
}

class _StatefulCheckboxState extends State<StatefulCheckbox> {

  bool value;
  void Function(bool) onChanged;

  _StatefulCheckboxState(this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: value, onChanged: (v) {
      setState(() {
        value = v;
        onChanged(v);
      });
    });
  }

}

typedef String Validator(String value);

final Validator doubleValidator =
    (v) => double.tryParse(v) == null ? 'Must be a double!' : null;

final Validator intValidator = (v) =>
int.tryParse(v) == null ? 'Must be an integer!' : null;
