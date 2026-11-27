import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/community_models.dart';
import 'package:bende_var/features/auth/view/community_pages.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

final _marmaraUser = mockAccounts
    .firstWhere((a) => a.user.community.id == mockMarmara.id)
    .user;

void main() {
  setUpAll(initTestEnv);

  group('CommunityViewModel', () {
    test('okul topluluğu en üstte ve ayrılınamaz', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      expect(vm.mine.map((c) => c.id), ['ytu']);
      expect(vm.mine.first.isSchool, isTrue);
      await vm.leave('yildiz'); // listeden düşer ama repo okulu bırakmaz
      final again = CommunityViewModel(MockCommunityRepository());
      await again.load(mockUser);
      expect(again.mine, isNotEmpty);
    });

    test(
      'arama: gizli çıkmaz, okula özel yalnızca okul üyesine çıkar',
      () async {
        final repo = MockCommunityRepository();
        final vm = CommunityViewModel(repo);
        await vm.load(mockUser); // yildiz
        await vm.setQuery('proje');
        expect(vm.results, isEmpty);
        await vm.setQuery('yurt');
        expect(vm.results.map((c) => c.id), ['yurt']);

        final other = CommunityViewModel(MockCommunityRepository());
        await other.load(_marmaraUser);
        await other.setQuery('yurt');
        expect(other.results, isEmpty);
      },
    );

    test('davet kodu: geçersiz, geçerli, tekrar', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      expect(await vm.joinByCode('yanlis'), isNull);
      expect(vm.codeFailure, CommunityFailure.invalidCode);
      final info = await vm.joinByCode(' proje-24 ');
      expect(info?.name, 'Proje Ekibi');
      expect(vm.codeFailure, isNull);
      expect(vm.mine.map((c) => c.id), contains('proje'));
      expect(await vm.joinByCode('PROJE-24'), isNull);
      expect(vm.codeFailure, CommunityFailure.alreadyMember);
    });

    test('oluştur → kurucu, sil → listeden çıkar', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      final c = (await vm.create(
        name: 'Okuma Grubu',
        description: '',
        visibility: CommunityVisibility.secret,
      ))!;
      expect(c.isFounder, isTrue);
      expect(c.inviteCode, isNotNull);
      expect(vm.mine.map((m) => m.id), contains(c.id));
      await vm.delete(c.id);
      expect(vm.mine.map((m) => m.id), isNot(contains(c.id)));
      expect(CommunityViewModel.validName('ab'), isFalse);
      expect(CommunityViewModel.validName(' abc '), isTrue);
    });
  });

  group('Okula özel topluluk', () {
    test('başka okulun üyesi doğrudan istese de katılamaz', () async {
      final repo = MockCommunityRepository();
      final marmara = CommunityViewModel(repo);
      await marmara.load(_marmaraUser);
      expect(await marmara.join('yurt'), isFalse); // 'yurt' YTÜ'ye özel
      expect(marmara.mine.map((c) => c.id), isNot(contains('yurt')));
    });

    test('aynı okulun üyesi katılır; açık topluluğa herkes katılır', () async {
      final repo = MockCommunityRepository();
      final ytu = CommunityViewModel(repo);
      await ytu.load(mockUser);
      expect(await ytu.join('yurt'), isTrue);
      final marmara = CommunityViewModel(repo);
      await marmara.load(_marmaraUser);
      expect(await marmara.join('kamp'), isTrue);
    });
  });

  group('C: davet kodu ve arama sıfırlama', () {
    test('kod yalnızca gizli topluluklarda', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      for (final v in CommunityVisibility.values) {
        final c = (await vm.create(
          name: 'Deneme ${v.name}',
          description: '',
          visibility: v,
        ))!;
        expect(
          c.inviteCode != null,
          v == CommunityVisibility.secret,
          reason: v.name,
        );
      }
      // Seed: açık ve okula özel topluluklarda kod yok, gizlide var.
      final repo = MockCommunityRepository();
      await repo.myCommunities(userId: mockUser.id, school: mockCommunity);
      for (final q in ['kamp', 'yoga', 'yurt']) {
        for (final r in await repo.search(q)) {
          expect(r.inviteCode, isNull, reason: r.name);
        }
      }
      expect(
        (await repo.joinByCode('PROJE-24')).visibility,
        CommunityVisibility.secret,
      );
    });

    test('açık ve okula özel topluluğa kodsuz doğrudan katılınır', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      await vm.join('kamp'); // açık
      await vm.join('yurt'); // okula özel, aynı okul
      expect(vm.mine.map((c) => c.id), containsAll(['kamp', 'yurt']));
    });

    test('resetSearch aramayı ve sonuçları temizler', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      await vm.setQuery('kamp');
      expect(vm.results, isNotEmpty);
      vm.resetSearch();
      expect(vm.query, isEmpty);
      expect(vm.isSearch, isFalse);
      expect(vm.results, isEmpty);
    });
  });

  testWidgets('C1: ekrana yeniden girince arama temizlenir', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    Future<void> settle() async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topluluklarım'));
    await settle();
    await tester.enterText(find.byKey(const Key('community-search')), 'kamp');
    await settle();
    expect(find.byKey(const Key('result-kamp')), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topluluklarım'));
    await settle();
    expect(find.byKey(const Key('result-kamp')), findsNothing);
    expect(find.byKey(const Key('mine-ytu')), findsOneWidget);
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('community-search')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.controller?.text ?? '', isEmpty);
  });

  testWidgets('Topluluklar akışı: ara-katıl, ayrıl, kod, oluştur, sil', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);

    Future<void> settle() async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    Future<void> tapKey(String key) async {
      final f = find.byKey(Key(key));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await settle();
    }

    // Profil → Ayarlar → Topluluklarım (1.16).
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topluluklarım'));
    await settle();
    expect(find.text('Yakında'), findsNothing);
    expect(find.text('Yıldız Teknik Üniversitesi'), findsOneWidget);
    expect(find.text('Okulun'), findsOneWidget);

    // 1.16g arama → katıl.
    await tester.enterText(find.byKey(const Key('community-search')), 'kamp');
    await settle();
    expect(find.byKey(const Key('result-kamp')), findsOneWidget);
    await tapKey('join-kamp');
    expect(find.text('Üyesin'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('community-search')), 'zzz');
    await settle();
    expect(find.text('Bu aramaya uygun topluluk bulunamadı.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('community-search')), '');
    await settle();
    expect(find.byKey(const Key('mine-kamp')), findsOneWidget);

    // 1.17 ayrıl: vazgeç, sonra onayla.
    await tapKey('leave-kamp');
    expect(find.text('Topluluktan ayrılmak istiyor musun?'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await settle();
    expect(find.byKey(const Key('mine-kamp')), findsOneWidget);
    await tapKey('leave-kamp');
    await tester.tap(find.text('Ayrıl').last);
    await settle();
    expect(find.byKey(const Key('mine-kamp')), findsNothing);

    // 1.16c yanlış kod, 1.16b doğru kod.
    await tapKey('join-with-code');
    await tester.enterText(find.byKey(const Key('invite-code')), 'yanlis');
    await tapKey('invite-submit');
    expect(
      find.text('Bu kod geçerli değil. Kodu kontrol edip tekrar dene.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('invite-code')), 'PROJE-24');
    await tapKey('invite-submit');
    expect(find.text('Topluluğa katıldın'), findsOneWidget);
    expect(find.text('Proje Ekibi topluluğuna katıldın.'), findsOneWidget);
    await tapKey('invite-done');
    expect(find.byKey(const Key('mine-proje')), findsOneWidget);

    // 1.16d oluştur: boş ad hata verir, gizli seçilir.
    await tapKey('create-community');
    await tapKey('create-submit');
    expect(find.text('Topluluk adı en az 3 karakter olmalı.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'Okuma Grubu',
    );
    await tapKey('visibility-secret');
    await tapKey('create-submit');
    expect(find.text('Okuma Grubu'), findsOneWidget);

    // 1.16e kurucu işlemleri → 1.16f sil.
    await tapKey('founder-c1');
    expect(find.text('Davet kodunu kopyala'), findsOneWidget);
    await tapKey('founder-delete');
    expect(find.text('Topluluğu silmek istiyor musun?'), findsOneWidget);
    await tester.tap(find.text('Topluluğu sil').last);
    await settle();
    expect(find.text('Okuma Grubu'), findsNothing);
  });

  for (final (name, w, h, scale) in [
    ('320×568', 320.0, 568.0, 1.0),
    ('360×640 büyük yazı', 360.0, 640.0, 1.6),
  ]) {
    testWidgets('Topluluk ekranları taşmaz: $name', (tester) async {
      useAndroidScreen(tester);
      tester.view.physicalSize = Size(w * 2, h * 2);
      tester.view.padding = const FakeViewPadding(bottom: 96, top: 96);
      tester.view.viewPadding = const FakeViewPadding(bottom: 96, top: 96);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final page in const [CommunitiesPage(), CreateCommunityPage()]) {
        final vm = CommunityViewModel(MockCommunityRepository());
        vm.load(mockUser);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: vm),
              ChangeNotifierProvider(
                create: (_) => AuthViewModel(
                  MockAuthRepository(),
                  communities: MockCommunityRepository(),
                ),
              ),
            ],
            child: wrap(page),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
