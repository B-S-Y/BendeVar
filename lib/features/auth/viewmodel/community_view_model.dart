import 'package:flutter/foundation.dart';

import '../../../data/models/community_models.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// Topluluklarım (1.16 – 1.17): liste, arama, davet kodu, oluşturma, ayrılma,
/// silme.
class CommunityViewModel extends ChangeNotifier {
  CommunityViewModel(this._repo);

  final CommunityRepository _repo;

  List<CommunityInfo> _mine = const [];
  List<CommunityInfo> _results = const [];
  String _query = '';
  bool _loaded = false;
  bool _searching = false;
  int _searchSeq = 0;
  CommunityFailure? _codeFailure;
  bool _busy = false;

  /// En az bu kadar karakterli ad kabul edilir.
  static const int minNameLength = 3;

  List<CommunityInfo> get mine => _mine;
  List<CommunityInfo> get results => _results;
  String get query => _query;
  bool get loaded => _loaded;
  bool get searching => _searching;
  bool get isSearch => _query.trim().isNotEmpty;
  CommunityFailure? get codeFailure => _codeFailure;
  bool get busy => _busy;

  /// Ekrana her girişte arama temizlenir, tüm topluluklar görünür. Sessiz:
  /// ekran kurulurken (build sırasında) çağrılır.
  void resetSearch() {
    _query = '';
    _results = const [];
    _searching = false;
    _searchSeq++;
  }

  Future<void> load(Community school) async {
    _mine = await _repo.myCommunities(school);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _reload() async {
    // myCommunities okul bilgisini hatırlar; okul her zaman listede.
    final school = _mine.where((c) => c.isSchool);
    if (school.isEmpty) return;
    final s = school.first;
    _mine = await _repo.myCommunities(
      Community(id: s.id, name: s.name, shortName: s.name),
    );
  }

  /// 1.16g · Arama kutusu değişti.
  Future<void> setQuery(String value) async {
    _query = value;
    final seq = ++_searchSeq;
    if (!isSearch) {
      _results = const [];
      _searching = false;
      notifyListeners();
      return;
    }
    _searching = true;
    notifyListeners();
    final found = await _repo.search(value);
    if (seq != _searchSeq) return; // eski sonuç
    _results = found;
    _searching = false;
    notifyListeners();
  }

  Future<void> join(String id) async {
    await _repo.join(id);
    await _reload();
    if (isSearch) _results = await _repo.search(_query);
    notifyListeners();
  }

  void clearCodeFailure() {
    if (_codeFailure == null) return;
    _codeFailure = null;
    notifyListeners();
  }

  /// 1.16b/1.16c · Başarılıysa topluluğu, değilse null döner ([codeFailure]).
  Future<CommunityInfo?> joinByCode(String code) async {
    _codeFailure = null;
    _busy = true;
    notifyListeners();
    try {
      final info = await _repo.joinByCode(code);
      await _reload();
      return info;
    } on CommunityException catch (e) {
      _codeFailure = e.failure;
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  static bool validName(String name) => name.trim().length >= minNameLength;

  Future<CommunityInfo> create({
    required String name,
    required String description,
    required CommunityVisibility visibility,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      final info = await _repo.create(
        name: name,
        description: description,
        visibility: visibility,
      );
      await _reload();
      return info;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// 1.17 · Ayrıl.
  Future<void> leave(String id) async {
    await _repo.leave(id);
    _mine = _mine.where((c) => c.id != id).toList();
    notifyListeners();
  }

  /// 1.16f · Sil (kurucu).
  Future<void> delete(String id) async {
    await _repo.delete(id);
    _mine = _mine.where((c) => c.id != id).toList();
    notifyListeners();
  }
}
