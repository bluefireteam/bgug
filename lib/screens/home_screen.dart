import 'dart:async';
import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:play_games/play_games.dart';

import '../ads.dart';
import '../async_saver.dart';
import '../audio.dart';
import '../constants.dart';
import '../data.dart';
import '../iap.dart';
import '../play_user.dart';
import '../tutorial_status.dart';
import 'audio_control_widget.dart';
import 'coin_widget.dart';
import 'gui_commons.dart';
import 'store_button_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _TutorialOverlay extends StatelessWidget {
  final Widget main;
  final String image;
  final void Function() onClick;

  _TutorialOverlay(this.main, this.image, this.onClick);

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset('assets/images/$image.png',
                  fit: BoxFit.cover, filterQuality: FilterQuality.none),
              left: (size.maxWidth - width) / 2,
              top: (size.maxHeight - height) / 2,
              width: width,
              height: height,
            ),
          ],
        );
      }),
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  bool showingAchievements = false;
  TutorialStatus tutorialStatus = TutorialStatus.NOT_SHOWING;
  bool loading = true;
  PlayUser user;
  String userCallback;

  _HomeScreenState() {
    var ps = [
      Ad.startup(),
      Flame.util.fullScreen(),
      Flame.util.setOrientation(DeviceOrientation.landscapeLeft),
      Flame.audio.loadAll([
        'death.wav',
        'gem_collect.wav',
        'jump.wav',
        'block.wav',
        'laser_load.wav',
        'laser_shoot.wav',
        'music.mp3',
      ]).then((audios) =>
          print('Done loading ' + audios.length.toString() + ' audios.')),
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
        'tutorial-2.png',
        'tutorial-gamepad.png',
        'splash_screen.png',
        'google-play-button.png',
        'store/skins_panel.png',
        'store/store_button.png',
        'store/store-ui.png',
        'store/times_2_panel.png',
        'store/x2coins-certificate.png',
      ]).then((images) =>
          print('Done loading ' + images.length.toString() + ' images.')),
      Data.loadHardData(),
      IAP.setup(),
      Audio.init(),
    ];
    Future.wait(ps).then((rs) async {
      if (ENABLE_LOGIN && (await PlayUser.shouldAutoLogin())) {
        _performSignIn();
      } else {
        await Data.loadLocalSoftData();
        this.setState(() => loading = false);
      }
      Audio.play(Song.MENU);
    });
  }

  void _performSignIn() async {
    try {
      Data.user = await PlayUser.singIn();
      SavedData data = await Data.fetch(false);
      if (data != null) {
        Data.setData(data);
      } else {
        await Data.loadLocalSoftData();
      }
      await PlayUser.setDisableAutoLogin(false);
      setState(() {
        this.user = Data.user;
        this.loading = false;
      });
    } catch (ex) {
      await PlayUser.setDisableAutoLogin(true);
      Data.user = null;
      await Data.loadLocalSoftData();
      setState(() {
        this.user = null;
        this.loading = false;
      });
      print('Error: $ex');
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(ex.toString()),
      ));
    }
    userCallback = Data.addUserCallback((user) => this.setState(() => this.user = user));
  }

  Widget userCard() {
    const S = 2.0;
    if (user == null) {
      return GestureDetector(
        child: Container(
            margin: const EdgeInsets.only(left: 12),
            child: Image.asset('assets/images/google-play-button.png',
                filterQuality: FilterQuality.none,
                fit: BoxFit.cover,
                width: 89 * S,
                height: 17 * S)),
        onTap: () => _performSignIn(),
      );
    }
    return GestureDetector(
      child: Stack(
        children: [
          Image.asset('assets/images/username-panel.png',
              filterQuality: FilterQuality.none,
              fit: BoxFit.cover,
              width: 88 * S,
              height: 18 * S),
          Positioned(
              child: Text(user.account.displayName,
                  style: TextStyle(fontFamily: '5x5', fontSize: 14.0)),
              right: (S * 20),
              top: 10),
          Positioned(
              child: RawImage(image: user.avatar, width: S * 9, height: S * 9),
              right: S * 7,
              top: S * 2,
              width: S * 9,
              height: S * 9),
        ],
      ),
      onTap: () async {
        setState(() => showingAchievements = true);
        await PlayGames.showAchievements();
        setState(() => showingAchievements = false);
      },
    );
  }

  String _tutorialImage() {
    switch (tutorialStatus) {
      case TutorialStatus.PAGE_0_GAMEPAD:
        return 'tutorial-gamepad';
      case TutorialStatus.PAGE_0_REGULAR:
        return 'tutorial';
      case TutorialStatus.PAGE_1:
        return 'tutorial-2';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        decoration: BoxDecoration(
          color: Color(0xFF000000),
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

    if (tutorialStatus != TutorialStatus.NOT_SHOWING) {
      return _TutorialOverlay(main, _tutorialImage(), () => this.setState(() => tutorialStatus = getNextStatus(tutorialStatus)));
    }

    if (showingAchievements) {
      return GestureDetector(
        child: main,
        behavior: HitTestBehavior.opaque,
      );
    }

    return main;
  }

  void displayTutorial() async {
    TutorialStatus nxtStatus = await getFirstTutorialStatus();
    setState(() => tutorialStatus = nxtStatus);
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
              pad(Text('gems', style: title), 2.0),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Column(
            children: [
              btn('Play', () => Navigator.of(context).pushNamed('/start')),
              btn('Score', () => Navigator.of(context).pushNamed('/score')),
              btn('How to Play', displayTutorial),
              btn('Credits', () => Navigator.of(context).pushNamed('/credits')),
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
          Positioned(
            child: AudioControlWidget(),
            top: 4.0,
            left: 4.0,
          ),
          Positioned(
              child: Column(
                children: [
                  Row(children: this.topRightButtons()),
                  pad(CoinWidget(), 4.0)
                ],
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
              top: 12.0,
              right: 12.0),
          Positioned(child: userCard(), bottom: 5, left: 0),
          Positioned(child: AsyncSaver.widget, bottom: 4.0, right: 4.0),
        ],
      ),
    );
  }

  List<Widget> topRightButtons() {
    List<Widget> result = [];
    if (IAP.pro) {
      result.add(ProBadge());
    }
    result.add(StoreButtonWidget());
    return result;
  }

  @override
  void dispose() {
    if (userCallback != null) {
      Data.removeUserCallback(userCallback);
    }
    super.dispose();
  }
}
