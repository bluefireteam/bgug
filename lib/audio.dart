import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/flame.dart';
import 'package:flame/audio_pool.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Song { GAME, MENU }

Future<AudioPool> loadSfx(String file) async {
  var audio = new AudioPool(file, prefix: 'audio/', maxPlayers: 4);
  await audio.init();

  return audio;
}

class Audio {
  static AudioCache musicPlayer;
  static Song song;
  static bool isPaused = false;

  static bool _enableMusic;
  static bool enableSfx;
  static bool inited = false;

  static Map<String, AudioPool> sfx = Map();

  static bool get enableMusic => _enableMusic;

  static set enableMusic(bool enableMusic) {
    _enableMusic = enableMusic;
    _updatePlayer();
  }

  static Future init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _enableMusic = prefs.getString('bgug.enable_music') != 'false';
    enableSfx = prefs.getString('bgug.enable_sfx') != 'false';

    musicPlayer = new AudioCache(prefix: 'audio/', fixedPlayer: new AudioPlayer());
    await musicPlayer.loadAll(['music.mp3', 'menu.mp3']);
    await musicPlayer.fixedPlayer.setReleaseMode(ReleaseMode.LOOP);

    sfx['block.wav'] = await loadSfx('block.wav');
    sfx['death.wav'] = await loadSfx('death.wav');
    sfx['gem_collect.wav'] = await loadSfx('gem_collect.wav');
    sfx['jump.wav'] = await loadSfx('jump.wav');
    sfx['laser_load.wav'] = await loadSfx('laser_load.wav');
    sfx['laser_shoot.wav'] = await loadSfx('laser_shoot.wav');

    inited = true;
  }

  static Future saveAudioControls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bgug.enable_music', enableMusic.toString());
    await prefs.setString('bgug.enable_sfx', enableSfx.toString());
  }

  static void playSfx(String file) {
    if (enableSfx && !isPaused) {
      sfx[file].start();
    }
  }

  static void play(Song song) async {
    Audio.song = song;
    if (song == Song.GAME) {
      await musicPlayer.loop('music.mp3');
    } else {
      await musicPlayer.loop('menu.mp3');
    }
    await _updatePlayer();
  }

  static void resume() {
    isPaused = false;
    _updatePlayer();
  }

  static void pause() {
    isPaused = true;
    _updatePlayer();
  }

  static Future _updatePlayer() async {
    if (!inited) {
      return;
    }
    bool should = !isPaused && enableMusic;
    if (song != null) {
      if (should) {
        await musicPlayer.fixedPlayer.resume();
      } else {
        await musicPlayer.fixedPlayer.pause();
      }
    } else {
      await musicPlayer.fixedPlayer.stop();
    }
  }
}
