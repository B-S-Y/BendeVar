import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema seçimi (sistem / açık / koyu); `shared_preferences` ile saklanır.
class ThemeController extends ChangeNotifier {
  ThemeController([this._prefs]);

  static const String _key = 'theme_mode';

  final SharedPreferences? _prefs;
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final v = p.getString(_key);
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == v,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_key, mode.name);
  }
}
