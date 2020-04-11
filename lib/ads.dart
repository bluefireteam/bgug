import 'package:firebase_admob/firebase_admob.dart';

import 'constants.dart';
import 'iap.dart';

class Ad {
  static bool get enableAds => ENABLE_ADS && IAP.pro != true;

  static Function(RewardedVideoAdEvent) listener;
  static bool loaded;

  static void show() {
    if (!enableAds) {
      return;
    }
    loaded = false;
    RewardedVideoAd.instance.show();
  }

  static void handle(RewardedVideoAdEvent evt) {
    if (evt == RewardedVideoAdEvent.loaded) {
      print('Ad: loaded an ad succesfully');
      loaded = true;
    } else if (evt == RewardedVideoAdEvent.failedToLoad) {
      print('Ad: failed to loaded an ad');
      loaded = false;
    } else {
      listener(evt);
    }
  }

  static Future<bool> startup() async {
    if (!ENABLE_ADS) {
      return false;
    }
    bool result = await FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-1451557002406313~7960207117');
    loaded = false;
    return result;
  }

  static Future loadAd() async {
    if (!enableAds || loaded) {
      return;
    }
    MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
      keywords: ['game', 'blocks', 'guns', 'platformer', 'action', 'fast'],
    );
    loaded = false;
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) => handle(event);
    await RewardedVideoAd.instance.load(adUnitId: 'ca-app-pub-1451557002406313/3618896211', targetingInfo: targetingInfo);
  }
}
