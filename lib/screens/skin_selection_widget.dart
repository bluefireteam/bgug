import 'dart:math' as math;

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/widgets.dart';

import '../components/coin.dart';
import '../components/floor.dart';
import '../components/lock.dart';
import '../data.dart';
import '../skin_list.dart';
import '../util.dart';
import 'store_skin_component.dart';

math.Random rand = math.Random();
TextConfig config = defaultText.withFontSize(24.0);

class _SkinCardComponent extends Component with Resizable {
  static Sprite btnOn = Sprite('store/store-ui.png', y: 36, width: 100, height: 36);
  static Sprite btnOff = Sprite('store/store-ui.png', width: 100, height: 36);

  _SkinSelectionGame gameRef;
  Skin skin;

  _SkinCardComponent(this.gameRef);

  bool get _btnOn => gameRef.currentOwn ? Data.buy.selectedSkin != skin.file : (skin.cost != 0 && Data.buy.coins >= skin.cost);

  String get _btnText => !gameRef.currentOwn ? (skin.cost > 0 ? 'Buy for ${skin.cost}' : 'Exclusive') : (_btnOn ? 'Equip' : 'In Use');

  @override
  void render(Canvas c) {
    if (gameRef.isMoving || skin == null) {
      return;
    }

    config.render(c, skin.name, Position(size.width / 2, 32.0), anchor: Anchor.topCenter);

    (_btnOn ? btnOn : btnOff).renderPosition(c, Position((size.width - 200) / 2, 64.0), size: Position(200.0, 72.0));
    config.render(c, _btnText, Position(size.width / 2, 64.0 + 72.0 / 2), anchor: Anchor.center);
  }

  @override
  void update(double t) {}
}

class _ArrowButton extends SpriteComponent {
  _SkinSelectionGame gameRef;
  bool left;

  _ArrowButton(this.gameRef, this.left) : super.fromSprite(1.0, 1.0, Sprite('store/store-ui.png', x: left ? 0 : 16, y: 72, width: 16, height: 64));

  @override
  void render(Canvas canvas) {
    if (gameRef.hideGui) {
      return;
    }
    super.render(canvas);
  }

  @override
  void resize(Size size) {
    const frac = 2;

    width = frac * 15.0;
    height = frac * 64.0;

    x = left ? 16.0 : size.width - 16.0 - width;
    y = (size.height - height) / 2;
  }
}

class _SkinSelectionGame extends BaseGame {
  bool loading = false;
  bool buying = false;
  int selected = 0;

  _SkinCardComponent card;
  Lock lock;

  List<Skin> skins;

  void _updateSkinList() {
    skins = List.from(Data.skinList.skins);
    skins.sort((s1, s2) {
      if (Data.buy.selectedSkin == s1.file) {
        return -1;
      } else if (Data.buy.selectedSkin == s2.file) {
        return 1;
      }

      final bool has1 = Data.buy.skinsOwned.contains(s1.file);
      final bool has2 = Data.buy.skinsOwned.contains(s2.file);
      if (has1 && !has2) {
        return 1;
      } else if (!has1 && has2) {
        return -1;
      }

      final bool hasPrice1 = s1.cost > 0;
      final bool hasPrice2 = s2.cost > 0;

      if (hasPrice1 && !hasPrice2) {
        return 1;
      } else if (!hasPrice1 && hasPrice2) {
        return -1;
      } else if (hasPrice1 && hasPrice2) {
        return -s1.cost.compareTo(s2.cost);
      } else {
        return -s1.name.compareTo(s2.name);
      }
    });

    _redrawSkinComponents();
  }

  Iterable<StoreSkinComponent> get skinComponents => components.where((c) => c is StoreSkinComponent).cast();

  bool get isMoving => skinComponents.any((s) => s.isMoving);

  bool doOwnSkin(int idx) => Data.buy.skinsOwned.contains(skins[idx].file);

  bool get currentOwn => doOwnSkin(selected);

