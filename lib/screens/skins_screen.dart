import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'gui_commons.dart';
import 'coin_widget.dart';
import 'skin_selection_widget.dart';

class SkinScreen extends StatefulWidget {
  @override
  State<SkinScreen> createState() => _SkinScreenState();
}

class _SkinScreenState extends State<SkinScreen> {
  void back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return rootContainer(
      Column(
        children: [
          Stack(children: [
            Center(child: pad(const Text('sKiNs', style: title), 20.0)),
            Positioned(child: CoinWidget(), top: 20.0, left: 20.0),
            Positioned(child: btn('go back', () => back()), top: 20.0, right: 20.0),
          ]),
          Expanded(
            child: SkinSelectionWidget(),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
