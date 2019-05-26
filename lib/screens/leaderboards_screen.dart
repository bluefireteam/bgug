import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:play_games/play_games.dart';

import 'gui_commons.dart';
import '../data.dart';

enum _TrophyType { GOLD, SILVER, BRONZE }

class _Trophy extends StatelessWidget {
  static final Position size = Position(32.0, 32.0);
  final _TrophyType type;

  _Trophy(this.type);

  Sprite get _sprite => Sprite('trophies.png',
      height: 16.0, width: 16.0, y: 0, x: type.index * 16.0);

  @override
  Widget build(BuildContext context) {
    return EmbeddedGameWidget(
        SimpleGame(SpriteComponent.fromSprite(size.x, size.y, _sprite)),
        size: size);
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int position;
  final String name, value;

  _LeaderboardEntry(this.position, this.name, this.value);

  Widget _trophy() {
    if (position == 0) {
      return _Trophy(_TrophyType.GOLD);
    } else if (position == 1) {
      return _Trophy(_TrophyType.SILVER);
    } else if (position == 2) {
      return _Trophy(_TrophyType.BRONZE);
    }
    return Container(
        constraints: BoxConstraints.expand(
            width: _Trophy.size.x, height: _Trophy.size.y));
  }

  Widget _left() {
    Widget trophy = _trophy();
    Widget text = Text(this.name, style: small_text);
    return Row(children: [trophy, text]);
  }

  Widget _right() {
    return Text(this.value, style: small_text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _left(),
        _right(),
      ],
    );
  }
}

class LeaderboardsScreen extends StatefulWidget {
  @override
  LeaderboardsScreenState createState() {
    return new LeaderboardsScreenState();
  }
}

class ScoreListWeaver {
  final String loggedUser;
  final String leaderboardName;
  ScoreListWeaver(this.leaderboardName, this.loggedUser);

  Future<List<ScoreResult>> fetch() {
    final ps = [
      PlayGames.loadTopScoresByName(leaderboardName, TimeSpan.TIME_SPAN_ALL_TIME, 10),
      PlayGames.loadPlayerCenteredScoresByName(leaderboardName, TimeSpan.TIME_SPAN_ALL_TIME, 1),
    ];
    final isMyScore = (s) => s.scoreHolderDisplayName == this.loggedUser;
    return Future.wait(ps).then((results) {
      List<ScoreResult> scores = results.first.scores;
      List<ScoreResult> userScore = results.last.scores.where(isMyScore).toList();
      bool isUserOnTop10 = scores.any(isMyScore);
      bool userHasOwnScore = userScore.isNotEmpty;
      if (!isUserOnTop10 && userHasOwnScore) {
        scores[scores.length - 1] = userScore.first;
      }
      return scores;
    });
  }
}

class LeaderboardsScreenState extends State<LeaderboardsScreen> {
  static const DISTANCE = 'leaderboard_bgug__max_distances';
  static const COINS = 'leaderboard_bgug__max_coins';

  List<ScoreResult> distances, coins;

  @override
  void initState() {
    super.initState();
    String loggedUser = Data.user.account.displayName;
    ScoreListWeaver(DISTANCE, loggedUser)
        .fetch()
        .then((list) => this.setState(() => distances = list));
    ScoreListWeaver(COINS, loggedUser)
        .fetch()
        .then((list) => this.setState(() => coins = list));
  }

  List<Widget> _toWidget(String titleStr, List<ScoreResult> list) {
    Widget title = pad(Text(titleStr, style: text), 12.0);
    if (list == null) {
      return [title, Text('Loading...', style: small_text)];
    }
    List<Widget> items = list
        .asMap()
        .entries
        .map((e) => _LeaderboardEntry(
            e.key, e.value.scoreHolderDisplayName, e.value.displayScore))
        .toList();
    return [title]..addAll(items);
  }

  bool isMissingFromAnyList() {
    if (distances == null || coins == null) {
      return false;
    }
    String loggedUser = Data.user.account.displayName;
    bool isOnDistances = distances.any((s) => s.scoreHolderDisplayName == loggedUser);
    bool isOnCoins = coins.any((s) => s.scoreHolderDisplayName == loggedUser);
    return !isOnDistances || !isOnCoins;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: pad(Text('LeAdErBoArD', style: title), 20.0)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: pad(
                        Column(children: _toWidget('Distances', distances)),
                        16.0)),
                Expanded(
                    child:
                        pad(Column(children: _toWidget('Coins', coins)), 16.0)),
              ],
            ),
          ),
          isMissingFromAnyList() ? Center(child: Text('Note that you are not listed because you have disabled the option to appear publically in GPGS.')) : Container(),
          btn('Go back', () {
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }
}
