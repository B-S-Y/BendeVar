import 'package:flutter/foundation.dart';

import '../../../data/models/settings_models.dart';
import '../../../data/repositories/repositories.dart';

/// Ayarlar: bildirim tercihleri (1.18) ve engellenen hesaplar (1.20/1.21).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repo);

  final SettingsRepository _repo;

  /// Verileri yüklenen kullanıcı (app.dart, oturum değişince günceller).
  String _userId = '';
  String get userId => _userId;

  /// Kullanıcı değişince önceki kullanıcının verisi bırakılır.
  void setUser(String? id) {
    final next = id ?? '';
    if (next == _userId) return;
    _userId = next;
    reset();
  }

  NotificationPrefs _prefs = const NotificationPrefs();
  List<BlockedUser> _blocked = const [];
  bool _loadedPrefs = false;
  bool _loadedBlocked = false;
  bool _prefsFailed = false;
  bool _blockedFailed = false;

  NotificationPrefs get prefs => _prefs;
  List<BlockedUser> get blocked => _blocked;
  bool get loadedPrefs => _loadedPrefs;
  bool get loadedBlocked => _loadedBlocked;
  bool get prefsFailed => _prefsFailed;
  bool get blockedFailed => _blockedFailed;

  /// Çıkışta / kullanıcı değişince: önceki kullanıcının verisi kalmasın;
  /// ekranlar açılınca yeniden yükler.
  void reset() {
    _prefs = const NotificationPrefs();
    _blocked = const [];
    _loadedPrefs = false;
    _loadedBlocked = false;
    _prefsFailed = false;
    _blockedFailed = false;
    notifyListeners();
  }

  /// "Tekrar dene": hata görünümünü hemen yükleniyora çevirir.
  Future<void> retryPrefs() {
    _prefsFailed = false;
    notifyListeners();
    return loadPrefs();
  }

  Future<void> retryBlocked() {
    _blockedFailed = false;
    notifyListeners();
    return loadBlocked();
  }

  Future<void> loadPrefs() async {
    _prefsFailed = false;
    try {
      _prefs = await _repo.notificationPrefs(_userId);
      _loadedPrefs = true;
    } catch (_) {
      _prefsFailed = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadBlocked() async {
    _blockedFailed = false;
    try {
      _blocked = await _repo.blockedUsers(_userId);
      _loadedBlocked = true;
    } catch (_) {
      _blockedFailed = true;
    } finally {
      notifyListeners();
    }
  }

  /// Hemen uygular; kaydedilemezse eski değere döner ve false verir.
  Future<bool> setPrefs(NotificationPrefs next) async {
    final before = _prefs;
    _prefs = next;
    notifyListeners();
    try {
      await _repo.saveNotificationPrefs(_userId, next);
      return true;
    } catch (_) {
      _prefs = before;
      notifyListeners();
      return false;
    }
  }

  /// Başarılıysa true.
  Future<bool> unblock(String id) async {
    try {
      await _repo.unblock(_userId, id);
      _blocked = _blocked.where((b) => b.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