  bool get lockVisible => !isMoving && !currentOwn;

  bool get hideGui => loading || isMoving || buying;

  _SkinSelectionGame() {
    add(Floor());
    add(_ArrowButton(this, true));
    add(_ArrowButton(this, false));
    add(card = _SkinCardComponent(this));
    add(lock = Lock(() => lockVisible));

    _updateSkinList();
  }

  void _redrawSkinComponents() {
    components.removeWhere((c) => c is StoreSkinComponent);
    _addStartSkin(1, selected - 2);
    _addStartSkin(2, selected - 1);
    _addStartSkin(3, selected);
    _addStartSkin(4, selected + 1);
    _addStartSkin(5, selected + 2);

    _updateSelectedSkin();
  }

  void _addStartSkin(int place, int idx) {
    idx = _fixIdx(idx);
    add(StoreSkinComponent.startAt(Place.places[place], skins[idx].file, !doOwnSkin(idx)));
  }

  int _fixIdx(int idx) {
    return (idx + skins.length) % skins.length;
  }

  void hitPrev() {
    skinComponents.forEach((s) => s.next());
    final int nextIdx = _fixIdx(selected - 2);
    _addLaterSkin(StartingPlace.LEFT, nextIdx);
  }

  void hitNext() {
    skinComponents.forEach((s) => s.prev());
    final int prevIdx = _fixIdx(selected + 2);
    _addLaterSkin(StartingPlace.RIGHT, prevIdx);
  }

  void _addLaterSkin(StartingPlace place, int nextIdx) {
    add(StoreSkinComponent(place, skins[nextIdx].file, !doOwnSkin(nextIdx)));
    _updateSelectedSkin();
  }

  void _updateSelectedSkin() {
    if (!currentOwn) {
      lock.reset();
    }
    card.skin = skins[selected];
  }

  void tap(TapDownDetails evt) {
    final x = evt.globalPosition.dx;
    if (hideGui) {
      return;
    }
    if (x < size.width / 3) {
      selected++;
      while (selected >= skins.length) {
        selected -= skins.length;
      }
      hitNext();
    } else if (x > 2 * size.width / 3) {
      selected--;
      while (selected < 0) {
        selected += skins.length;
      }
      hitPrev();
    } else {
      if (currentOwn) {
        Data.buy.selectedSkin = skins[selected].file;
        loading = true;
        Data.save().then((_) {
          selected = 0;
          _updateSkinList();
          loading = false;
        });
      } else if (skins[selected].cost > 0 && Data.buy.coins >= skins[selected].cost) {
        buying = true;
        final Position start = Position(camera.x + 20 + 32.0 / 2, camera.y + 20 + 32.0 / 2);
        final Position end = Position((size.width - 200) / 2 + 200 / 2, 64.0 + 72 / 2);
        final CoinTrace trace = CoinTrace(false, start, end);
        addLater(trace);
        lock.closed = false;
        trace.after.then((_) {
          Data.buy.coins -= skins[selected].cost;
          Data.buy.skinsOwned.add(skins[selected].file);
          Data.buy.selectedSkin = skins[selected].file;
          skinComponents.firstWhere((s) => s.skin == skins[selected].file)?.locked = false;
          buying = false;
          loading = true;
          Data.checkAchievementsAndSkins();
          Data.save().then((_) {
            selected = 0;
            _updateSkinList();
            loading = false;
          });
        });
      }
    }
  }

  @override
  void renderComponent(Canvas canvas, Component c) {
    canvas.translate(-camera.x, -camera.y);
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }
}

class SkinSelectionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SkinSelectionWidgetState();
}

class _SkinSelectionWidgetState extends State<SkinSelectionWidget> {
  final _SkinSelectionGame game;

  _SkinSelectionWidgetState() : game = _SkinSelectionGame();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: EmbeddedGameWidget(game),
      onTapDown: (evt) => game.tap(evt),
    );
  }
}
