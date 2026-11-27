import 'package:bende_var/core/utils/validators.dart';
import 'package:bende_var/app/app.dart';
import 'package:bende_var/app/di.dart';
import 'package:bende_var/app/locale_controller.dart';
import 'package:bende_var/app/theme_controller.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/repositories/repositories.dart';
import 'package:bende_var/features/auth/view/password_reset_pages.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

AuthViewModel _vm({Duration verifyAfter = Duration.zero}) =>
    AuthViewModel(MockAuthRepository(verifyAfter: verifyAfter));

void main() {
  setUpAll(initTestEnv);

  group('Şifre sıfırlama ViewModel', () {
    test('geçersiz e-posta bağlantı göndermez', () async {
      final vm = _vm()..setResetEmail('ad@gmail.com');
      expect(await vm.sendReset(), isFalse);
      expect(vm.resetEmailError, EmailError.notEdu);
    });

    test('girişte yazılan e-posta 1.05\'e hazır gelir', () {
      final vm = _vm()..setEmail('eda@std.yildiz.edu.tr');
      vm.startReset();
      expect(vm.resetEmail, 'eda@std.yildiz.edu.tr');
    });

    test(
      'bağlantı → doğrulandı → yeni şifre ile giriş; kilit de açılır',
      () async {
        final vm = _vm()
          ..setEmail('eda@std.yildiz.edu.tr')
          ..setPassword('yanlis');
        for (var i = 0; i < 4; i++) {
          await vm.signIn();
        }
        expect(vm.failure, AuthFailure.tooManyAttempts);

        vm.startReset();
        expect(await vm.sendReset(), isTrue);
        expect(await vm.checkReset(), VerificationStatus.verified);

        vm.setNewPassword('abc');
        vm.setConfirmPassword('abc');
        expect(await vm.savePassword(), isFalse);
        expect(vm.newPasswordError, NewPasswordError.weak);

        vm.setNewPassword('yeniSifre9');
        vm.setConfirmPassword('baska1234');
        expect(await vm.savePassword(), isFalse);
        expect(vm.passwordMismatch, isTrue);

        vm.setConfirmPassword('yeniSifre9');
        expect(await vm.savePassword(), isTrue);

        vm.setPassword('sifre123'); // eski şifre artık geçmez
        expect(await vm.signIn(), isFalse);
        expect(vm.failure, AuthFailure.wrongPassword);
        vm.setPassword('yeniSifre9');
        expect(await vm.signIn(), isTrue);
      },
    );

    test(
      'kayıtsız e-postaya bağlantı gitmez ama hata da sızdırılmaz',
      () async {
        final vm = _vm()..setResetEmail('yok@std.yildiz.edu.tr');
        expect(await vm.sendReset(), isTrue);
        expect(await vm.checkReset(), VerificationStatus.pending);
      },
    );

    test('süresi dolan bağlantı expired verir', () async {
      final vm = AuthViewModel(MockAuthRepository(verifyAfter: Duration.zero))
        ..setResetEmail('suredoldu@yildiz.edu.tr');
      // Hesap yok → pending; kayıtlı hesapla denemek için kayıt aç.
      vm
        ..setSignupEmail('suredoldu@yildiz.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      await vm.signUp();
      await vm.sendReset();
      expect(await vm.checkReset(), VerificationStatus.expired);
    });
  });

  testWidgets('Şifre sıfırlama akışı: giriş → 1.05 → 1.06 → 1.07 → giriş', (
    tester,
  ) async {
    useAndroidScreen(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localeCtrl = LocaleController(prefs);
    await localeCtrl.setChoice(LocaleChoice.tr);
    await tester.pumpWidget(
      BendeVarApp(
        deps: AppDependencies(
          auth: MockAuthRepository(verifyAfter: Duration.zero),
        ),
        themeController: ThemeController(prefs),
        localeController: localeCtrl,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giriş yap').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Şifremi unuttum'));
    await tester.pumpAndSettle();
    expect(find.text('Şifreni mi unuttun?'), findsOneWidget);

    // Boş e-posta: hata.
    await tester.tap(find.text('Bağlantı gönder'));
    await tester.pumpAndSettle();
    expect(find.text('E-posta adresini gir.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('reset-email-field')),
      'Eda@Std.Yıldız.edu.tr',
    );
    await tester.tap(find.text('Bağlantı gönder'));
    // 1.06: geri sayım zamanlayıcısı var, settle beklenmez.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Bağlantıyı gönderdik'), findsOneWidget);
    expect(find.text('eda@std.yildiz.edu.tr'), findsOneWidget);

    await tester.tap(find.text('Bağlantıya tıkladım'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Yeni şifre belirle'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('new-password-field')),
      'yeniSifre9',
    );
    await tester.enterText(
      find.byKey(const Key('confirm-password-field')),
      'baska1234',
    );
    // Her alanın kendi göz ikonu: biri açılınca diğeri kapalı kalır.
    bool obscured(String key) => tester
        .widget<TextField>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(TextField),
          ),
        )
        .obscureText;
    expect(find.byTooltip('Şifreyi göster'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Şifreyi göster').first);
    await tester.pump();
    expect(obscured('new-password-field'), isFalse);
    expect(obscured('confirm-password-field'), isTrue);
    await tester.tap(find.byTooltip('Şifreyi göster').last);
    await tester.pump();
    expect(obscured('confirm-password-field'), isFalse);
    await tester.tap(find.byTooltip('Şifreyi gizle').first);
    await tester.pump();
    expect(obscured('new-password-field'), isTrue);
    expect(obscured('confirm-password-field'), isFalse);

    await tester.tap(find.text('Şifreyi kaydet'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('confirm-password-field')),
      'yeniSifre9',
    );
    await tester.tap(find.text('Şifreyi kaydet'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    expect(
      find.text('Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.'),
      findsOneWidget,
    );
  });

  for (final (name, w, h, scale) in [
    ('320×568', 320.0, 568.0, 1.0),
    ('360×640 büyük yazı', 360.0, 640.0, 1.6),
  ]) {
    testWidgets('Sıfırlama ekranları taşmaz: $name', (tester) async {
      useAndroidScreen(tester);
      tester.view.physicalSize = Size(w * 2, h * 2);
      tester.view.padding = const FakeViewPadding(bottom: 96, top: 96);
      tester.view.viewPadding = const FakeViewPadding(bottom: 96, top: 96);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final page in const [
        ForgotPasswordPage(),
        ResetSentPage(),
        ResetNewPasswordPage(),
      ]) {
        final vm = _vm()..setResetEmail('eda@std.yildiz.edu.tr');
        await tester.pumpWidget(
          ChangeNotifierProvider.value(value: vm, child: wrap(page)),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
