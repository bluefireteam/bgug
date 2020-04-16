import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'buy.g.dart';

enum PlayerButtonState { LOCKED, AVAILABLE, SELECTED }

@JsonSerializable()
class Buy {
  List<String> skinsOwned;
  String selectedSkin;
  int coins;

  Buy() {
    skinsOwned = ['asimov.png'];
    selectedSkin = 'asimov.png';
    coins = 0;
  }

  factory Buy.fromJson(Map<String, dynamic> json) => _$BuyFromJson(json);

  Map<String, dynamic> toJson() => _$BuyToJson(this);

  static Buy merge(Buy buy1, Buy buy2) {
    return Buy()
        ..skinsOwned = (<String>{}..addAll(buy1.skinsOwned)..addAll(buy2.skinsOwned)).toList().cast<String>()
        ..selectedSkin = buy1.selectedSkin ?? buy2.selectedSkin
        ..coins = math.max(buy1.coins, buy2.coins);
  }
}
