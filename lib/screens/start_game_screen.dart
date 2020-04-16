import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';
import '../game.dart';
import '../main.dart';
import '../audio.dart';
import '../options.dart';
import 'gui_commons.dart';

class StartGameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartGameScreenState();
}

class MyGameBinder extends BgugGame {
  _StartGameScreenState screen;

  MyGameBinder(this.screen, bool shouldSore, bool showTutorial) : super(shouldSore, showTutorial);

  @override
  void stop() {
    super.stop();
    Audio.play(Song.MENU);
    screen?.redraw();
  }
}

class _StartGameScreenState extends State<StartGameScreen> {
  void redraw() {
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    if (Main.game != null) {
      if (Main.game.state != GameState.STOPPED) {
        return WillPopScope(
          onWillPop: () async {
            return await Main.game.willPop();
          },
          child: Main.game.widget,
        );
      } else {
        Main.game = null;
        setState(() {});
      }
    }

    return rootContainer(
      Center(
        child: LayoutBuilder(builder: (_, size) {
          return Stack(children: [
            Row(
              children: [
                Column(
                  children: [
                    pad(const Text('pLaY', style: title), 20.0),
                    btn('Go back', () {
                      Navigator.of(context).pop();
                    }),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Column(
                  children: [
                    btn('Endless', () => startGame(true, Options())),
                    btn('Playground', () => startGame(false, Data.options)),
                    btn('Config Playground', () => Navigator.of(context).pushNamed('/options')),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Positioned(
              child: const Center(child: const Text('Playground can be configured as you wish, but will NOT award coins nor scoreboard entries.')),
              bottom: 4.0,
              width: size.maxWidth,
            )
          ]);
        }),
      ),
    );
  }

  void startGame(bool shouldSore, Options options) async {
    final showTutorial = await Data.getAndToggleShowTutorial();
    Data.currentOptions = options;
    Main.game = MyGameBinder(this, shouldSore, showTutorial);
    setState(() {});
  }
}
