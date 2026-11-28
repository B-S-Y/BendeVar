import 'package:bende_var/core/utils/community_icons.dart';
import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/community_models.dart';
import 'package:bende_var/data/models/settings_models.dart';
import 'package:bende_var/features/auth/view/community_pages.dart';
import 'package:bende_var/features/auth/view/settings_pages.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

/// Profil → Ayarlar → Topluluklarım (1.16).
Future<void> _openCommunities(WidgetTester tester) async {
  await tester.tap(find.byIcon(LucideIcons.user));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Ayarlar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Topluluklarım'));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Dokunur, SnackBar görünene kadar birkaç kare ilerler (settle yok: SnackBar
/// süresi dolup kaybolmasın).
Future<void> _tapOnly(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
  // Sheet kapanır, pano yazılır, SnackBar girer.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await _settle(tester);
}

/// Pano yazımlarını yakalar.
List<String> _captureClipboard(WidgetTester tester) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

void main() {
  setUpAll(initTestEnv);

  group('Simgeler', () {
    test('12 simge, hepsi tanımlı; bilinmeyen anahtar users olur', () {
      expect(kCommunityIconKeys, hasLength(12));
      expect(kCommunityIconKeys.first, kDefaultCommunityIcon);
      expect(communityIcon('book-open'), LucideIcons.bookOpen);
      expect(communityIcon(kSchoolCommunityIcon), LucideIcons.graduationCap);
      expect(communityIcon('yok'), LucideIcons.users);
      expect(
        kCommunityIconKeys.map(communityIcon).toSet(),
        hasLength(kCommunityIconKeys.length),
      );
    });

    test('seçilen simge CommunityInfo.iconKey olarak saklanır', () async {
      final repo = MockCommunityRepository();
      final vm = CommunityViewModel(repo);
      await vm.load(mockUser);
      final c = (await vm.create(
        name: 'Koşu Grubu',
        description: '',
        visibility: CommunityVisibility.open,
        iconKey: 'bike',
      ))!;
      expect(c.iconKey, 'bike');
      expect(vm.mine.firstWhere((m) => m.id == c.id).iconKey, 'bike');
      expect(vm.mine.first.iconKey, kSchoolCommunityIcon);
    });
  });

  group('Ad kontrolü', () {
    test(
      'boş/kısa ad denetlenmez, aynı ad (harf farkı önemsiz) alınmış',
      () async {
        final vm = CommunityViewModel(MockCommunityRepository());
        await vm.load(mockUser);
        await vm.checkName('');
        expect(vm.nameAvailable, isNull);
        await vm.checkName('ab');
        expect(vm.nameAvailable, isNull);
        await vm.checkName('Okuma Grubu');
        expect(vm.nameAvailable, isTrue);
        await vm.checkName('KAMP KULÜBÜ');
        expect(vm.nameAvailable, isFalse);
        await vm.checkName('kamp kulubu');
        expect(vm.nameAvailable, isFalse);
      },
    );

    test('alınmış adla oluşturulamaz', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      final c = await vm.create(
        name: 'Kamp Kulübü',
        description: '',
        visibility: CommunityVisibility.open,
      );
      expect(c, isNull);
      expect(vm.nameAvailable, isFalse);
      expect(vm.mine.map((m) => m.name), isNot(contains('Kamp Kulübü')));
    });
  });

  group('Görünürlük değişimi', () {
    test('kaydedilir; kod yalnızca gizlide bulunur', () async {
      final repo = MockCommunityRepository();
      final vm = CommunityViewModel(repo);
      await vm.load(mockUser);
      final c = (await vm.create(
        name: 'Okuma Grubu',
        description: '',
        visibility: CommunityVisibility.secret,
      ))!;
      final code = c.inviteCode;
      expect(code, isNotNull);

      expect(await vm.setVisibility(c.id, CommunityVisibility.open), isTrue);
      var row = vm.mine.firstWhere((m) => m.id == c.id);
      expect(row.visibility, CommunityVisibility.open);
      expect(row.inviteCode, isNull);

      expect(
        await vm.setVisibility(c.id, CommunityVisibility.schoolOnly),
        isTrue,
      );
      row = vm.mine.firstWhere((m) => m.id == c.id);
      expect(row.visibility, CommunityVisibility.schoolOnly);
      expect(row.schoolId, mockUser.community.id);

      expect(await vm.setVisibility(c.id, CommunityVisibility.secret), isTrue);
      expect(
        vm.mine.firstWhere((m) => m.id == c.id).inviteCode,
        matches(RegExp(r'^\d{6}$')),
      );

      // Yeni görünüm repoda kalıcı: yeni bir model aynı değeri okur.
      final again = CommunityViewModel(repo);
      await again.load(mockUser);
      expect(
        again.mine.firstWhere((m) => m.id == c.id).visibility,
        CommunityVisibility.secret,
      );
    });

    test('kurucu olmayan ve okul topluluğu değiştirilemez', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      expect(
        await vm.setVisibility('yildiz', CommunityVisibility.open),
        isFalse,
      );
      await vm.join('kamp');
      expect(
        await vm.setVisibility('kamp', CommunityVisibility.secret),
        isFalse,
      );
    });
  });

  group('"Yeni" rozeti', () {
    test('katılınca 24 saat görünür, sonra kaybolur', () async {
      var clock = DateTime(2026, 11, 28, 10);
      final repo = MockCommunityRepository(now: () => clock);
      final vm = CommunityViewModel(repo, now: () => clock);
      await vm.load(mockUser);
      expect(vm.isNew(vm.mine.first), isFalse); // okul topluluğu: hiç

      await vm.join('kamp');
      final kamp = vm.mine.firstWhere((m) => m.id == 'kamp');
      expect(kamp.joinedAt, clock);
      expect(vm.isNew(kamp), isTrue);

      clock = clock.add(const Duration(hours: 23, minutes: 59));
      expect(vm.isNew(kamp), isTrue);
      clock = clock.add(const Duration(minutes: 1));
      expect(vm.isNew(kamp), isFalse);
    });

    test('yeni oluşturulan topluluk rozet alır, 24 saat sonra almaz; ayrılıp dönünce yeniden damgalanır', () async {
      var clock = DateTime(2026, 11, 28, 10);
      final repo = MockCommunityRepository(now: () => clock);
      final vm = CommunityViewModel(repo, now: () => clock);
      await vm.load(mockUser);
      final c = (await vm.create(
        name: 'Okuma Grubu',
        description: '',
        visibility: CommunityVisibility.open,
      ))!;
      CommunityInfo mine(String id) => vm.mine.firstWhere((m) => m.id == id);
      expect(c.joinedAt, clock);
      expect(vm.isNew(mine(c.id)), isTrue);
      clock = clock.add(const Duration(hours: 23, minutes: 59));
      expect(vm.isNew(mine(c.id)), isTrue);
      clock = clock.add(const Duration(minutes: 1));
      expect(vm.isNew(mine(c.id)), isFalse);

      await vm.join('kamp');
      await vm.leave('kamp');
      clock = clock.add(const Duration(days: 3));
      await vm.join('kamp');
      expect(vm.isNew(mine('kamp')), isTrue);
    });

    test('vurgu: oluşturma ve davet koduyla katılmada set, aramadan '
        'katılmada yok, temizlenir', () async {
      final vm = CommunityViewModel(MockCommunityRepository());
      await vm.load(mockUser);
      expect(vm.highlightedId, isNull);
      await vm.join('kamp');
      expect(vm.highlightedId, isNull);
      final c = (await vm.create(
        name: 'Okuma Grubu',
        description: '',
        visibility: CommunityVisibility.open,
      ))!;
      expect(vm.highlightedId, c.id);
      vm.clearHighlight();
      expect(vm.highlightedId, isNull);
      await vm.joinByCode('482913');
      expect(vm.highlightedId, 'proje');
      vm.reset();
      expect(vm.highlightedId, isNull);
    });

    test('demo: 3 saat önce katılınmış topluluk rozetli başlar', () async {
      final clock = DateTime(2026, 11, 28, 10);
      final repo = MockCommunityRepository(
        now: () => clock,
        seedDemoMembership: true,
      );
      final vm = CommunityViewModel(repo, now: () => clock);
      await vm.load(mockUser);
      final yoga = vm.mine.firstWhere((m) => m.id == 'yoga');
      expect(clock.difference(yoga.joinedAt!), const Duration(hours: 3));
      expect(vm.isNew(yoga), isTrue);
    });
  });

  group('Bildirim tercihleri (1.18)', () {
    test('hatırlatma zamanı varsayılanı ve kaydı', () async {
      final repo = MockSettingsRepository();
      final vm = SettingsViewModel(repo)..setUser('u1');
      await vm.loadPrefs();
      expect(vm.prefs.reminderTiming, ReminderTiming.dayBeforeAndDay);
      await vm.setPrefs(
        vm.prefs.copyWith(reminderTiming: ReminderTiming.twoDaysBefore),
      );
      final again = SettingsViewModel(repo)..setUser('u1');
      await again.loadPrefs();
      expect(again.prefs.reminderTiming, ReminderTiming.twoDaysBefore);
      // Başka kullanıcıya sızmaz.
      final other = SettingsViewModel(repo)..setUser('u2');
      await other.loadPrefs();
      expect(other.prefs.reminderTiming, ReminderTiming.dayBeforeAndDay);
    });

    testWidgets('anahtarlar ve zaman seçenekleri', (tester) async {
      useAndroidScreen(tester);
      final vm = SettingsViewModel(MockSettingsRepository())..setUser('u1');
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: wrap(const NotificationSettingsPage()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Duyuru anahtarı yok; üç anahtar görseldeki sırayla.
      expect(find.byKey(const Key('notif-announcements')), findsNothing);
      expect(find.text('Topluluk duyuruları'), findsNothing);
      expect(find.text('Yeni karşılıklar'), findsOneWidget);
      expect(find.text('Yeni mesajlar'), findsOneWidget);
      expect(find.text('İade hatırlatması'), findsOneWidget);
      // Telefon bildirimi uyarısı yok (izin okuyan paket yok).
      expect(find.textContaining('Telefonda bildirimler kapalı'), findsNothing);
      // Terminoloji: talep/teklif yok.
      expect(find.textContaining('teklif'), findsNothing);
      expect(find.textContaining('Talebine'), findsNothing);

      // Açıkken "Ne zaman hatırlatalım?" ve 3 seçenek; 1 gün önce seçili.
      expect(find.text('Ne zaman hatırlatalım?'), findsOneWidget);
      expect(find.text('İade gününden 2 gün önce'), findsOneWidget);
      expect(find.text('1 gün önce ve iade günü'), findsOneWidget);
      expect(find.text('Yalnızca iade günü'), findsOneWidget);
      expect(vm.prefs.reminderTiming, ReminderTiming.dayBeforeAndDay);

      await tester.tap(find.byKey(const Key('remind-dayOf')));
      await tester.pumpAndSettle();
      expect(vm.prefs.reminderTiming, ReminderTiming.dayOf);
      await tester.tap(find.byKey(const Key('remind-twoDaysBefore')));
      await tester.pumpAndSettle();
      expect(vm.prefs.reminderTiming, ReminderTiming.twoDaysBefore);

      // Hatırlatma kapanınca grup gizlenir, seçim korunur.
      await tester.tap(find.byKey(const Key('notif-reminders')));
      await tester.pumpAndSettle();
      expect(find.text('Ne zaman hatırlatalım?'), findsNothing);
      expect(vm.prefs.reminderTiming, ReminderTiming.twoDaysBefore);
      await tester.tap(find.byKey(const Key('notif-reminders')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('remind-twoDaysBefore')), findsOneWidget);
    });
  });

  testWidgets('1.16d: ad kontrolü, simge seçimi, satırda simge', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    await _openCommunities(tester);
    await _tapKey(tester, 'create-community');

    // Izgara: 12 simge, ilki seçili.
    for (final k in kCommunityIconKeys) {
      expect(find.byKey(Key('icon-$k')), findsOneWidget, reason: k);
    }
    expect(find.text('Kim görebilir?'), findsOneWidget);
    expect(find.text('Herkes adıyla arayıp katılabilir.'), findsOneWidget);
    expect(
      find.text('Sadece okulundaki kişiler adıyla arayıp katılabilir.'),
      findsOneWidget,
    );
    expect(
      find.text('Aramada çıkmaz. Sadece davet koduyla girilir.'),
      findsOneWidget,
    );

    // Ad boşken not yok; yazılınca "kullanılabilir"; alınmış adda hata.
    expect(find.text('Bu ad kullanılabilir.'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'Koşu Grubu',
    );
    await _settle(tester);
    expect(find.text('Bu ad kullanılabilir.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('community-name')), '');
    await _settle(tester);
    expect(find.text('Bu ad kullanılabilir.'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'kamp kulubu',
    );
    await _settle(tester);
    expect(find.text('Bu ad zaten kullanılıyor.'), findsOneWidget);
    expect(find.text('Bu ad kullanılabilir.'), findsNothing);
    await _tapKey(tester, 'create-submit'); // engellenir
    expect(find.byKey(const Key('community-name')), findsOneWidget);

    // Geçerli ad + trophy simgesi → satırda trophy.
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'Koşu Grubu',
    );
    await _settle(tester);
    await _tapKey(tester, 'icon-trophy');
    await _tapKey(tester, 'create-submit');
    final row = find.byKey(const Key('mine-c1'));
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.byIcon(LucideIcons.trophy)),
      findsOneWidget,
    );
    // Okul topluluğu graduation-cap ile kalır; baş harfli avatar yok.
    expect(
      find.descendant(
        of: find.byKey(const Key('mine-yildiz')),
        matching: find.byIcon(LucideIcons.graduationCap),
      ),
      findsOneWidget,
    );
    // Demo: 3 saat önce katılınan topluluk "Yeni" rozetli; okul ve kurucuda yok.
    expect(find.byKey(const Key('new-yoga')), findsOneWidget);
    expect(find.byKey(const Key('new-yildiz')), findsNothing);
    // Oluşturulan topluluk da rozetli ve (bu ekranda kalındığı için) mavi çerçeveli.
    expect(find.byKey(const Key('new-c1')), findsOneWidget);
    expect(find.text('Yeni'), findsNWidgets(2));
    expect(find.byKey(const Key('highlight-row-frame')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('highlight-row-frame')),
        matching: find.byKey(const Key('founder-c1')),
      ),
      findsOneWidget,
    );

    // Ekrandan çıkıp girince vurgu kalkar, rozet 24 saat durur.
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topluluklarım'));
    await _settle(tester);
    expect(find.byKey(const Key('highlight-row-frame')), findsNothing);
    expect(find.byKey(const Key('row-frame-c1')), findsOneWidget);
    expect(find.byKey(const Key('new-c1')), findsOneWidget);
    expect(find.byKey(const Key('new-yoga')), findsOneWidget);
    // Okul satırı koyu çerçeveli, diğerleri aynı kart iskeletinde.
    expect(find.byKey(const Key('school-row-frame')), findsOneWidget);
    expect(find.byKey(const Key('row-frame-yoga')), findsOneWidget);
  });

  testWidgets('1.16e: Paylaş panoya davet metnini kopyalar', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    final copied = _captureClipboard(tester);
    await _openCommunities(tester);
    await _tapKey(tester, 'create-community');
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'Okuma Grubu',
    );
    await _settle(tester);
    await _tapKey(tester, 'visibility-secret');
    await _tapKey(tester, 'create-submit');

    // "Topluluk oluşturuldu." SnackBar'ı kapansın (kuyrukta beklemesin).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await _tapKey(tester, 'founder-c1');
    expect(find.text('Kurucu işlemleri'), findsOneWidget);
    expect(find.text('Davet kodu'), findsOneWidget);
    final code = tester
        .widget<Text>(find.byKey(const Key('founder-code')))
        .data!;
    expect(code, matches(RegExp(r'^\d{6}$')));

    await _tapOnly(tester, 'founder-share');
    expect(copied, hasLength(1));
    expect(copied.single, contains('Okuma Grubu'));
    expect(copied.single, contains(code));
    expect(find.text('Davet metni kopyalandı.'), findsOneWidget);

    // Kopyala yalnızca kodu kopyalar (önceki SnackBar kapansın).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await _tapKey(tester, 'founder-c1');
    await _tapOnly(tester, 'founder-copy');
    expect(copied.last, code);
    expect(find.text('Davet kodu kopyalandı.'), findsOneWidget);
  });

  /// Okuma Grubu adlı topluluğu verilen türde oluşturur (ekran: Topluluklarım).
  Future<void> createCommunity(WidgetTester tester, String visibility) async {
    await _tapKey(tester, 'create-community');
    await tester.enterText(
      find.byKey(const Key('community-name')),
      'Okuma Grubu',
    );
    await _settle(tester);
    await _tapKey(tester, 'visibility-$visibility');
    await _tapKey(tester, 'create-submit');
    // "Topluluk oluşturuldu." SnackBar'ı kapansın.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets(
    '1.16e: görünürlük taslaktır; Kaydet kaydeder, kapatınca kaybolur',
    (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await _openCommunities(tester);
      await createCommunity(tester, 'secret');
      expect(find.textContaining('Gizli'), findsOneWidget);

      // Değişiklik yokken ana düğme Kapat.
      await _tapKey(tester, 'founder-c1');
      expect(find.byKey(const Key('founder-code-card')), findsOneWidget);
      expect(find.byKey(const Key('founder-close')), findsOneWidget);
      expect(find.byKey(const Key('founder-save')), findsNothing);

      // Taslak değişince Kaydet; eski tür geri seçilince yine Kapat.
      await _tapKey(tester, 'segment-schoolOnly');
      expect(find.byKey(const Key('founder-save')), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);
      expect(
        find.text(
          'Okula özel: sadece okulundaki kişiler adıyla arayıp katılabilir.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('founder-code-card')), findsNothing);
      await _tapKey(tester, 'segment-secret');
      expect(find.byKey(const Key('founder-close')), findsOneWidget);
      expect(find.byKey(const Key('founder-code-card')), findsOneWidget);

      // Kaydetmeden kapatınca (sheet dışına dokun) hiçbir şey değişmez.
      await _tapKey(tester, 'segment-open');
      await tester.tapAt(const Offset(10, 10));
      await _settle(tester);
      expect(find.textContaining('Gizli'), findsOneWidget);
      await _tapKey(tester, 'founder-c1');
      expect(find.byKey(const Key('founder-code-card')), findsOneWidget);

      // Kaydet: sheet kapanır, satır güncellenir.
      await _tapKey(tester, 'segment-schoolOnly');
      await _tapKey(tester, 'founder-save');
      expect(find.byKey(const Key('founder-save')), findsNothing);
      expect(find.textContaining('Okula özel'), findsOneWidget);
      expect(find.textContaining('Gizli'), findsNothing);
    },
  );

  testWidgets(
    '1.16e: gizliye geçiş kod yer tutucusu gösterir, Kaydet kod üretir',
    (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await _openCommunities(tester);
      await createCommunity(tester, 'open');

      await _tapKey(tester, 'founder-c1');
      expect(find.byKey(const Key('founder-code-card')), findsNothing);
      await _tapKey(tester, 'segment-secret');
      expect(find.text('Kaydedince davet kodu oluşturulur.'), findsOneWidget);
      expect(find.byKey(const Key('founder-code')), findsNothing);
      await _tapKey(tester, 'founder-save');

      await _tapKey(tester, 'founder-c1');
      final code = tester
          .widget<Text>(find.byKey(const Key('founder-code')))
          .data!;
      expect(code, matches(RegExp(r'^\d{6}$')));
      expect(
        find.descendant(
          of: find.byKey(const Key('mine-c1')),
          matching: find.textContaining('Gizli'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '1.16e: seçenek değişince sheet sıçramaz, yumuşak büyür/küçülür',
    (tester) async {
      // Animasyonlar açık (useAndroidScreen azaltılmış hareket ister, burada yok).
      tester.view.physicalSize = const Size(824, 1834);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final vm = CommunityViewModel(MockCommunityRepository());
      // Mock gecikmesi gerçek zaman ister: sahte saat dışında çalıştır.
      final c = (await tester.runAsync(() async {
        await vm.load(mockUser);
        return vm.create(
          name: 'Okuma Grubu',
          description: '',
          visibility: CommunityVisibility.secret,
        );
      }))!;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: wrap(
            Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: const Key('open-sheet'),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FounderSheet(communityId: c.id),
                  ),
                  child: const Text('aç'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('open-sheet')));
      await tester.pumpAndSettle();

      double top() => tester.getTopLeft(find.byType(BottomSheet)).dy;
      final topSecret = top();
      final sizeSecret = tester.getSize(
        find.byKey(const Key('founder-code-size')),
      );

      // Gizli → Açık: kod bölümü kapanır; sheet bir anda değil, adım adım iner.
      await tester.tap(find.byKey(const Key('segment-open')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final topMid = top();
      final sizeMid = tester.getSize(
        find.byKey(const Key('founder-code-size')),
      );
      expect(sizeMid.height, lessThan(sizeSecret.height));
      expect(sizeMid.height, greaterThan(0));
      expect(topMid, greaterThan(topSecret));
      await tester.pumpAndSettle();
      final topOpen = top();
      expect(topOpen, greaterThan(topMid));

      // Açık → Okula özel: açıklama 1 ↔ 2 satır olsa da sheet yerinde kalır.
      await tester.tap(find.byKey(const Key('segment-schoolOnly')));
      await tester.pumpAndSettle();
      expect(top(), topOpen);
      await tester.tap(find.byKey(const Key('segment-open')));
      await tester.pumpAndSettle();
      expect(top(), topOpen);
    },
  );
}
