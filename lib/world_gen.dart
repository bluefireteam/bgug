import 'dart:math' as math;

import 'package:flame/components/component.dart';

import 'constants.dart';
import 'components/obstacle.dart';
import 'components/gem.dart';

math.Random random = new math.Random();

class WorldGen {
  static List<Component> generateSector(int sector) {
    double start = sector * SECTOR_LENGTH;

    List<SpriteComponent> stuffSoFar = new List();
    for (int i = random.nextInt(4); i > 0; i--) {
      double x = start + random.nextInt(1000);
      UpObstacle obstacle = random.nextBool() ? new Obstacle(x) : new UpObstacle(x);
      if (stuffSoFar.any((box) => box.toRect().overlaps(obstacle.toRect()) || (box.x - obstacle.x).abs() < 20.0)) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      stuffSoFar.add(obstacle);
    }

    for (int i = random.nextInt(6); i > 0; i--) {
      double x = start + random.nextInt(1000);
      Gem gem = new Gem(x, (size) => size_bottom(size) - (1 + random.nextInt(8)) * size_tenth(size));
      if (stuffSoFar.any((box) => box.toRect().overlaps(gem.toRect()))) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      stuffSoFar.add(gem);
    }

    return stuffSoFar;
  }
}
