import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../core/utils/text_search.dart';
import 'models/school.dart';

/// Okul rehberi: JSON bir kez yüklenir, bellekte tutulur. Kimlik ve
/// alias'lar tek bir arama haritasında toplanır; arama büyük/küçük harf ve
/// Türkçe karakterden bağımsızdır ([TextSearch.normalize]).
class SchoolDirectory {
  SchoolDirectory(Iterable<School> schools) {
    for (final s in schools) {
      _byKey[TextSearch.normalize(s.id)] = s;
    }
    for (final s in schools) {
      for (final a in s.aliases) {
        _byKey.putIfAbsent(TextSearch.normalize(a), () => s);
      }
    }
  }

  factory SchoolDirectory.fromJson(String source) => SchoolDirectory(
    (jsonDecode(source) as List).map(
      (e) => School.fromJson(e as Map<String, dynamic>),
    ),
  );

  static const String assetPath = 'assets/data/tr_universities.json';

  static SchoolDirectory? _instance;
  static Future<SchoolDirectory>? _loading;

  /// Yüklendiyse hazır rehber (eşzamanlı); yoksa null.
  static SchoolDirectory? get cached => _instance;

  /// Uygulama genelinde tek sefer yüklenen rehber.
  static Future<SchoolDirectory> loadShared() async =>
      _instance ??= await (_loading ??= load(rootBundle));

  static Future<SchoolDirectory> load(AssetBundle bundle) async =>
      SchoolDirectory.fromJson(await bundle.loadString(assetPath));

  final Map<String, School> _byKey = {};

  /// Okul kimliği ya da alias'ına göre okul; bilinmiyorsa null.
  School? find(String schoolId) => _byKey[TextSearch.normalize(schoolId)];
}
