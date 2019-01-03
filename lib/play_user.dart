import 'dart:typed_data';
import 'dart:ui';

import 'package:play_games/play_games.dart';

class PlayUser {
  Account account;
  Image avatar;
  ByteData avatarBytes;

  PlayUser(this.account, this.avatar, this.avatarBytes);

  static Future<PlayUser> singIn() async {
    try {
      SigninResult result = await PlayGames.signIn().timeout(new Duration(seconds: 5), onTimeout: () => throw 'Timeout 5 seconds');
      if (result.success) {
        await PlayGames.setPopupOptions().timeout(new Duration(seconds: 5), onTimeout: () => throw 'Timeout 5 seconds');
        Account acc = result.account;
        Image image = await acc.iconImage;
        return new PlayUser(acc, image, await image.toByteData());
      } else {
        throw 'Unable to login to play games; reason: ${result.message}.';
      }
    } catch (e) {
      throw 'Unable to login to play games; error: $e';
    }
  }
}
