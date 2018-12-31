import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/flame.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../ads.dart';
import '../data.dart';
import 'gui_commons.dart';
import 'coin_widget.dart';
import 'store_button_widget.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showingTutorial = false;
  bool loading = true;
  String username = '-';

  _HomeScreenState() {
    var ps = <Future>[
      Ad.startup(),
      SystemChrome.setEnabledSystemUIOverlays([]),
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]),
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
      _handleSignIn();
    } else {
      username = 'test user';
    }
  }

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('signed in ${user.displayName}');
    setState(() => username = user.displayName);
    return user;
  }

  addToScore(String newScore) async {
    Data.score.scores.add(newScore);
    Data.score.save();
  }

  redraw() {
    this.setState(() => {});
  }

  // TODO proper user badge
  Widget userCard() {
    return new Text(username);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF404040),
        ),
        child: Image.asset(
          "assets/images/splash_screen.png",
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
                child: Image.asset('assets/images/tutorial.png', fit: BoxFit.cover),
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
              pad(GestureDetector(child: Text('gems', style: title), onTap: () { Data.buy.coins += 50; Data.buy.save(); }), 2.0), // TODO remove this hack
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
          Positioned(child: Column(children: [ pad(StoreButtonWidget(), 4.0), pad(CoinWidget(), 4.0) ]), top: 12.0, right: 12.0),
          Positioned(child: userCard(), bottom: 12.0, left: 12.0),
        ],
      ),
    );
  }
}
