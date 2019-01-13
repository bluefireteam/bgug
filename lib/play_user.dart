import 'dart:ui';

import 'package:play_games/play_games.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayUser {
  Account account;
  Image avatar;

  PlayUser(this.account, this.avatar);

  static Future<PlayUser> singIn() async {
    try {
      SigninResult result = await PlayGames.signIn(scopeSnapshot: true).timeout(new Duration(seconds: 30), onTimeout: () => throw 'Timeout 30 seconds');
      if (result.success) {
        await PlayGames.setPopupOptions().timeout(new Duration(seconds: 5), onTimeout: () => throw 'Timeout 5 seconds');
        Account acc = result.account;
        Image image = await acc.iconImage;
        return new PlayUser(acc, image);
      } else {
        throw 'Unable to login to play games; reason: ${result.message}.';
      }
    } catch (e) {
      throw 'Unable to login to play games; error: $e';
    }
  }

  static Future<bool> shouldAutoLogin() async {
    return !(await isDisableAutoLogin());
  }

  static Future<bool> isDisableAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString('bgug.disable_auto_login');
    print('Get disable_auto_login: $value');
    return value == 'true';
  }

  static Future<bool> setDisableAutoLogin(bool value) async {
    print('Set disable_auto_login: $value');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('bgug.disable_auto_login', value.toString());
  }
}
