import 'package:bende_var/core/utils/validators.dart';
import 'package:bende_var/app/app.dart';
import 'package:bende_var/app/di.dart';
import 'package:bende_var/app/locale_controller.dart';
import 'package:bende_var/app/theme_controller.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/repositories/repositories.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/view/legal_page.dart';
import 'package:bende_var/features/auth/view/signup_expired_page.dart';
import 'package:bende_var/features/auth/view/signup_name_page.dart';
import 'package:bende_var/features/auth/view/signup_page.dart';
import 'package:bende_var/features/auth/view/signup_sent_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

AuthViewModel _vm({Duration verifyAfter = Duration.zero}) => AuthViewModel(
  MockAuthRepository(verifyAfter: verifyAfter),
  communities: MockCommunityRepository(),
);

void main() {
  setUpAll(initTestEnv);

  group('Kayıt ViewModel', () {
    test(
      'boş form / zayıf şifre / şartlar kabul edilmeden kayıt olmaz',
      () async {
        final vm = _vm();
        expect(await vm.signUp(), isFalse);
        expect(vm.signupEmailError, EmailError.empty);
        vm.setSignupEmail('ad.soyad@std.yildiz.edu.tr');
        vm.setSignupPassword('abc');
        expect(await vm.signUp(), isFalse);
        expect(vm.signupPasswordError, NewPasswordError.weak);
        vm.setSignupPassword('sifre123');
        expect(await vm.signUp(), isFalse);
        expect(vm.termsError, isTrue);
        vm.setTermsAccepted(true);
        expect(await vm.signUp(), isTrue);
      },
    );

    test('1.08a: kurum dışı e-posta reddedilir', () async {
      final vm = _vm()
        ..setSignupEmail('ad@gmail.com')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      expect(await vm.signUp(), isFalse);
      expect(vm.signupEmailError, EmailError.notEdu);
    });

    test('kayıtlı e-posta emailInUse verir', () async {
      final vm = _vm()
        ..setSignupEmail('eda@std.yildiz.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      expect(await vm.signUp(), isFalse);
      expect(vm.signupFailure, AuthFailure.emailInUse);
    });

    test('std.yildiz ve yildiz aynı topluluğu bulur', () async {
      final vm = _vm();
      vm.setSignupEmail('a@std.yildiz.edu.tr');
      await Future<void>.delayed(Duration.zero);
      expect(vm.schoolCommunity?.name, 'Yıldız Teknik Üniversitesi');
      vm.setSignupEmail('a@yildiz.edu.tr');
      await Future<void>.delayed(Duration.zero);
      expect(vm.schoolCommunity?.name, 'Yıldız Teknik Üniversitesi');
      vm.setSignupEmail('a@std.yeni.edu.tr');
      await Future<void>.delayed(Duration.zero);
      expect(vm.schoolCommunity, isNull);
      expect(vm.schoolLookedUp, isTrue);
    });

    test('doğrulama: bekliyor → doğrulandı; ad e-postadan hazır gelir; '
        'yeni okulda topluluk açılır', () async {
      final vm = _vm(verifyAfter: const Duration(hours: 1))
        ..setSignupEmail('ayse.kaya@std.yeni.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      expect(await vm.signUp(), isTrue);
      expect(await vm.checkVerification(), VerificationStatus.pending);
      expect(vm.suggestedName, 'Ayse Kaya');

      final fast = _vm()
        ..setSignupEmail('ayse.kaya@std.yeni.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      await fast.signUp();
      expect(await fast.checkVerification(), VerificationStatus.verified);
      expect(await fast.completeSignUp('Ayşe Kaya'), isTrue);
      expect(fast.isSignedIn, isTrue);
      expect(fast.user?.shortName, 'Ayşe K.');
      expect(fast.user?.community.name, 'Yeni');
    });

    test('1.12: süresi dolan bağlantı expired verir', () async {
      final vm = _vm()
        ..setSignupEmail('suredoldu@yildiz.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      await vm.signUp();
      expect(await vm.checkVerification(), VerificationStatus.expired);
    });

    test('Tekrar gönder bekleme süresi', () async {
      final vm = _vm()
        ..setSignupEmail('x@yildiz.edu.tr')
        ..setSignupPassword('sifre123')
        ..setTermsAccepted(true);
      await vm.signUp();
      expect(vm.resendRemaining(), inInclusiveRange(44, 45));
      expect(
        vm.resendRemaining(DateTime.now().add(const Duration(seconds: 50))),
        0,
      );
    });
  });

  testWidgets('Kayıt akışı: form → bağlantı gönderildi → ad → ana sayfa', (
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

    await tester.tap(find.text('Kayıt ol'));
    await tester.pumpAndSettle();
    expect(find.text('Okul e-postanla başla'), findsOneWidget);

    // Türkçe karakter ve büyük harf düzeltmesi, sabit .edu.tr soneki.
    await tester.enterText(
      find.byKey(const Key('signup-email-field')),
      'Şule.Çelik@Std.Yıldız.edu.tr',
    );
    await tester.pumpAndSettle();
    final field = tester.widget<TextFormField>(
      find.byKey(const Key('signup-email-field')),
    );
    expect(field.controller!.text, 'sule.celik@std.yildiz.edu.tr');
    expect(find.text('Yıldız Teknik Üniversitesi'), findsOneWidget);

    // Şartlar kabul edilmeden kayıt olunmaz.
    await tester.enterText(
      find.byKey(const Key('signup-password-field')),
      'sifre123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Kayıt ol'));
    await tester.pumpAndSettle();
    expect(
      find.text('Devam etmek için şartları kabul etmelisin.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('terms-checkbox')));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Kayıt ol'));
    // 1.09: geri sayım zamanlayıcısı olduğu için settle beklenmez.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Bağlantıyı gönderdik'), findsOneWidget);
    expect(find.text('sule.celik@std.yildiz.edu.tr'), findsOneWidget);
    expect(find.textContaining('Tekrar gönder (0:4'), findsOneWidget);

    await tester.tap(find.text('Bağlantıya tıkladım'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Adın ne?'), findsOneWidget);
    expect(find.text('Sule Celik'), findsOneWidget);

    await tester.tap(find.text('Tamamla'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('İlanlar · '), findsOneWidget);
  });

  for (final (name, w, h, scale) in [
    ('412×915', 412.0, 915.0, 1.0),
    ('320×568', 320.0, 568.0, 1.0),
    ('360×640 büyük yazı', 360.0, 640.0, 1.6),
  ]) {
    testWidgets('Kayıt ekranları taşmaz ve kesilmez: $name', (tester) async {
      useAndroidScreen(tester);
      tester.view.physicalSize = Size(w * 2, h * 2);
      tester.view.padding = const FakeViewPadding(bottom: 96, top: 96);
      tester.view.viewPadding = const FakeViewPadding(bottom: 96, top: 96);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      Future<void> show(Widget page) async {
        final vm = _vm();
        vm.setSignupEmail('ad.soyad@std.yildiz.edu.tr');
        await tester.pumpWidget(
          ChangeNotifierProvider.value(value: vm, child: wrap(page)),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }

      await show(const SignupPage());
      expect(
        tester.getRect(find.widgetWithText(ElevatedButton, 'Kayıt ol')).bottom,
        lessThanOrEqualTo(h - 48),
      );
      await show(const SignupSentPage());
      expect(
        tester.getRect(find.text('Bağlantıya tıkladım')).bottom,
        lessThanOrEqualTo(h - 48),
      );
      await show(const SignupNamePage());
      await show(const SignupExpiredPage());
      await show(const LegalPage(kind: LegalKind.terms));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
