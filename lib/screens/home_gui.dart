import 'dart:async';
import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../play_user.dart';
import '../ads.dart';
import '../constants.dart';
import '../data.dart';
import 'coin_widget.dart';
import 'gui_commons.dart';
import 'store_button_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showingTutorial = false;
  bool loading = true;
  PlayUser user;

  _HomeScreenState() {
    var ps = <Future>[
      Ad.startup(),
      Flame.util.fullScreen(),
      Flame.util.setOrientation(DeviceOrientation.landscapeLeft),
      Flame.audio.loadAll([
        'death.wav',
        'gem_collect.wav',
        'jump.wav',
        'laser_load.wav',
        'laser_shoot.wav',
        'music.wav',
      ]).then((audios) => print('Done loading ' + audios.length.toString() + ' audios.')),
      Flame.images.loadAll([
        'skins/asimov.png',
        'hud_bg.png',
        'base_bottom.png',
        'base_top.png',
        'block.png',
        'obstacle.png',
        'shooter.png',
        'bullet.png',
        'gem.png',
        'coin.png',
        'lock.png',
        'bg.png',
        'button.png',
        'endgame_bg.png',
        'endgame_buttons.png',
        'tutorial.png',
        'splash_screen.png',
        'google-play-button.png',
        'store/skins_panel.png',
        'store/store_button.png',
        'store/store-ui.png',
        'store/times_2_panel.png',
        'store/x2coins-certificate.png',
      ]).then((images) => print('Done loading ' + images.length.toString() + ' images.')),
      Data.loadAll(),
    ];
    Future.wait(ps).then((rs) => this.setState(() => loading = false));
    if (ENABLE_LOGIN) {
      _performSignIn();
    }
  }

  void _performSignIn() async {
    try {
      PlayUser user = await PlayUser.singIn();
      setState(() => this.user = user);
    } catch (ex) {
      print('Error: $ex');
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(ex),
      ));
    }
  }

  void addToScore(String newScore) async {
    Data.score.scores.add(newScore);
    Data.score.save();
  }

  void redraw() {
    this.setState(() => {});
  }

  Widget userCard() {
    const S = 2.0;
    if (user == null) {
      return GestureDetector(
          child: Image.asset('assets/images/google-play-button.png', filterQuality: FilterQuality.none, fit: BoxFit.cover, width: 89 * S, height: 17 * S),
          onTap: () => _performSignIn(),
      );
    }
    return Stack(
      children: [
        Image.asset('assets/images/username-panel.png', filterQuality: FilterQuality.none, fit: BoxFit.cover, width: 72 * S, height: 18 * S),
        Positioned(child: Text(user.account.displayName, style: TextStyle(fontFamily: '5x5', fontSize: 14.0)), right: 0, top: 0),
        Positioned(child: RawImage(image: user.avatar, width: S * 9, height: S * 9), left: S * 7, top: S * 2, width: S * 9, height: S * 9),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        decoration: BoxDecoration(
          color: Color(0xFF404040),
        ),
        child: Image.asset(
          "assets/images/splash_screen.png",
          filterQuality: FilterQuality.none,
          fit: BoxFit.contain,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      );
    }

    Widget main = renderContent(context);

    if (showingTutorial) {
      return GestureDetector(
        child: LayoutBuilder(builder: (_, BoxConstraints size) {
          double potWidth = 3 * size.maxWidth / 4;
          double potHeight = 4 * size.maxHeight / 5;
          double frac = math.min(potWidth / 192, potHeight / 162);
          double width = 192 * frac;
          double height = 162 * frac;
          return Stack(
            children: [
              main,
              Positioned(
                child: Image.asset('assets/images/tutorial.png', fit: BoxFit.cover, filterQuality: FilterQuality.none),
                left: (size.maxWidth - width) / 2,
                top: (size.maxHeight - height) / 2,
                width: width,
                height: height,
              ),
            ],
          );
        }),
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => showingTutorial = false),
      );
    }

    return main;
  }

  Widget renderContent(BuildContext context) {
    final child = Center(
      child: Row(
        children: [
          Column(
            children: [
              pad(Text('BREAK', style: title), 2.0),
              pad(Text('guns', style: title), 2.0),
              pad(Text('USING', style: title), 2.0),
              pad(
                  GestureDetector(
                      child: Text('gems', style: title),
                      onTap: () {
                        Data.buy.coins += 50;
                        Data.buy.save();
                      }),
                  2.0), // TODO remove this hack
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Column(
            children: [
              btn('Play', () => Navigator.of(context).pushNamed('/start')),
              btn('Score', () => Navigator.of(context).pushNamed('/score')),
              btn('How to Play', () => setState(() => showingTutorial = true)),
              btn('Exit', () => SystemNavigator.pop()),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          child,
          Positioned(child: Column(children: [pad(StoreButtonWidget(), 4.0), pad(CoinWidget(), 4.0)]), top: 12.0, right: 12.0),
          Positioned(child: userCard(), bottom: 12.0, left: 12.0),
        ],
      ),
    );
  }
}
