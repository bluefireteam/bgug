import 'dart:ui';

import 'components/hud.dart';

const double BAR_SIZE = 16.0;
const double SECTOR_LENGTH = 1000.0;

final size_tenth = (Size size) => (size_bottom(size)- size_top(size)) / 8;
final size_bottom = (Size size) => size.height - BAR_SIZE;
final size_top = (Size size) => BAR_SIZE + Hud.HEIGHT;