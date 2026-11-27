/// Doğrulayıcılar; hata türü döner, metni UI ARB'den çevirir.
enum EmailError { empty, notEdu }

enum PasswordError { empty }

/// Yeni şifre (kayıt): en az 8 karakter, en az bir harf ve bir rakam.
enum NewPasswordError { empty, weak }

enum RequiredError { empty }

class Validators {
  const Validators._();

  /// Kişisel e-posta sağlayıcıları: alan sabit `.edu.tr` eklediği için
  /// "gmail.edu.tr" gibi adresler geçmesin diye okul kimliği olarak reddedilir.
  static const Set<String> personalProviders = {
    'gmail',
    'hotmail',
    'outlook',
    'yahoo',
    'icloud',
    'yandex',
    'proton',
    'protonmail',
    'live',
    'msn',
  };

  /// Okul kimliği kişisel e-posta sağlayıcısı mı (gmail, hotmail...).
  static bool isPersonalProvider(String? email) =>
      personalProviders.contains(schoolId(email));

  /// Kurum e-postası `.edu.tr` ile bitmeli; kişisel sağlayıcı adı olmamalı.
  /// İkisi de aynı hata durumudur ([EmailError.notEdu]: "kurum dışı e-posta").
  static EmailError? email(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    if (v.isEmpty) return EmailError.empty;
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.edu\.tr$');
    if (!pattern.hasMatch(v)) return EmailError.notEdu;
    if (isPersonalProvider(v)) return EmailError.notEdu;
    return null;
  }

  /// Okul kartı için en az bu kadar harfli okul kimliği gerekir.
  static const int minSchoolIdLength = 3;

  /// Okul kimliği: `.edu.tr`'den önceki son kelime
  /// (`std.yildiz.edu.tr` ve `yildiz.edu.tr` → `yildiz`). Geçersizse null.
  static String? schoolId(String? email) {
    final v = (email ?? '').trim().toLowerCase();
    final m = RegExp(r'^[^\s@]+@(?:[^\s@]*\.)?([^\s@.]+)\.edu\.tr$')
        .firstMatch(v);
    return m?.group(1);
  }

  static PasswordError? password(String? value) {
    if ((value ?? '').isEmpty) return PasswordError.empty;
    return null;
  }

  static NewPasswordError? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return NewPasswordError.empty;
    final ok =
        v.length >= 8 &&
        RegExp(r'\p{L}', unicode: true).hasMatch(v) &&
        RegExp(r'\d').hasMatch(v);
    return ok ? null : NewPasswordError.weak;
  }

  /// `ad.soyad@...` → "Ad Soyad" (kayıttaki ad önerisi).
  static String nameFromEmail(String? email) {
    final local = (email ?? '').split('@').first;
    final words = local
        .split(RegExp(r'[._\-+\d]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase());
    return words.join(' ');
  }

  static RequiredError? requiredText(String? value) {
    if ((value ?? '').trim().isEmpty) return RequiredError.empty;
    return null;
  }

  /// Ücretli ise fiyat > 0 olmalı.
  static bool validPrice(String? value) {
    final n = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return n != null && n > 0;
  }
}
