import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

const _elif = 'elif@std.yildiz.edu.tr';
const _unverified = 'sudem@yildiz.edu.tr';
const _key = MockAuthRepository.rememberKey;

Future<String?> _stored() async =>
    (await SharedPreferences.getInstance()).getString(_key);

void main() {
  setUpAll(initTestEnv);

  group('Beni hatırla · repository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('açıkken giriş hatırlanır, yeni açılışta oturum geri gelir', () async {
      await MockAuthRepository().signIn(_elif, 'sifre123', remember: true);
      expect(await _stored(), _elif);
      final restarted = MockAuthRepository(); // uygulama yeniden açıldı
      expect((await restarted.restoreSession())?.shortName, 'Elif Y.');
      expect(restarted.currentUser, isNotNull);
    });

    test('kapalıyken hatırlanmaz; açılışta oturum yok', () async {
      await MockAuthRepository().signIn(_elif, 'sifre123');
      expect(await _stored(), isNull);
      expect(await MockAuthRepository().restoreSession(), isNull);
    });

    test('kapalı giriş eski hatırlamayı siler', () async {
      final repo = MockAuthRepository();
      await repo.signIn(_elif, 'sifre123', remember: true);
      await repo.signIn(_elif, 'sifre123');
      expect(await _stored(), isNull);
    });

    test('çıkış yapınca hatırlama silinir', () async {
      final repo = MockAuthRepository();
      await repo.signIn(_elif, 'sifre123', remember: true);
      await repo.signOut();
      expect(await _stored(), isNull);
      expect(await MockAuthRepository().restoreSession(), isNull);
    });

    test('doğrulanmamış hesapta hatırlama yapılmaz', () async {
      final repo = MockAuthRepository();
      await expectLater(
        repo.signIn(_unverified, 'sifre123', remember: true),
        throwsA(
          isA<AuthException>().having(
            (e) => e.failure,
            'failure',
            AuthFailure.notVerified,
          ),
        ),
      );
      expect(await _stored(), isNull);
      // Elle yazılmış eski kayıt olsa bile açılışta kullanılmaz ve silinir.
      SharedPreferences.setMockInitialValues({_key: _unverified});
      expect(await MockAuthRepository().restoreSession(), isNull);
      expect(await _stored(), isNull);
    });
  });

  group('Beni hatırla · ekran', () {
    Future<void> login(WidgetTester tester, {required bool remember}) async {
      await tester.tap(find.text('Giriş yap').first);
      await tester.pumpAndSettle();
      expect(find.text('Beni hatırla'), findsOneWidget);
      final box = find.byKey(const Key('remember-checkbox'));
      expect(tester.widget<Checkbox>(box).value, isFalse); // varsayılan boş
      if (remember) {
        await tester.tap(find.text('Beni hatırla'));
        await tester.pump();
        expect(tester.widget<Checkbox>(box).value, isTrue);
      }
      await tester.enterText(find.byKey(const Key('email-field')), _elif);
      await tester.enterText(
        find.byKey(const Key('password-field')),
        'sifre123',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş yap'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.textContaining('İlanlar · '), findsOneWidget);
    }

    testWidgets('açıkken: kapanıp açılınca giriş istemeden Ana Sayfa', (
      tester,
    ) async {
      await pumpApp(tester);
      await login(tester, remember: true);
      final saved = await _stored();
      expect(saved, _elif);

      // Uygulama kapandı, yeniden açıldı (yeni bağımlılıklar, kalıcı veri).
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, prefsValues: {_key: saved!});
      expect(find.textContaining('İlanlar · '), findsOneWidget);
      expect(find.text('Giriş yap'), findsNothing);
      await tester.pump(const Duration(seconds: 1)); // sahte gecikmeler
    });

    testWidgets('kapalıyken: açılışta Karşılama, giriş istenir', (
      tester,
    ) async {
      await pumpApp(tester);
      await login(tester, remember: false);
      expect(await _stored(), isNull);

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester); // kalıcı veri yok
      expect(find.text('Giriş yap'), findsOneWidget);
      expect(find.textContaining('İlanlar · '), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
