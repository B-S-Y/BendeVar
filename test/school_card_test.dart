import 'package:bende_var/core/utils/validators.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/signup_page.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

const _debounce = Duration(milliseconds: 500);

AuthViewModel _vm({Duration delay = Duration.zero}) => AuthViewModel(
  MockAuthRepository(verifyAfter: Duration.zero),
  communities: MockCommunityRepository(),
  schoolLookupDelay: delay,
);

Future<AuthViewModel> _open(WidgetTester tester) async {
  useAndroidScreen(tester);
  final vm = _vm(delay: _debounce);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: vm, child: wrap(const SignupPage())),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return vm;
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('signup-email-field')), text);
  await tester.pump();
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('1-2 harfli okul kimliğinde kart çıkmaz (yeni@b.edu.tr)', (
    tester,
  ) async {
    await _open(tester);
    await _type(tester, 'yeni@b.edu.tr');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('B'), findsNothing);
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsNothing);
    await _type(tester, 'yeni@bo.edu.tr');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Bo'), findsNothing);
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('bilinen okul: yazarken yok, ~500 ms sonra adıyla çıkar', (
    tester,
  ) async {
    await _open(tester);
    await _type(tester, 'ali@boun.edu.tr');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Boğaziçi Üniversitesi'), findsNothing); // yazılıyor
    await _type(tester, 'ali@std.bogazici.edu.tr');
    await tester.pump(const Duration(milliseconds: 300));
    // Sayaç yeniden başladı: toplam yazma durmadı.
    expect(find.text('Boğaziçi Üniversitesi'), findsNothing);
    await tester.pump(const Duration(milliseconds: 300)); // ~600 ms durdu
    expect(find.text('Boğaziçi Üniversitesi'), findsOneWidget);
    expect(find.text('Okul topluluğuna katılacaksın'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('bilinmeyen okul: not yalnızca odak kaybında gelir', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.byKey(const Key('signup-email-field')));
    await tester.pump();
    await _type(tester, 'ali@yeniokul.edu.tr');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsNothing);
    // Alan odağı kaybolur (şifre alanına geçiş).
    await tester.tap(find.byKey(const Key('signup-password-field')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yeniokul'), findsOneWidget);
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets("bilinmeyen okul: Kayıt ol'a basınca da not gelir", (
    tester,
  ) async {
    final vm = await _open(tester);
    await _type(tester, 'ali@yeniokul.edu.tr');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsNothing);
    await vm.signUp(); // şifre/şart eksik: hatalar ve not görünür
    await tester.pump();
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('kişisel e-posta sağlayıcıları reddedilir (kayıt ve giriş)', () async {
    expect(
      Validators.personalProviders,
      containsAll([
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
      ]),
    );
    for (final p in Validators.personalProviders) {
      expect(Validators.email('ali@$p.edu.tr'), EmailError.notEdu, reason: p);
      expect(Validators.email('ali@mail.$p.edu.tr'), EmailError.notEdu);
      expect(Validators.isPersonalProvider('ali@$p.edu.tr'), isTrue);
    }
    expect(Validators.email('ali@boun.edu.tr'), isNull);
    expect(Validators.email('ali@gmailx.edu.tr'), isNull); // yalnızca tam ad

    // Kayıt: kurum dışı hata durumu, hesap açılmaz, okul kartı yok.
    final su = _vm()
      ..setSignupEmail('ali@gmail.edu.tr')
      ..setSignupPassword('sifre123')
      ..setTermsAccepted(true);
    expect(await su.signUp(), isFalse);
    expect(su.signupEmailError, EmailError.notEdu);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(su.showSchoolCard, isFalse);

    // Giriş: aynı hata.
    final si = _vm()
      ..setEmail('ali@hotmail.edu.tr')
      ..setPassword('sifre123');
    expect(await si.signIn(), isFalse);
    expect(si.emailError, EmailError.notEdu);
  });

  testWidgets('kişisel e-posta alandan çıkınca hata gösterilir', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.byKey(const Key('signup-email-field')));
    await tester.pump();
    await _type(tester, 'ali@gmail.edu.tr');
    await tester.tap(find.byKey(const Key('signup-password-field')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(LucideIcons.circleAlert), findsWidgets);
    expect(find.text('Topluluğun ilk kayıtla açılacak'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
