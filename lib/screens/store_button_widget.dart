import 'package:flutter/widgets.dart';

import 'gui_commons.dart';

class StoreButtonWidget extends StatelessWidget {
  static const S = 1.5;

  final VoidCallback onBack;

  StoreButtonWidget({ this.onBack });

  @override
  Widget build(BuildContext context) {
    return pad(
        GestureDetector(
          child: Image.asset('assets/images/store/store_button.png', width: S * 72, height: S * 28, fit: BoxFit.contain, filterQuality: FilterQuality.none),
          onTap: () => Navigator.of(context).pushNamed('/store')
          .then((_) => onBack?.call()),
        ),
        4.0);
  }
}

class ProBadge extends StatelessWidget {
  static const S = 1.5;
  @override
  Widget build(BuildContext context) {
    return pad(
        Image.asset('assets/images/store/x2coins-certificate.png', width: S * 68, height: S * 21, fit: BoxFit.contain, filterQuality: FilterQuality.none), 4.0);
  }
}
