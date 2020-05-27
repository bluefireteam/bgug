import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../iap.dart';
import 'gui_commons.dart';
import 'coin_widget.dart';
import 'skin_widget.dart';

class StoreScreen extends StatefulWidget {
  @override
  State<StoreScreen> createState() => _StoreState();
}

class _StoreState extends State<StoreScreen> {
  void back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return rootContainer(
      Column(
        children: [
          Stack(children: [
            Center(child: pad(const Text('StOrE', style: title), 20.0)),
            Positioned(child: CoinWidget(), top: 20.0, left: 20.0),
            Positioned(child: btn('go back', () => back()), top: 20.0, right: 20.0),
          ]),
          Expanded(
              child: Row(
            children: [
              Expanded(child: pad(cardBuyIAP(), 32.0)),
              Expanded(child: pad(cardBuySkins(context), 32.0)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          )),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  Widget cardBuySkins(BuildContext context) {
    return GestureDetector(
      child: Image.asset('assets/images/store/skins_panel.png', fit: BoxFit.contain, filterQuality: FilterQuality.none),
      onTap: () => Navigator.of(context).pushNamed('/skins'),
    );
  }

  Widget cardBuyIAP() {
    if (IAP.pro) {
      return const Center(child: const Text('You have the full version, thanks!', style: text));
    }
    if (IAP.iap == null) {
      return Center(child: Text('You must have the ${Platform.isAndroid ? 'Google Play' : 'App Store'} Services to buy the game.', style: text));
    }
    return LayoutBuilder(builder: (ctx, constraints) {
      return Stack(
        children: [
          Image.asset('assets/images/store/times_2_panel.png', fit: BoxFit.contain, filterQuality: FilterQuality.none),
          Positioned(
            child: SizedBox(child: SkinWidget('gold.png'), width: 64.0, height: 64.0),
            top: constraints.maxHeight / 112 * 70.0 - 64.0 / 2,
            left: (constraints.maxWidth - 64.0) / 2,
          ),
          Positioned(
            child: GestureDetector(
              child: Center(child: Text(IAP.iap.localizedPrice, style: const TextStyle(fontSize: 20.0, fontFamily: '5x5'))),
              onTap: () async {
                if (IAP.pro) {
                  return;
                }
                try {
                  await IAP.purchase();
                  showToast('Congratulations, you just bought the game! Thanks ;)');
                } catch (ex) {
                  if (ex is PlatformException && ex.details == 'responseCode: 1') {
                    return; // user canceled
                  }
                  print('Error buying game: $ex');
                  showToast('Error while buying: ${ex.toString()}');
                } finally {
                  setState(() {});
                }
              },
            ),
            left: 0,
            width: constraints.maxWidth,
            bottom: 0.0,
          )
        ],
        fit: StackFit.expand,
      );
    });
  }

  void showToast(String str) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(str),
    ));
  }
}
