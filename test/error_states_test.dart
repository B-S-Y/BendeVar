import 'package:bende_var/core/theme/app_spacing.dart';
import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/community_models.dart';
import 'package:bende_var/data/models/models.dart';
import 'package:bende_var/data/models/settings_models.dart';
import 'package:bende_var/features/auth/view/community_pages.dart';
import 'package:bende_var/features/auth/view/settings_pages.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

/// İlk [failures] çağrıda hata atar, sonra normal çalışır.
class _FlakySettings extends MockSettingsRepository {
  _FlakySettings({this.failures = 1});
  int failures;

  void _maybeFail() {
    if (failures > 0) {
      failures--;
      throw StateError('ağ');
    }
  }

  @override
  Future<List<BlockedUser>> blockedUsers(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _maybeFail();
    return super.blockedUsers(userId);
  }

  @override
  Future<NotificationPrefs> notificationPrefs(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _maybeFail();
    return super.notificationPrefs(userId);
  }

  bool failSave = false;

  @override
  Future<void> saveNotificationPrefs(
    String userId,
    NotificationPrefs prefs,
  ) async {
    if (failSave) throw StateError('ağ');
    return super.saveNotificationPrefs(userId, prefs);
  }
}

class _FlakyCommunities extends MockCommunityRepository {
  int loadFailures = 1;
  bool failJoin = false;

  @override
  Future<List<CommunityInfo>> myCommunities({
    required String userId,
    required Community school,
  }) async {
    if (loadFailures > 0) {
      loadFailures--;
      throw StateError('ağ');
    }
    return super.myCommunities(userId: userId, school: school);
  }

  @override
  Future<CommunityInfo> join(String id) async {
    if (failJoin) throw StateError('ağ');
    return super.join(id);
  }

  @override
  Future<CommunityInfo> joinByCode(String code) async => throw StateError('ağ');
}

Widget _host(
  Widget page, {
  SettingsViewModel? settings,
  CommunityViewModel? communities,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(
      value: settings ?? SettingsViewModel(MockSettingsRepository()),
    ),
    ChangeNotifierProvider.value(
      value: communities ?? CommunityViewModel(MockCommunityRepository()),
    ),
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(
        MockAuthRepository(),
        communities: MockCommunityRepository(),
      ),
    ),
  ],
  child: wrap(page),
);

void main() {
  setUpAll(initTestEnv);

  testWidgets('Engellenenler: yükleniyor → hata → Tekrar dene → liste', (
    tester,
  ) async {
    useAndroidScreen(tester);
    final vm = SettingsViewModel(_FlakySettings());
    await tester.pumpWidget(_host(const BlockedAccountsPage(), settings: vm));
    await tester.pump();
    expect(find.byKey(const Key('settings-loading')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('Yüklenemedi. Bağlantını kontrol edip tekrar dene.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tekrar dene'));
    await tester.pump();
    expect(find.byKey(const Key('settings-loading')), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Mert Y.'), findsOneWidget);
  });

  testWidgets(
    '1.18: ayarlar yüklenene kadar anahtar yok; kayıt hatası geri alır',
    (tester) async {
      useAndroidScreen(tester);
      final repo = _FlakySettings(failures: 0);
      final vm = SettingsViewModel(repo);
      await tester.pumpWidget(
        _host(const NotificationSettingsPage(), settings: vm),
      );
      await tester.pump();
      expect(find.byType(Switch), findsNothing);
      expect(find.byKey(const Key('settings-loading')), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Switch), findsNWidgets(3));

      repo.failSave = true;
      await tester.tap(find.byKey(const Key('notif-messages')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(vm.prefs.messages, isTrue); // eski değere döndü
      expect(find.text('İşlem tamamlanamadı.'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    },
  );

  test(
    'CommunityViewModel: yükleme hatası, tekrar dene, işlem hatası',
    () async {
      final repo = _FlakyCommunities();
      final vm = CommunityViewModel(repo);
      await vm.load(mockUser);
      expect(vm.loadFailed, isTrue);
      expect(vm.loaded, isFalse);
      await vm.retryLoad();
      expect(vm.loadFailed, isFalse);
      expect(vm.loaded, isTrue);

      repo.failJoin = true;
      expect(await vm.join('kamp'), isFalse);
      expect(vm.mine.map((c) => c.id), isNot(contains('kamp')));
      expect(await vm.joinByCode('482913'), isNull);
      expect(vm.codeFailure, CommunityFailure.unknown);
    },
  );

  testWidgets('Topluluklarım: arama kutusu liste yüklenene kadar pasif', (
    tester,
  ) async {
    useAndroidScreen(tester);
    final vm = CommunityViewModel(MockCommunityRepository());
    await tester.pumpWidget(_host(const CommunitiesPage(), communities: vm));
    await tester.pump();
    TextField field() => tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('community-search')),
        matching: find.byType(TextField),
      ),
    );
    expect(vm.loaded, isFalse);
    expect(field().enabled, isFalse);
    // Pasif alana dokunmak odak/klavye açmaz.
    await tester.tap(
      find.byKey(const Key('community-search')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    expect(vm.query, isEmpty);

    vm.load(mockUser);
    await tester.pump(const Duration(seconds: 1));
    expect(field().enabled, isTrue);
    await tester.enterText(find.byKey(const Key('community-search')), 'kamp');
    await tester.pump(const Duration(seconds: 1));
    expect(vm.query, 'kamp');
    expect(find.byKey(const Key('result-kamp')), findsOneWidget);
  });

  testWidgets('Topluluklarım: yüklenirken gösterge, hata olunca Tekrar dene', (
    tester,
  ) async {
    useAndroidScreen(tester);
    final vm = CommunityViewModel(_FlakyCommunities());
    await tester.pumpWidget(_host(const CommunitiesPage(), communities: vm));
    await tester.pump();
    expect(find.byKey(const Key('settings-loading')), findsOneWidget);
    vm.load(mockUser);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tekrar dene'), findsOneWidget);
    await tester.tap(find.text('Tekrar dene'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('mine-yildiz')), findsOneWidget);
  });

  for (final page in const [BlockedAccountsPage(), CommunitiesPage()]) {
    testWidgets('Alt sistem çubuğu payı: ${page.runtimeType}', (tester) async {
      useAndroidScreen(tester);
      tester.view.padding = const FakeViewPadding(bottom: 96);
      tester.view.viewPadding = const FakeViewPadding(bottom: 96);
      final communities = CommunityViewModel(MockCommunityRepository());
      communities.load(mockUser);
      await tester.pumpWidget(_host(page, communities: communities));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final padding = tester
          .widget<ListView>(find.byType(ListView))
          .padding!
          .resolve(TextDirection.ltr);
      // 96 fiziksel px / dpr 2 = 48 dp.
      expect(padding.bottom, AppSpacing.xxl + 48);
    });
  }
}
