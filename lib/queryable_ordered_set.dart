import 'package:flame/components/component.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import 'components/block.dart';
import 'components/end_card.dart';
import 'components/hud.dart';
import 'components/player.dart';
import 'components/shooter.dart';
import 'components/tutorial.dart';

class QueryableOrderedSet<T, E> extends OrderedSet<T> {
  Map<E, bool Function(T)> _fns = {};
  Map<E, List<T>> _cache = {};

  QueryableOrderedSet([int compare(T e1, T e2)]) : super(compare);

  void register(E e, bool Function(T) query) {
    _fns[e] = query;
    _cache[e] = _filter(_fns[e]);
  }

  List<T> query(E e) {
    return _cache[e];
  }

  @override
  bool add(T t) {
    if (super.add(t)) {
      _fns.keys.forEach((e) {
        if (_fns[e](t)) {
          _cache[e].add(t);
        }
      });
      return true;
    }
    return false;
  }

  @override
  int removeWhere(bool test(T element)) {
    _cache.values.forEach((v) => v.removeWhere(test));
    return super.removeWhere(test);
  }

  @override
  bool remove(T e) {
    _cache.values.forEach((v) => v.remove(e));
    return super.remove(e);
  }

  @override
  void clear() {
    _cache.values.forEach((v) => v.clear());
    super.clear();
  }

  List<T> _filter(bool Function(T) query) => this.where(query).toList();
}

enum Queries {
  BaseBlock,
  Player,
  Shooter,
  Hud,
  EndCard,
  Tutorial,
}

class QueryableOrderedSetImpl extends QueryableOrderedSet<Component, Queries> {
  QueryableOrderedSetImpl() : super(Comparing.on((c) => c.priority())) {
    this.register(Queries.BaseBlock, (e) => e is BaseBlock);
    this.register(Queries.Player, (e) => e is Player);
    this.register(Queries.Shooter, (e) => e is Shooter);
    this.register(Queries.Hud, (e) => e is Hud);
    this.register(Queries.EndCard, (e) => e is EndCard);
    this.register(Queries.Tutorial, (e) => e is Tutorial);
  }

  Iterable<Shooter> shooters() {
    return _postFilter<Shooter>(Queries.Shooter);
  }

  Iterable<BaseBlock> blocks() {
    return _postFilter<BaseBlock>(Queries.BaseBlock);
  }

  Player player() {
    return _firstOrNull<Player>(Queries.Player);
  }

  Hud hud() {
    return _firstOrNull<Hud>(Queries.Hud);
  }

  EndCard endCard() {
    return _firstOrNull<EndCard>(Queries.EndCard);
  }

  Tutorial tutorial() {
    return _firstOrNull<Tutorial>(Queries.Tutorial);
  }

  bool has(Queries q) {
    return _postFilter(q).isNotEmpty;
  }

  T _firstOrNull<T>(Queries e) {
    if (!has(e)) {
      return null;
    }
    return _postFilter<T>(e).first;
  }

  Iterable<T> _postFilter<T>(Queries e) {
    return query(e).cast();
  }
}
