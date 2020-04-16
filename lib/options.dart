import 'package:json_annotation/json_annotation.dart';

part 'options.g.dart';

@JsonSerializable()
class Options {
  double bulletSpeed;

  int buttonCost;
  int buttonIncCost;
  int coinsAwardedPerBlock;
  double blockLifespan;

  int maxHoldJumpMillis;
  double gravityImpulse;
  double jumpImpulse;
  double diveImpulse;
  double jumpTimeMultiplier;

  int mapSize;
  bool hasGuns;

  bool get hasLimit => mapSize != -1;

  Options() {
    bulletSpeed = 500.0;
    buttonCost = 4;
    buttonIncCost = 0;
    coinsAwardedPerBlock = 3;
    blockLifespan = 24.0;
    maxHoldJumpMillis = 500;
    gravityImpulse = 1875.0;
    jumpImpulse = 7000.0;
    diveImpulse = 20000.0;
    jumpTimeMultiplier = 0.0004;
    mapSize = -1; // infinite
    hasGuns = true;
  }

  factory Options.fromJson(Map<String, dynamic> json) => _$OptionsFromJson(json);
  Map<String, dynamic> toJson() => _$OptionsToJson(this);

  Options clone() {
    return Options.fromJson(toJson());
  }
}
