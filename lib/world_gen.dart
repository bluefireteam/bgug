import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components/component.dart';

import 'constants.dart';
import 'components/obstacle.dart';
import 'components/gem.dart';
import 'components/coin.dart';

math.Random random = new math.Random();

class WorldGen {
  static List<Component> _generateSectorZero(Size size) {
    List<PositionComponent> list = new List();
    double x = SECTOR_LENGTH / 2;
    double y = sizeBottom(size) - 1.2 * sizeTenth(size);
    list.add(new Gem(x, y));
    return list;
  }

  static List<Component> generateSector(Size size, int sector) {
    if (sector == 0) {
      return _generateSectorZero(size);
    }

    double start = sector * SECTOR_LENGTH + SECTOR_MARGIN;
    int length = (SECTOR_LENGTH - 2 * SECTOR_MARGIN).round();

    List<PositionComponent> list = new List();
    int blockMaxAmont = (4 + sector / 4).round();
    for (int i = random.nextInt(blockMaxAmont); i > 0; i--) {
      double x = start + random.nextInt(length);
      UpObstacle obstacle = random.nextBool() ? new Obstacle(x) : new UpObstacle(x);
      obstacle.resize(size);
      if (list.any((box) => box.toRect().overlaps(obstacle.toRect()) || (box.x - obstacle.x).abs() < 8.0)) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      list.add(obstacle);
    }

    for (int i = random.nextInt(6); i > 0; i--) {
      double x = start + random.nextInt(length);
      double y = sizeBottom(size) - (1 + random.nextInt(8)) * sizeTenth(size);
      Gem gem = new Gem(x, y);
      if (list.any((box) => box.toRect().overlaps(gem.toRect().inflate(8.0)))) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      list.add(gem);
    }

    double coinChance = 0.2 + math.min(0.005 * sector, 0.5);
    if (random.nextDouble() < coinChance) {
      double x = start + random.nextInt(length);
      double y = sizeBottom(size) - (1 + random.nextInt(8)) * sizeTenth(size);
      list.add(new Coin(x, y));
    }

    return list;
  }
}
