import 'package:firebase_admob/firebase_admob.dart';

class Ad {
  InterstitialAd _ad;
  MobileAdListener listener;
  bool loaded;

  set ad(InterstitialAd ad) {
    loaded = false;
    _ad = ad..load();
  }

  void show() {
    _ad.show();
  }

  void handle(MobileAdEvent evt) {
    if (evt == MobileAdEvent.loaded) {
      loaded = true;
    } else {
      listener(evt);
    }
  }

  static void startup() {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-1451557002406313~7960207117');
  }

  static Ad loadAd() {
    MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
      keywords: ['game', 'blocks', 'guns'],
      testDevices: ["7C7297F768C9EDFA141F5C3E1821C8E2"],
    );
    var ad = new Ad();
    ad.ad = new InterstitialAd(
      adUnitId: 'ca-app-pub-1451557002406313/3919043844',
      targetingInfo: targetingInfo,
      listener: (evt) => ad.handle(evt),
    );
    return ad;
  }
}
