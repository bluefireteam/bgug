import 'dart:ui';
import 'dart:io';

import 'components/hud.dart';

bool ENABLE_LOGIN = Platform.isAndroid;
const bool ENABLE_ADS = true;
const bool ENABLE_IAP = true;

const double BAR_SIZE = 16.0;
const double SECTOR_LENGTH = 1000.0;
const double SECTOR_MARGIN = 16.0;

final sizeTenth = (Size size) => (sizeBottom(size) - sizeTop(size)) / 8;
final sizeBottom = (Size size) => size.height - BAR_SIZE;
final sizeTop = (Size size) => BAR_SIZE + Hud.HEIGHT;
