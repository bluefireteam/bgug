import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components/component.dart';

import 'constants.dart';
import 'components/obstacle.dart';
import 'components/gem.dart';
import 'components/coin.dart';

math.Random random = math.Random();

class WorldGen {
  static List<Component> _generateSectorZero(Size size) {
    const x = SECTOR_LENGTH / 2;
    final y = sizeBottom(size) - 1.2 * sizeTenth(size);

    return [Gem(x, y)];
  }

  static List<Component> generateSector(Size size, int sector) {
    if (sector == 0) {
      return _generateSectorZero(size);
    }

    final start = sector * SECTOR_LENGTH + SECTOR_MARGIN;
    final length = (SECTOR_LENGTH - 2 * SECTOR_MARGIN).round();

    final list = <PositionComponent>[];
    final blockMaxAmount = (4 + sector / 4).round();
    for (int i = random.nextInt(blockMaxAmount); i > 0; i--) {
      final x = start + random.nextInt(length);
      final obstacle = random.nextBool() ? DownObstacle(x) : UpObstacle(x);
      obstacle.resize(size);
      if (list.any((box) => box.toRect().overlaps(obstacle.toRect()) || (box.x - obstacle.x).abs() < 12.0)) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      list.add(obstacle);
    }

    for (int i = random.nextInt(6); i > 0; i--) {
      final x = start + random.nextInt(length);
      final y = sizeBottom(size) - (1 + random.nextInt(8)) * sizeTenth(size);
      final gem = Gem(x, y);
      if (list.any((box) => box.toRect().overlaps(gem.toRect().inflate(8.0)))) {
        if (random.nextBool()) {
          i++;
        }
        continue;
      }
      list.add(gem);
    }

    final coinChance = 0.2 + math.min(0.005 * sector, 0.5);
    if (random.nextDouble() < coinChance) {
      final x = start + random.nextInt(length);
      final y = sizeBottom(size) - (1 + random.nextInt(8)) * sizeTenth(size);
      list.add(Coin(x, y));
    }

    return list;
  }
}
