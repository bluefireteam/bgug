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
    this.bulletSpeed = 500.0;
    this.buttonCost = 4;
    this.buttonIncCost = 0;
    this.coinsAwardedPerBlock = 3;
    this.blockLifespan = 24.0;
    this.maxHoldJumpMillis = 500;
    this.gravityImpulse = 1875.0;
    this.jumpImpulse = 7000.0;
    this.diveImpulse = 20000.0;
    this.jumpTimeMultiplier = 0.0004;
    this.mapSize = -1; // infinite
    this.hasGuns = true;
  }

  factory Options.fromJson(Map<String, dynamic> json) => _$OptionsFromJson(json);
  Map<String, dynamic> toJson() => _$OptionsToJson(this);
}
