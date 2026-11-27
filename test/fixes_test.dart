import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/community_models.dart';
import 'package:bende_var/data/models/models.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

final _marmaraUser = mockAccounts
    .firstWhere((a) => a.user.community.id == mockMarmara.id)
    .user;

class _BrokenRestoreAuth extends MockAuthRepository {
  @override
  Future<AppUser?> restoreSession() async => throw StateError('disk');
}

void main() {
  setUpAll(initTestEnv);

  group('Topluluk üyelikleri kullanıcıya göre', () {
    test('Elif\'in toplulukları Marmara hesabında görünmez', () async {
      final repo = MockCommunityRepository();
      final elif = CommunityViewModel(repo);
      await elif.load(mockUser);
      await elif.join('kamp');
      await elif.create(
        name: 'Okuma Grubu',
        description: '',
        visibility: CommunityVisibility.open,
      );
      expect(elif.mine.map((c) => c.id), containsAll(['ytu', 'kamp']));

      // Aynı oturumda çıkış, Marmara hesabıyla giriş (aynı repo).
      final marmara = CommunityViewModel(repo);
      await marmara.load(_marmaraUser);
      expect(marmara.mine.map((c) => c.id), ['marmara']);
      expect(marmara.mine.single.isSchool, isTrue);
      await marmara.setQuery('kamp');
      expect(marmara.results.single.joined, isFalse);
      await marmara.setQuery('okuma');
      expect(marmara.results.single.isFounder, isFalse);
      // Okula özel YTÜ topluluğu Marmara'ya çıkmaz.
      await marmara.setQuery('yurt');
      expect(marmara.results, isEmpty);

      // Elif geri dönünce kendi üyelikleri yerinde.
      final again = CommunityViewModel(repo);
      await again.load(mockUser);
      expect(again.mine.map((c) => c.id), contains('kamp'));
      expect(again.mine.where((c) => c.isFounder), hasLength(1));
      expect(again.mine.map((c) => c.id), isNot(contains('marmara')));
    });

    test('reset önceki kullanıcının listesini ve aramayı temizler', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      await vm.setQuery('kamp');
      vm.reset();
      expect(vm.mine, isEmpty);
      expect(vm.loaded, isFalse);
      expect(vm.isSearch, isFalse);
    });
  });

  group('AuthViewModel', () {
    test('restore hata verirse oturumsuz devam eder, restored true', () async {
      final vm = AuthViewModel(
        _BrokenRestoreAuth(),
        communities: MockCommunityRepository(),
      );
      await vm.restore();
      expect(vm.restored, isTrue);
      expect(vm.isSignedIn, isFalse);
    });

    test('çıkışta Beni hatırla kutusu sıfırlanır', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = AuthViewModel(
        MockAuthRepository(),
        communities: MockCommunityRepository(),
      );
      vm
        ..setEmail('elif@std.yildiz.edu.tr')
        ..setPassword('sifre123')
        ..setRemember(true);
      expect(await vm.signIn(), isTrue);
      await vm.signOut();
      expect(vm.remember, isFalse);
    });
  });

  test('SettingsViewModel.reset verileri boşaltır', () async {
    final vm = SettingsViewModel(MockSettingsRepository());
    await vm.loadBlocked();
    await vm.loadPrefs();
    vm.reset();
    expect(vm.blocked, isEmpty);
    expect(vm.loadedBlocked, isFalse);
    expect(vm.loadedPrefs, isFalse);
  });

  testWidgets('Oturum açıkken giriş öncesi sayfalar Ana Sayfa\'ya yönlenir', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    for (final path in ['/forgot', '/signup/sent', '/forgot/new', '/login']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.textContaining('İlanlar · '), findsOneWidget, reason: path);
    }
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Çıkışta ayarlar ve topluluk verisi sıfırlanır', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    final ctx = tester.element(find.byType(Scaffold).first);
    final settings = Provider.of<SettingsViewModel>(ctx, listen: false);
    final communities = Provider.of<CommunityViewModel>(ctx, listen: false);
    // Sahte gecikmeli yüklemeler: zamanı pump ile ilerlet.
    settings.loadBlocked();
    communities.load(mockUser);
    await tester.pump(const Duration(seconds: 1));
    expect(settings.loadedBlocked, isTrue);
    expect(communities.loaded, isTrue);

    Provider.of<AuthViewModel>(ctx, listen: false).signOut();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(settings.loadedBlocked, isFalse);
    expect(settings.blocked, isEmpty);
    expect(communities.loaded, isFalse);
    expect(communities.mine, isEmpty);
  });

  group('Ayarlar kullanıcıya göre ayrı', () {
    test(
      'birinde engel kaldırılınca diğeri etkilenmez; tercihler ayrı',
      () async {
        final repo = MockSettingsRepository();
        final a = SettingsViewModel(repo)..setUser('u-a@yildiz.edu.tr');
        final b = SettingsViewModel(repo)..setUser('u-b@marmara.edu.tr');

        await a.loadBlocked();
        await a.unblock('u-mert');
        expect(a.blocked.map((u) => u.name), ['Kaan D.']);

        await b.loadBlocked();
        expect(b.blocked.map((u) => u.name), ['Mert Y.', 'Kaan D.']);

        await a.loadPrefs();
        await a.setPrefs(a.prefs.copyWith(messages: false));
        await b.loadPrefs();
        expect(b.prefs.messages, isTrue);

        // A'ya geri dönünce kendi verisi yerinde.
        final again = SettingsViewModel(repo)..setUser('u-a@yildiz.edu.tr');
        await again.loadBlocked();
        await again.loadPrefs();
        expect(again.blocked.map((u) => u.name), ['Kaan D.']);
        expect(again.prefs.messages, isFalse);
      },
    );

    test('setUser kullanıcı değişince veriyi bırakır', () async {
      final vm = SettingsViewModel(MockSettingsRepository())..setUser('x');
      await vm.loadBlocked();
      expect(vm.loadedBlocked, isTrue);
      vm.setUser('y');
      expect(vm.loadedBlocked, isFalse);
      expect(vm.blocked, isEmpty);
      vm.setUser('y'); // aynı kullanıcı: değişiklik yok
      expect(vm.userId, 'y');
    });
  });

  testWidgets('Uygulamada hesap değişince engel listesi kişiye özel', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    final ctx = tester.element(find.byType(Scaffold).first);
    final settings = Provider.of<SettingsViewModel>(ctx, listen: false);
    expect(settings.userId, isNotEmpty); // oturumdaki kullanıcıya bağlı
    settings.loadBlocked();
    await tester.pump(const Duration(seconds: 1));
    settings.unblock('u-mert');
    await tester.pump(const Duration(seconds: 1));
    expect(settings.blocked.map((u) => u.name), ['Kaan D.']);
    final elif = settings.userId;

    Provider.of<AuthViewModel>(ctx, listen: false).signOut();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(settings.userId, isNot(elif));
    expect(settings.blocked, isEmpty);
  });
}
