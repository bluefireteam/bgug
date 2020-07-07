import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'constants.dart';
import 'data.dart';

class IAP {
  static const PRODUCT_ID = 'bgug_pro';

  static IAPItem iap;
  static bool pro;

  static const _PURCHASED_KEY = 'BGUG_PURCHASED_PRO';

  static Future setup() async {
    if (!ENABLE_IAP) {
      iap = null;
      pro = false;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final purchased = prefs.getBool(_PURCHASED_KEY);
      if (purchased != null && purchased) {
        pro = true;
      } else {
        pro = false;
        await FlutterInappPurchase.instance.initConnection;
        final items = await FlutterInappPurchase.instance.getProducts([PRODUCT_ID]);
        iap = items.first;
      }
    } catch (ex) {
      print('Error with IAP setup: $ex');
      iap = null;
      pro = false;
    }
  }

  static Future<bool> restore() async {
      await FlutterInappPurchase.instance.initConnection;
      final purchases = await FlutterInappPurchase.instance.getPurchaseHistory();
      if (purchases.isNotEmpty && purchases.first.productId == PRODUCT_ID) {
        pro = true;
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_PURCHASED_KEY, true);
        Data.validatePro(pro);
        await Data.save();
        return true;
      }

      return false;
  }

  static Future purchase() async {
    final _completer = Completer();
    FlutterInappPurchase.instance.requestPurchase(PRODUCT_ID);

    final _updateSub = FlutterInappPurchase.purchaseUpdated.listen((purchase) async {
      pro = true;
      Data.validatePro(pro);
      await Data.save();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(_PURCHASED_KEY, true);
      _completer.complete();
    });

    final _errorSub = FlutterInappPurchase.purchaseError.listen((purchase) async {
      _completer.completeError('Could not process purchase');
    });

    return _completer.future.whenComplete((){
      _updateSub.cancel();
      _errorSub.cancel();
    });
  }
}
