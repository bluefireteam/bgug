import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'constants.dart';
import 'data.dart';

class IAP {
  static const PRODUCT_ID = 'bgug_pro';

  static IAPItem iap;
  static bool pro;

  static Future setup() async {
    if (!ENABLE_IAP) {
      iap = null;
      pro = false;
      return;
    }

    try {
      await FlutterInappPurchase.initConnection;
      final items = await FlutterInappPurchase.getProducts([PRODUCT_ID]);
      final purchases = await FlutterInappPurchase.getPurchaseHistory();
      iap = items.first;
      pro = purchases.isNotEmpty && purchases.first.productId == PRODUCT_ID;
    } catch (ex) {
      print('Error with IAP setup: $ex');
      iap = null;
      pro = false;
    }
  }

  static Future purchase() async {
    final purchased = await FlutterInappPurchase.buyProduct(PRODUCT_ID);
    print('Purchace: $purchased');

    pro = true;
    Data.validatePro(pro);
    await Data.save();
  }
}
