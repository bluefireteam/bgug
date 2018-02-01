import 'package:firebase_admob/firebase_admob.dart';

class Ad {
  InterstitialAd ad;
  bool loaded;

  Ad(this.ad) {
    loaded = false;
    ad.load().then((loaded) {
      print('Loaded ad: ${loaded.toString()}');
      this.loaded = loaded;
    });
  }

  static void startup() {
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-1451557002406313~7960207117');
  }

  static Ad loadAd() {
    MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
      keywords: ['game', 'blocks', 'guns'],
      testDevices: ["7C7297F768C9EDFA141F5C3E1821C8E2"],
    );
    return new Ad(new InterstitialAd(
      unitId: 'ca-app-pub-1451557002406313/3919043844',
      targetingInfo: targetingInfo,
    ));
  }
}
