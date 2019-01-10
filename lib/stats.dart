import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';

import 'game.dart';

part 'stats.g.dart';

@JsonSerializable()
class Score {
  double distance;
  int coins;
  Score(this.distance, this.coins);
  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreToJson(this);
  String toText() => 'Scored ${distance.toStringAsFixed(2)} meters earning $coins coins.';
}

@JsonSerializable()
class Stats {
  static const MAX_SCORES = 10;

  List<Score> scores;

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

  Stats() {
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

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);

  Map<String, dynamic> toJson() => _$StatsToJson(this);

  void calculateStats(BgugGame game) {
    double distance = game.hud.maxDistanceInMeters;
    int jumps = game.totalJumps;
    int dives = game.totalDives;
    int gems = game.points;
    int coins = game.currentCoins;

    Score score = Score(distance, coins);
    scores.insert(0, score);
    scores = normalize(scores);

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

  static List<T> normalize<T>(List<T> scores) => scores.sublist(0, MAX_SCORES.clamp(0, scores.length));

  static Stats merge(Stats stats1, Stats stats2) {
    return new Stats()
      ..scores = normalize((new Set()..addAll(stats1.scores)..addAll(stats2.scores)).toList().cast<Score>())
      ..maxDistance = math.max(stats1.maxDistance, stats2.maxDistance)
      ..totalDistance = math.max(stats1.totalDistance, stats2.totalDistance)
      ..maxJumps = math.max(stats1.maxJumps, stats2.maxJumps)
      ..totalJumps = math.max(stats1.totalJumps, stats2.totalJumps)
      ..maxDives = math.max(stats1.maxDives, stats2.maxDives)
      ..totalDives = math.max(stats1.totalDives, stats2.totalDives)
      ..maxGems = math.max(stats1.maxGems, stats2.maxGems)
      ..totalGems = math.max(stats1.totalGems, stats2.totalGems)
      ..maxCoins = math.max(stats1.maxCoins, stats2.maxCoins)
      ..totalCoins = math.max(stats1.totalCoins, stats2.totalCoins);
  }
}
