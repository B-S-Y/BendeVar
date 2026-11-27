import 'package:bende_var/core/utils/validators.dart';
import 'package:bende_var/core/widgets/institution_email_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Klavyeden tek tek yazmayı taklit eder.
void type(InstitutionEmailController c, String chars) {
  for (final ch in chars.split('')) {
    final sel = c.selection.isValid ? c.selection.baseOffset : c.text.length;
    final t = c.text.replaceRange(sel, sel, ch);
    c.value = TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: sel + 1),
    );
  }
}

void main() {
  test('@ yazılınca .edu.tr sabit sonek gelir, imleç arada kalır', () {
    final c = InstitutionEmailController();
    type(c, 'ad.soyad@');
    expect(c.text, 'ad.soyad@.edu.tr');
    expect(c.selection.baseOffset, 'ad.soyad@'.length);
    type(c, 'std.yildiz');
    expect(c.text, 'ad.soyad@std.yildiz.edu.tr');
    expect(c.selection.baseOffset, 'ad.soyad@std.yildiz'.length);
    expect(Validators.email(c.text), isNull);
  });

  test('kullanıcı .edu.tr yazarsa fazlalık temizlenir', () {
    final c = InstitutionEmailController();
    type(c, 'ad@std.yildiz.edu.tr');
    expect(c.text, 'ad@std.yildiz.edu.tr');
  });

  test('tam e-posta yapıştırılınca fazlalık temizlenir', () {
    final c = InstitutionEmailController();
    c.value = const TextEditingValue(text: 'ad.soyad@std.yildiz.edu.tr');
    expect(c.text, 'ad.soyad@std.yildiz.edu.tr');
    expect(c.isForeign, isFalse);
  });

  test(
    'kurum dışı e-posta yapıştırılırsa olduğu gibi kalır ve geçersizdir',
    () {
      final c = InstitutionEmailController();
      c.value = const TextEditingValue(text: 'ad.soyad@gmail.com');
      expect(c.text, 'ad.soyad@gmail.com');
      expect(c.isForeign, isTrue);
      expect(Validators.email(c.text), EmailError.notEdu);
    },
  );

  test('@ silinince sonek de gider', () {
    final c = InstitutionEmailController();
    type(c, 'ad@yildiz');
    c.value = const TextEditingValue(
      text: 'adyildiz.edu.tr',
      selection: TextSelection.collapsed(offset: 2),
    );
    expect(c.text, 'adyildiz');
  });

  test('Türkçe karakterler ASCII karşılığına çevrilir, büyük harf küçülür', () {
    final c = InstitutionEmailController();
    type(c, 'ŞÖYLE.Çağrı@Ğüzel');
    expect(c.text, 'soyle.cagri@guzel.edu.tr');
    type(c, 'İıt');
    expect(c.text, 'soyle.cagri@guzeliit.edu.tr');
    expect(Validators.email(c.text), isNull);
  });

  test('Validators.schoolId: son kelime okul kimliğidir', () {
    expect(Validators.schoolId('elif@std.yildiz.edu.tr'), 'yildiz');
    expect(Validators.schoolId('mert@yildiz.edu.tr'), 'yildiz');
    expect(Validators.schoolId('a@gmail.com'), isNull);
    expect(Validators.schoolId('a@.edu.tr'), isNull);
  });
}
