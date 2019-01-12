import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'data.dart';

class IAP {
  static const PRODUCT_ID = 'bgug_pro';

  static IAPItem iap;
  static bool pro;

  static Future setup() async {
    try {
      await FlutterInappPurchase.initConnection;
      List<IAPItem> items = await FlutterInappPurchase.getProducts([PRODUCT_ID]);
      List<PurchasedItem> purchases = await FlutterInappPurchase.getPurchaseHistory();
      iap = items.first;
      pro = purchases.isNotEmpty && purchases.first.productId == PRODUCT_ID;
    } catch (ex) {
      print('Error with IAP setup: $ex');
      iap = null;
      pro = false;
    }
  }

  static Future purchase() async {
    PurchasedItem purchased = await FlutterInappPurchase.buyProduct(PRODUCT_ID);
    print('Purchace: $purchased');

    pro = true;
    Data.validatePro(pro);
    await Data.save();
  }
}
