import 'package:json_annotation/json_annotation.dart';

import 'game.dart';

part 'score.g.dart';

@JsonSerializable()
class Score {
  List<String> scores;

  double maxDistance;
  double totalDistance;
  int maxJumps;
  int totalJumps;
  int maxDives;
  int totalDives;
  int maxGems;
  int totalGems;
  int maxCoins;
  int totalCoins;

  Score() {
    scores = [];
    maxDistance = 0;
    totalDistance = 0;
    maxJumps = 0;
    totalJumps = 0;
    maxDives = 0;
    totalDives = 0;
    maxGems = 0;
    totalGems = 0;
    maxCoins = 0;
    totalCoins = 0;
  }

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreToJson(this);

  void score(BgugGame game) {
    double distance = game.hud.maxDistance;
    int jumps = game.totalJumps;
    int dives = game.totalDives;
    int gems = game.points;
    int coins = game.currentCoins;

    String score = 'Scored ${distance.toStringAsFixed(2)} meters earning $coins coins.';
    scores.add(score);

    if (distance > maxDistance) {
      maxDistance = distance;
    }
    totalDistance += distance;

    if (jumps > maxJumps) {
      maxJumps = jumps;
    }
    totalJumps += jumps;

    if (dives > maxDives) {
      maxDives = dives;
    }
    totalDives += dives;

    if (gems > maxGems) {
      maxGems = gems;
    }
    totalGems += gems;

    if (coins > maxCoins) {
      maxCoins = coins;
    }
    totalCoins += coins;
  }
}
