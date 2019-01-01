import 'package:flutter/widgets.dart';

class StoreButtonWidget extends StatelessWidget {
  static const S = 1.5;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.asset('assets/images/store/store_button.png', width: S * 72, height: S * 28, fit: BoxFit.contain, filterQuality: FilterQuality.none),
      onTap: () => Navigator.of(context).pushNamed('/store'),
    );
  }
}