import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocaleChoice { system, tr, en }

/// Dil seçimi (sistem / TR / EN); `shared_preferences` ile saklanır.
class LocaleController extends ChangeNotifier {
  LocaleController([this._prefs]);

  static const String _key = 'locale_choice';

  final SharedPreferences? _prefs;
  LocaleChoice _choice = LocaleChoice.system;

  LocaleChoice get choice => _choice;

  /// `null` = sistem dili (desteklenmiyorsa Türkçe'ye düşer).
  Locale? get locale => switch (_choice) {
    LocaleChoice.system => null,
    LocaleChoice.tr => const Locale('tr'),
    LocaleChoice.en => const Locale('en'),
  };

  Future<void> load() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final v = p.getString(_key);
    _choice = LocaleChoice.values.firstWhere(
      (c) => c.name == v,
      orElse: () => LocaleChoice.system,
    );
    notifyListeners();
  }

  Future<void> setChoice(LocaleChoice choice) async {
    if (choice == _choice) return;
    _choice = choice;
    notifyListeners();
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_key, choice.name);
  }
}
