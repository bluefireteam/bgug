import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/flame.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data.dart';
import 'gui_commons.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  String username = '-';

  _HomeScreenState() {
    var ps = <Future>[
      Flame.audio.loadAll([
        'death.wav',
        'gem_collect.wav',
        'jump.wav',
        'laser_load.wav',
        'laser_shoot.wav',
        'music.wav'
      ]).then((audios) =>
          print('Done loading ' + audios.length.toString() + ' audios.')),
      Flame.images.loadAll([
        'base.png',
        'bg.png',
        'block.png',
        'bullet.png',
        'button.png',
        'coin.png',
        'gem.png',
        'obstacle.png',
        'player_1.png',
        'player_2.png',
        'shooter.png'
      ]).then((images) =>
          print('Done loading ' + images.length.toString() + ' images.')),
      Data.loadAll(),
    ];
    Future.wait(ps).then((rs) => this.setState(() => loading = false));
    _handleSignIn();
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
    print("signed in " + user.displayName);
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

  Widget userCard() {
    return new Text(username);
  }

  Widget coin() {
    final stack = new Stack(
      alignment: Alignment.bottomCenter,
      children: [
        new Image.asset('assets/images/coin_button.png'),
        new Positioned(child: new Text(Data.buy.coins.toString()), bottom: 2.0),
      ],
    );
    return new GestureDetector(
      child: stack,
      onTap: () => Navigator.of(context).pushNamed('/buy'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return new Center(child: new Text('Loading...'));
    }

    final child = new Center(
      child: new Row(
        children: [
          new Column(
            children: [
              pad(new Text('BLOCK', style: title), 2.0),
              pad(new Text('guns', style: title), 2.0),
              pad(new Text('USING', style: title), 2.0),
              pad(new Text('gems', style: title), 2.0),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new Column(
            children: [
              btn('Play', () => Navigator.of(context).pushNamed('/start')),
              btn('Score', () => Navigator.of(context).pushNamed('/score')),
              btn('Options',
                  () => Navigator.of(context).pushNamed('/options')),
              btn('Exit', () => SystemNavigator.pop()),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );

    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: new Stack(
        children: [
          child,
          new Positioned(child: coin(), top: 12.0, right: 12.0),
          new Positioned(child: userCard(), bottom: 12.0, left: 12.0),
        ],
      ),
    );
  }
}
