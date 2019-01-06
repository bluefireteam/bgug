import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

enum Song { GAME, MENU }

class Music {
  static AudioCache player;
  static Song song;
  static bool isPaused = false;

  static Future init() async {
    player = new AudioCache(prefix: 'audio/', fixedPlayer: new AudioPlayer());
    await player.loadAll(['music.mp3', 'menu.mp3']);
    await player.fixedPlayer.setReleaseMode(ReleaseMode.LOOP);
  }

  static void play(Song song) {
    Music.song = song;
    if (song == Song.GAME) {
      player.loop('music.mp3');
    } else {
      player.loop('menu.mp3');
    }
    if (isPaused) {
      player.fixedPlayer.pause();
    }
  }

  static void resume() {
    isPaused = false;
    if (song != null) {
      player.fixedPlayer.resume();
    }
  }

  static void pause() {
    isPaused = true;
    if (song != null) {
      player.fixedPlayer.pause();
    }
  }
}
