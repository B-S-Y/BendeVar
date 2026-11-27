/// Türkçe'ye duyarlı arama normalizasyonu. Aranan ve hedef metin AYNI
/// fonksiyondan geçirilir: büyük/küçük harf ve Türkçe karakter farkı yok sayılır.
///
/// - Türkçe küçültme: `İ→i`, `I→ı`; sonra `ı→i`, `ç→c`, `ğ→g`, `ö→o`, `ş→s`,
///   `ü→u` (ASCII karşılıkları). Böylece "acik", "AÇIK", "Açık" ve
///   "istanbul", "İstanbul", "ISTANBUL" birbirini bulur.
abstract final class TextSearch {
  static const Map<String, String> _fold = {
    'İ': 'i',
    'I': 'i', // Türkçe'de I→ı→i
    'ı': 'i',
    'Ç': 'c',
    'ç': 'c',
    'Ğ': 'g',
    'ğ': 'g',
    'Ö': 'o',
    'ö': 'o',
    'Ş': 's',
    'ş': 's',
    'Ü': 'u',
    'ü': 'u',
    'Â': 'a',
    'â': 'a',
    'Î': 'i',
    'î': 'i',
    'Û': 'u',
    'û': 'u',
  };

  /// Karşılaştırma için katlanmış metin (küçük harf, ASCII, kenar boşluğu yok).
  static String normalize(String text) {
    final b = StringBuffer();
    for (final ch in text.trim().split('')) {
      b.write(_fold[ch] ?? ch.toLowerCase());
    }
    return b.toString();
  }

  /// [haystack], [query]'yi (normalize edilmiş) içeriyor mu.
  static bool matches(String haystack, String query) =>
      normalize(haystack).contains(normalize(query));
}
