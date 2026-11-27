import 'package:bende_var/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('boş e-posta reddedilir', () {
      expect(Validators.email(''), EmailError.empty);
      expect(Validators.email('   '), EmailError.empty);
      expect(Validators.email(null), EmailError.empty);
    });

    test('.edu.tr ile bitmeyen e-posta reddedilir', () {
      expect(Validators.email('ad@gmail.com'), EmailError.notEdu);
      expect(Validators.email('ad@okul.edu'), EmailError.notEdu);
      expect(Validators.email('ad@okul.com.tr'), EmailError.notEdu);
      expect(Validators.email('okul.edu.tr'), EmailError.notEdu);
    });

    test('.edu.tr ile biten e-posta kabul edilir', () {
      expect(Validators.email('ad.soyad@okul.edu.tr'), isNull);
      expect(Validators.email('ELIF@std.yildiz.edu.tr'), isNull);
      expect(Validators.email(' ad@okul.edu.tr '), isNull);
    });
  });

  test('Validators.password boşu reddeder', () {
    expect(Validators.password(''), PasswordError.empty);
    expect(Validators.password(null), PasswordError.empty);
    expect(Validators.password('x'), isNull);
  });

  test('Validators.requiredText', () {
    expect(Validators.requiredText('  '), RequiredError.empty);
    expect(Validators.requiredText('Yoga matı'), isNull);
  });

  test('Validators.validPrice', () {
    expect(Validators.validPrice('30'), isTrue);
    expect(Validators.validPrice('30,5'), isTrue);
    expect(Validators.validPrice('0'), isFalse);
    expect(Validators.validPrice('abc'), isFalse);
    expect(Validators.validPrice(''), isFalse);
  });

  test('Validators.nameFromEmail', () {
    expect(
      Validators.nameFromEmail('elif.yildirim@std.yildiz.edu.tr'),
      'Elif Yildirim',
    );
    expect(Validators.nameFromEmail('mert_kaya2@yildiz.edu.tr'), 'Mert Kaya');
    expect(Validators.nameFromEmail('a.b-c+d@okul.edu.tr'), 'A B C D');
    expect(Validators.nameFromEmail('ALI@okul.edu.tr'), 'Ali');
    expect(Validators.nameFromEmail('sule'), 'Sule');
    expect(Validators.nameFromEmail('123@okul.edu.tr'), '');
    expect(Validators.nameFromEmail(''), '');
    expect(Validators.nameFromEmail(null), '');
  });
}
