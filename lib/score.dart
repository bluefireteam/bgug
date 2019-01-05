import 'dart:math' as math;
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

  static Score merge(Score score1, Score score2) {
    return new Score()
      ..scores = (new Set()..addAll(score1.scores)..addAll(score2.scores)).toList().cast<String>()
      ..maxDistance = math.max(score1.maxDistance, score2.maxDistance)
      ..totalDistance = math.max(score1.totalDistance, score2.totalDistance)
      ..maxJumps = math.max(score1.maxJumps, score2.maxJumps)
      ..totalJumps = math.max(score1.totalJumps, score2.totalJumps)
      ..maxDives = math.max(score1.maxDives, score2.maxDives)
      ..totalDives = math.max(score1.totalDives, score2.totalDives)
      ..maxGems = math.max(score1.maxGems, score2.maxGems)
      ..totalGems = math.max(score1.totalGems, score2.totalGems)
      ..maxCoins = math.max(score1.maxCoins, score2.maxCoins)
      ..totalCoins = math.max(score1.totalCoins, score2.totalCoins);
  }
}
