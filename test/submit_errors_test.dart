import 'package:bende_var/core/widgets/shake_on_error.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/password_reset_pages.dart';
import 'package:bende_var/features/auth/view/signup_page.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

const _rule = 'En az 8 karakter, bir harf ve bir rakam.';

AuthViewModel _vm() => AuthViewModel(
  MockAuthRepository(verifyAfter: const Duration(hours: 1)),
  communities: MockCommunityRepository(),
  schoolLookupDelay: Duration.zero,
);

/// Animasyonlar açık (titreme görülsün); sürekli yıldız animasyonu olduğu
/// için settle yerine kısa pump'lar.
Future<AuthViewModel> _open(WidgetTester tester, Widget page) async {
  useAndroidScreen(tester);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures();
  final vm = _vm();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: vm, child: wrap(page)),
  );
  await tester.pump(const Duration(seconds: 4));
  return vm;
}

/// Alanın titreme ötelemesi (0 = sabit).
double _shake(WidgetTester tester, Key fieldKey) {
  final shaker = find.ancestor(
    of: find.byKey(fieldKey),
    matching: find.byType(ShakeOnError),
  );
  final t = tester.widget<Transform>(
    find.descendant(of: shaker, matching: find.byType(Transform)).first,
  );
  return t.transform.getTranslation().x;
}

Color? _fieldBorder(WidgetTester tester, Key fieldKey) {
  final field = tester.widget<TextField>(
    find.descendant(of: find.byKey(fieldKey), matching: find.byType(TextField)),
  );
  return field.decoration?.enabledBorder?.borderSide.color;
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('Kayıt: yazarken ve odak kaybında hata/titreme yok, kural nötr', (
    tester,
  ) async {
    await _open(tester, const SignupPage());
    const pw = Key('signup-password-field');
    final neutral = _fieldBorder(tester, pw);
    await tester.tap(find.byKey(pw));
    for (final text in ['a', 'ab', 'abc1']) {
      await tester.enterText(find.byKey(pw), text);
      await tester.pump(const Duration(milliseconds: 50));
      expect(_shake(tester, pw), 0, reason: text);
      expect(_fieldBorder(tester, pw), neutral, reason: text);
      expect(find.text(_rule), findsOneWidget); // nötr yardımcı metin
    }
    // Odak kaybı (e-postaya geç): yine hata yok.
    await tester.tap(find.byKey(const Key('signup-email-field')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_fieldBorder(tester, pw), neutral);
    await tester.pumpWidget(const SizedBox());
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  testWidgets('Kayıt: Kayıt ol\'dan sonra hata + titreme; düzeltince hemen '
      'temizlenir, yazarken geri gelmez', (tester) async {
    final vm = await _open(tester, const SignupPage());
    const pw = Key('signup-password-field');
    const email = Key('signup-email-field');
    final neutral = _fieldBorder(tester, pw);
    await tester.enterText(find.byKey(email), 'ali@yildiz.edu.tr');
    await tester.enterText(find.byKey(pw), 'abc');
    await tester.pump();

    await vm.signUp(); // Kayıt ol
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(vm.signupPasswordError, isNotNull);
    expect(_fieldBorder(tester, pw), isNot(neutral)); // hata rengi
    expect(_shake(tester, pw).abs(), greaterThan(0)); // titrer
    expect(vm.signupEmailError, isNull); // e-posta geçerli: hata yok
    await tester.pump(const Duration(seconds: 1));

    // Hâlâ geçersiz yazarken: hata durur ama yeniden titremez.
    await tester.enterText(find.byKey(pw), 'abcd1');
    await tester.pump(const Duration(milliseconds: 40));
    expect(_shake(tester, pw), 0);
    expect(vm.signupPasswordError, isNotNull);

    // Kural sağlanınca hemen temizlenir.
    await tester.enterText(find.byKey(pw), 'abcdefg1');
    await tester.pump();
    expect(vm.signupPasswordError, isNull);
    expect(_fieldBorder(tester, pw), neutral);

    // Yeniden bozulsa da yazarken hata gelmez (bir sonraki gönderime kadar).
    await tester.enterText(find.byKey(pw), 'abc');
    await tester.pump(const Duration(milliseconds: 40));
    expect(vm.signupPasswordError, isNull);
    expect(_shake(tester, pw), 0);
    await tester.pumpWidget(const SizedBox());
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  test(
    'Kayıt: e-posta hatası yalnızca gönderimde, düzelince temizlenir',
    () async {
      final vm = _vm()..setSignupEmail('ali@gmail.edu.tr');
      vm.signupEmailBlurred(); // odak kaybı: hata yok
      expect(vm.signupEmailError, isNull);
      expect(await vm.signUp(), isFalse);
      expect(vm.signupEmailError, isNotNull);
      final seq = vm.signupErrorSeq;
      vm.setSignupEmail('ali@yildiz.edu.tr');
      expect(vm.signupEmailError, isNull);
      vm.setSignupEmail('ali@hotmail.edu.tr'); // yazarken yeniden bozuldu
      expect(vm.signupEmailError, isNull);
      await vm.signUp();
      expect(vm.signupEmailError, isNotNull);
      expect(vm.signupErrorSeq, greaterThan(seq)); // her gönderim yeni titreme
    },
  );

  test(
    'Yeni şifre: yazarken hata yok; kaydette hata; düzelince temizlenir',
    () async {
      final vm = _vm();
      vm.setNewPassword('abc');
      vm.setConfirmPassword('x');
      expect(vm.newPasswordError, isNull);
      expect(vm.passwordMismatch, isFalse);

      expect(await vm.savePassword(), isFalse);
      expect(vm.newPasswordError, isNotNull);
      expect(vm.passwordMismatch, isFalse); // önce yeni şifre kuralı
      final seq = vm.newErrorSeq;

      vm.setNewPassword('abcdefg1'); // kural sağlandı
      expect(vm.newPasswordError, isNull);
      expect(vm.passwordMismatch, isFalse); // tekrar alanı yazarken hata yok

      expect(await vm.savePassword(), isFalse); // eşleşmiyor
      expect(vm.passwordMismatch, isTrue);
      expect(vm.newErrorSeq, greaterThan(seq));
      vm.setConfirmPassword('abcdefg1'); // eşleşti
      expect(vm.passwordMismatch, isFalse);
    },
  );

  testWidgets('Yeni şifre ekranı: yazarken titreme ve hata rengi yok', (
    tester,
  ) async {
    await _open(tester, const ResetNewPasswordPage());
    const pw = Key('new-password-field');
    final neutral = _fieldBorder(tester, pw);
    await tester.enterText(find.byKey(pw), 'ab');
    await tester.pump(const Duration(milliseconds: 40));
    expect(_shake(tester, pw), 0);
    expect(_fieldBorder(tester, pw), neutral);
    expect(find.text(_rule), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });
}
