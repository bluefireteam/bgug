import 'dart:ui';

import 'package:play_games/play_games.dart';

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
}
