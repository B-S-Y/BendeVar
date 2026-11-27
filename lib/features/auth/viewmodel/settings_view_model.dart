import 'package:flutter/foundation.dart';

import '../../../data/models/settings_models.dart';
import '../../../data/repositories/repositories.dart';

/// Ayarlar: bildirim tercihleri (1.18) ve engellenen hesaplar (1.20/1.21).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repo);

  final SettingsRepository _repo;

  NotificationPrefs _prefs = const NotificationPrefs();
  List<BlockedUser> _blocked = const [];
  bool _loadedPrefs = false;
  bool _loadedBlocked = false;

  NotificationPrefs get prefs => _prefs;
  List<BlockedUser> get blocked => _blocked;
  bool get loadedPrefs => _loadedPrefs;
  bool get loadedBlocked => _loadedBlocked;

  Future<void> loadPrefs() async {
    _prefs = await _repo.notificationPrefs();
    _loadedPrefs = true;
    notifyListeners();
  }

  Future<void> loadBlocked() async {
    _blocked = await _repo.blockedUsers();
    _loadedBlocked = true;
    notifyListeners();
  }

  Future<void> setPrefs(NotificationPrefs next) async {
    _prefs = next;
    notifyListeners();
    await _repo.saveNotificationPrefs(next);
  }

  Future<void> unblock(String id) async {
    await _repo.unblock(id);
    _blocked = _blocked.where((b) => b.id != id).toList();
    notifyListeners();
  }
}
