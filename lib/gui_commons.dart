import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const title = const TextStyle(fontSize: 64.0, fontFamily: 'Blox2');
const text = const TextStyle(fontSize: 32.0, fontFamily: 'Squared Display');

var pad = (Widget w, double p) =>
    new Container(child: w, padding: new EdgeInsets.all(p));
var btn = (String txt, VoidCallback handle) => new FlatButton(
    onPressed: handle, child: pad(new Text(txt, style: text), 10.0));
