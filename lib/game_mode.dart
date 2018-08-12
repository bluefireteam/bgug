
class GameMode {
  static String singlePattern(int score, bool won) => won ? 'Won Single; ${score.toString()} points' : 'Lost Single; ${score.toString()} points';
  static String endlessPattern(int score, bool won) => 'Endless; ${score.toString()} points';
  static String playgroundPattern(int score, bool won) => 'Playground; ${score.toString()} points';

  static const SINGLE = const GameMode(15000, true, false, singlePattern);
  static const ENDLESS = const GameMode(-1, true, true, endlessPattern);
  static const PLAYGROUND = const GameMode(-1, false, false, playgroundPattern);

  final int mapSize;
  final bool hasGuns;
  final bool gunRespawn;
  final String Function(int, bool) _scorePattern;

  const GameMode(this.mapSize, this.hasGuns, this.gunRespawn, this._scorePattern);

  bool get hasLimit => mapSize != -1;

  String score(int points, bool won) {
    return _scorePattern(points, won);
  }
}
