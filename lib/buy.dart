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
}
