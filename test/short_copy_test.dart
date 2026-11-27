import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/password_reset_pages.dart';
import 'package:bende_var/features/auth/view/signup_done_page.dart';
import 'package:bende_var/features/auth/view/signup_expired_page.dart';
import 'package:bende_var/features/auth/view/signup_name_page.dart';
import 'package:bende_var/features/auth/view/signup_page.dart';
import 'package:bende_var/features/auth/view/signup_sent_page.dart';
import 'package:bende_var/features/auth/view/login_page.dart';
import 'package:bende_var/features/auth/view/welcome_page.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

/// Kapsamdaki tüm giriş/kayıt ekranları.
final _pages = <String, Widget>{
  'welcome': const WelcomePage(),
  'login': const LoginPage(),
  'signup': const SignupPage(),
  'sent': const SignupSentPage(),
  'name': const SignupNamePage(),
  'expired': const SignupExpiredPage(),
  'done': const SignupDonePage(),
  'forgot': const ForgotPasswordPage(),
  'resetSent': const ResetSentPage(),
  'resetNew': const ResetNewPasswordPage(),
};

AuthViewModel _vm() => AuthViewModel(
  MockAuthRepository(verifyAfter: const Duration(hours: 1)),
  communities: MockCommunityRepository(),
  schoolLookupDelay: Duration.zero,
)..setSignupEmail('ad.soyad@std.yildiz.edu.tr');

void main() {
  setUpAll(initTestEnv);

  test('Bilgilendirme metinleri tek kısa cümle (TR ve EN)', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      final infos = <String>[
        l.nameSubtitle,
        l.forgotSubtitle,
        l.sentInstruction,
        l.resetSentInstruction,
        l.doneSlogan,
        l.errorEmailNotEdu,
        l.errorAccountNotFound,
        l.errorPasswordWrong,
        l.errorTooManyAttempts,
        l.errorEmailInUse,
        l.errorTermsRequired,
        l.errorPasswordWeak,
        l.signupPasswordRule,
        l.emailAsciiHint,
        l.notVerifiedYet,
        l.passwordUpdated,
        l.resetExpired,
      ];
      for (final s in infos) {
        // En fazla bir cümle sonu (doğrulanmamış kutusu hariç: ne oldu + eylem).
        final ends = RegExp(r'[.!?](\s|$)').allMatches(s).length;
        expect(ends, lessThanOrEqualTo(1), reason: '$locale: $s');
        expect(s.length, lessThanOrEqualTo(60), reason: '$locale: $s');
      }
      expect(
        l.errorNotVerified.length,
        lessThanOrEqualTo(70),
        reason: '$locale doğrulanmamış kutusu',
      );
      // Şartlar onay satırı kısa (tek satır hedefi).
      final terms =
          l.termsLead + l.termsLink + l.termsMid + l.privacyLink + l.termsTail;
      expect(terms.length, lessThanOrEqualTo(40), reason: '$locale: $terms');
    }
  });

  for (final locale in [const Locale('tr'), const Locale('en')]) {
    testWidgets(
      'Şartlar onay satırı tek satır (360 dp, ${locale.languageCode})',
      (tester) async {
        useAndroidScreen(tester);
        tester.view.physicalSize = const Size(720, 1600);
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: _vm(),
            child: wrap(const SignupPage(), locale: locale),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        final rich = find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains(
                locale.languageCode == 'tr' ? 'Şartları' : 'Terms',
              ),
        );
        expect(rich, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(rich);
        final lines = paragraph
            .getBoxesForSelection(
              TextSelection(
                baseOffset: 0,
                extentOffset: paragraph.text.toPlainText().length,
              ),
            )
            .map((b) => b.top.round())
            .toSet();
        expect(lines.length, 1, reason: paragraph.text.toPlainText());
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test('Kurum dışı e-posta metni "edu.tr" biçiminde (nokta yok)', () async {
    final tr = await AppLocalizations.delegate.load(const Locale('tr'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(tr.errorEmailNotEdu, 'Okul e-postanı kullan (edu.tr).');
    expect(en.errorEmailNotEdu, 'Use your school email (edu.tr).');
    for (final l in [tr, en]) {
      expect(l.errorEmailNotEdu, isNot(contains('.edu.tr')));
    }
  });

  testWidgets('Kaldırılan cümleler ekranlarda yok', (tester) async {
    useAndroidScreen(tester);
    for (final entry in _pages.entries) {
      final vm = _vm();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(value: vm, child: wrap(entry.value)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      for (final gone in [
        'Kurum e-postan ve şifrenle devam et.',
        'Topluluğun e-posta uzantısından bulunur.',
        'Doğrulama bağlantısını şu adrese gönderdik:',
        '24 saat',
        'Gerekirse düzenleyebilirsin',
        'kampüsün seni bekliyor',
      ]) {
        expect(find.textContaining(gone), findsNothing, reason: entry.key);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  for (final (w, h) in [(360.0, 800.0), (412.0, 917.0)]) {
    for (final scale in [1.3, 1.5, 2.0]) {
      for (final locale in [const Locale('tr'), const Locale('en')]) {
        testWidgets(
          'Giriş/kayıt ekranları taşmaz: ${w.toInt()}×${h.toInt()} ×$scale '
          '${locale.languageCode}',
          (tester) async {
            useAndroidScreen(tester);
            tester.view.physicalSize = Size(w * 2, h * 2);
            tester.view.padding = const FakeViewPadding(top: 64, bottom: 96);
            tester.view.viewPadding = const FakeViewPadding(
              top: 64,
              bottom: 96,
            );
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            for (final entry in _pages.entries) {
              final vm = _vm();
              await tester.pumpWidget(
                ChangeNotifierProvider.value(
                  value: vm,
                  child: wrap(entry.value, locale: locale),
                ),
              );
              await tester.pump(const Duration(milliseconds: 300));
              await tester.pump(const Duration(seconds: 3));
              expect(tester.takeException(), isNull, reason: entry.key);
            }
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
