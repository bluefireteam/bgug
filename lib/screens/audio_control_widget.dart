import 'package:flutter/widgets.dart';

import '../audio.dart';
import 'gui_commons.dart';

class AudioControlWidget extends StatefulWidget {
  @override
  AudioControlWidgetState createState() {
    return AudioControlWidgetState();
  }
}

class AudioControlWidgetState extends State<AudioControlWidget> {
  static const S = 2.0;

  void toggleMusic() async {
    Audio.enableMusic = !Audio.enableMusic;
    await Audio.saveAudioControls();
    setState(() {});
  }

  void toggleSfx() async {
    Audio.enableSfx = !Audio.enableSfx;
    await Audio.saveAudioControls();
    setState(() {});
  }

  Widget _img(String name) {
    return Image.asset('assets/images/$name', scale: 1 / S, filterQuality: FilterQuality.none);
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      pad(GestureDetector(child: _img('sound/music_${Audio.enableMusic ? 'on' : 'off'}.png'), onTap: () => toggleMusic()), 2.0),
      pad(GestureDetector(child: _img('sound/sfx_${Audio.enableSfx ? 'on' : 'off'}.png'), onTap: () => toggleSfx()), 2.0),
    ]);
  }
}
