import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

enum ListingSort { newest, oldest }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repo) {
    _all = _repo.current;
    _sub = _repo.watchListings().listen((items) {
      _all = items;
      notifyListeners();
    });
  }

  final ListingRepository _repo;
  StreamSubscription<List<Listing>>? _sub;

  List<Listing> _all = const [];
  ListingKind _kind = ListingKind.ilan;
  ListingCategory? _category;
  String _query = '';
  ListingSort _sort = ListingSort.newest;
  bool _onlyFavorites = false;

  ListingKind get kind => _kind;
  ListingCategory? get category => _category;
  String get query => _query;
  ListingSort get sort => _sort;
  bool get onlyFavorites => _onlyFavorites;

  int countOf(ListingKind k) => _all.where((l) => l.kind == k).length;

  List<Listing> get visible {
    final q = _query.trim().toLowerCase();
    final list = _all.where((l) {
      if (l.kind != _kind) return false;
      if (_category != null && l.category != _category) return false;
      if (_onlyFavorites && !l.isFavorite) return false;
      if (q.isNotEmpty && !l.title.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
    list.sort(
      (a, b) => _sort == ListingSort.newest
          ? b.postedAt.compareTo(a.postedAt)
          : a.postedAt.compareTo(b.postedAt),
    );
    return list;
  }

  void setKind(ListingKind k) {
    _kind = k;
    notifyListeners();
  }

  /// Aynı çipe tekrar basınca filtre kalkar.
  void setCategory(ListingCategory? c) {
    _category = c == _category ? null : c;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void toggleSort() {
    _sort = _sort == ListingSort.newest
        ? ListingSort.oldest
        : ListingSort.newest;
    notifyListeners();
  }

  void toggleOnlyFavorites() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) => _repo.toggleFavorite(id);

  Listing? byId(String id) => _repo.byId(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
