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
  bool _loadFailed = false;
  bool _searchFailed = false;

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

  /// Liste yüklenemedi ("Tekrar dene" gösterilir).
  bool get loadFailed => _loadFailed;

  /// Arama yapılamadı.
  bool get searchFailed => _searchFailed;

  /// Ekrana her girişte arama temizlenir, tüm topluluklar görünür. Sessiz:
  /// ekran kurulurken (build sırasında) çağrılır.
  void resetSearch() {
    _query = '';
    _results = const [];
    _searching = false;
    _searchFailed = false;
    _searchSeq++;
  }

  AppUser? _user;

  /// [user]'ın toplulukları (okul topluluğu en üstte).
  Future<void> load(AppUser user) async {
    _user = user;
    _loadFailed = false;
    try {
      _mine = await _repo.myCommunities(
        userId: user.id,
        school: user.community,
      );
      _loaded = true;
    } catch (_) {
      _loadFailed = true;
    } finally {
      notifyListeners();
    }
  }

  /// "Tekrar dene".
  Future<void> retryLoad() async {
    final user = _user;
    if (user == null) return;
    _loadFailed = false;
    notifyListeners(); // hata → yükleniyor
    await load(user);
  }

  Future<void> _reload() async {
    final user = _user;
    if (user == null) return;
    _mine = await _repo.myCommunities(userId: user.id, school: user.community);
  }

  /// Çıkışta / kullanıcı değişince: önceki kullanıcının verisi kalmasın.
  void reset() {
    _user = null;
    _mine = const [];
    _loaded = false;
    _loadFailed = false;
    _codeFailure = null;
    _busy = false;
    resetSearch();
    notifyListeners();
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
    _searchFailed = false;
    notifyListeners();
    try {
      final found = await _repo.search(value);
      if (seq != _searchSeq) return; // eski sonuç
      _results = found;
    } catch (_) {
      if (seq != _searchSeq) return;
      _results = const [];
      _searchFailed = true;
    }
    _searching = false;
    notifyListeners();
  }

  /// Başarılıysa true.
  Future<bool> join(String id) async {
    try {
      await _repo.join(id);
      await _reload();
      if (isSearch) _results = await _repo.search(_query);
      return true;
    } catch (_) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  void clearCodeFailure() {
    if (_codeFailure == null) return;
    _codeFailure = null;
    notifyListeners();
  }

  /// Kodun topluluğunu katılmadan getirir (önizleme). Başarısızsa null
  /// ([codeFailure]).
  Future<CommunityInfo?> previewByCode(String code) async {
    _codeFailure = null;
    _busy = true;
    notifyListeners();
    try {
      return await _repo.previewByCode(code);
    } on CommunityException catch (e) {
      _codeFailure = e.failure;
      return null;
    } catch (_) {
      _codeFailure = CommunityFailure.unknown;
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
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
    } catch (_) {
      _codeFailure = CommunityFailure.unknown;
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  static bool validName(String name) => name.trim().length >= minNameLength;

  /// Başarısızsa null.
  Future<CommunityInfo?> create({
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
    } catch (_) {
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// 1.17 · Ayrıl. Başarılıysa true.
  Future<bool> leave(String id) async {
    try {
      await _repo.leave(id);
      _mine = _mine.where((c) => c.id != id).toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// 1.16f · Sil (kurucu). Başarılıysa true.
  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
      _mine = _mine.where((c) => c.id != id).toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      notifyListeners();
    }
  }
}
