import 'package:flutter/widgets.dart';

class CoinWidget extends StatelessWidget {
  final int coins;
  final bool doClick;

  CoinWidget(this.coins, {this.doClick = true});

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset('assets/images/coin_button.png'),
        Positioned(child: Text(coins.toString()), bottom: 2.0),
      ],
    );
    if (!doClick) {
      return stack;
    }
    return GestureDetector(
      child: stack,
      onTap: () => Navigator.of(context).pushNamed('/buy'),
    );
  }
}
