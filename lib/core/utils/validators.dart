/// Doğrulayıcılar; hata türü döner, metni UI ARB'den çevirir.
enum EmailError { empty, notEdu }

enum PasswordError { empty }

enum RequiredError { empty }

class Validators {
  const Validators._();

  /// Kurum e-postası `.edu.tr` ile bitmeli.
  static EmailError? email(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    if (v.isEmpty) return EmailError.empty;
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.edu\.tr$');
    if (!pattern.hasMatch(v)) return EmailError.notEdu;
    return null;
  }

  static PasswordError? password(String? value) {
    if ((value ?? '').isEmpty) return PasswordError.empty;
    return null;
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
