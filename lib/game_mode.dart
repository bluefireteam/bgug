class GameMode {
  static const SINGLE = const GameMode(15000, true, false);
  static const ENDLESS = const GameMode(-1, true, true);
  static const PLAYGROUND = const GameMode(-1, false, false);

  final int mapSize;
  final bool hasGuns;
  final bool gunRespawn;

  const GameMode(this.mapSize, this.hasGuns, this.gunRespawn);

  bool get hasLimit => mapSize != -1;
}
