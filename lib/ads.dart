import 'package:firebase_admob/firebase_admob.dart';

import 'constants.dart';

class Ad {
  static Function(RewardedVideoAdEvent) listener;
  static bool loaded;

  static void show() {
    RewardedVideoAd.instance.show();
  }

  static void handle(RewardedVideoAdEvent evt) {
    if (evt == RewardedVideoAdEvent.loaded) {
      loaded = true;
    } else {
      listener(evt);
    }
  }

  static Future<bool> startup() async {
    if (ENABLE_ADS) {
      return FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-1451557002406313~7960207117');
    }
    return false;
  }

  static Future loadAd() async {
    if (!ENABLE_ADS) {
      return;
    }
    MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
      keywords: ['game', 'blocks', 'guns', 'platformer', 'action', 'fast'],
    );
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) => handle(event);
    loaded = false;
    await RewardedVideoAd.instance.load(adUnitId: 'ca-app-pub-1451557002406313/3618896211', targetingInfo: targetingInfo);
  }
}
