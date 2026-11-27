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

  test(
    'Validators.schoolId: boun, std.bogazici, ogr.msgsu, rakamlı e-posta',
    () {
      expect(Validators.schoolId('ali@boun.edu.tr'), 'boun');
      expect(Validators.schoolId('ali@std.bogazici.edu.tr'), 'bogazici');
      expect(Validators.schoolId('ayse@ogr.msgsu.edu.tr'), 'msgsu');
      // Rakamlı e-posta: yerel kısımdaki rakam okul kimliğini etkilemez.
      expect(Validators.schoolId('ali123@boun.edu.tr'), 'boun');
      expect(Validators.schoolId('2021.ali@ogr.msgsu.edu.tr'), 'msgsu');
      // Büyük harf/boşluk: kimlik küçük harfe çevrilir.
      expect(Validators.schoolId(' ALI@BOUN.EDU.TR '), 'boun');
    },
  );

  test('Validators.schoolId: .edu.tr sınırı (yalnızca sonek sayılır)', () {
    // .edu.tr e-postanın SONUNDA olmalı; ortada/yanında geçmesi yetmez.
    expect(Validators.schoolId('a@boun.edu.tr.com'), isNull);
    expect(Validators.schoolId('a@boun.edu.trx'), isNull);
    expect(Validators.schoolId('a@bounedu.tr'), isNull);
    expect(Validators.schoolId('a@edu.tr'), isNull); // okul kimliği yok
    expect(Validators.schoolId('a@boun.edu'), isNull);
    expect(Validators.schoolId('a@@boun.edu.tr'), isNull);
    expect(Validators.schoolId('a b@boun.edu.tr'), isNull);
    // Aynı okulun alt alan adları aynı kimliğe düşer.
    expect(
      Validators.schoolId('a@std.bogazici.edu.tr'),
      Validators.schoolId('b@bogazici.edu.tr'),
    );
  });
}
