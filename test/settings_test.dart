import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/settings_pages.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  group('SettingsViewModel', () {
    test('bildirim tercihleri kaydedilir', () async {
      final vm = SettingsViewModel(MockSettingsRepository());
      await vm.loadPrefs();
      expect(vm.prefs.messages, isTrue);
      await vm.setPrefs(vm.prefs.copyWith(messages: false));
      expect(vm.prefs.messages, isFalse);
      expect(vm.prefs.reminders, isTrue);
    });

    test('engeli kaldırınca listeden çıkar', () async {
      final vm = SettingsViewModel(MockSettingsRepository());
      await vm.loadBlocked();
      expect(vm.blocked.map((b) => b.name), ['Mert Y.', 'Kaan D.']);
      await vm.unblock('u-mert');
      expect(vm.blocked.map((b) => b.name), ['Kaan D.']);
    });
  });

  testWidgets('Ayarlar akışı: bildirimler, engellenenler, şartlar, çıkış', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    // Profil sekmesi → dişli ikonu → Ayarlar (1.15).
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    expect(find.text('Tema ve dil'), findsOneWidget);
    expect(find.text('Yakında'), findsNothing);

    // 1.15 → tema/dil sheet'i.
    await tester.tap(find.text('Tema ve dil'));
    await tester.pumpAndSettle();
    expect(find.text('Kapat'), findsOneWidget);
    await tester.tap(find.text('Kapat'));
    await tester.pumpAndSettle();

    // 1.18 bildirim ayarları.
    await tester.tap(find.text('Bildirim ayarları'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    Switch sw(String key) => tester.widget<Switch>(find.byKey(Key(key)));
    expect(sw('notif-messages').value, isTrue);
    await tester.tap(find.byKey(const Key('notif-messages')));
    await tester.pumpAndSettle();
    expect(sw('notif-messages').value, isFalse);
    expect(sw('notif-reminders').value, isTrue);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();

    // 1.19 → 1.19a şartlar → geri.
    await tester.tap(find.text('Gizlilik ve destek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kullanım şartları'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bende Var, aynı okulda'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();

    // 1.20 → 1.21.
    await tester.tap(find.text('Engellenen hesaplar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // sahte repo gecikmesi
    await tester.pumpAndSettle();
    expect(find.text('Mert Y.'), findsOneWidget);
    expect(find.text('Kaan D.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('unblock-u-mert')));
    await tester.pumpAndSettle();
    expect(find.text('Engeli kaldırmak istiyor musun?'), findsOneWidget);
    expect(
      find.text('Mert Y. sana yeniden mesaj gönderebilir.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.text('Mert Y.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('unblock-u-mert')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Engeli kaldır').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Mert Y.'), findsNothing);
    expect(find.text('Kaan D.'), findsOneWidget);
    expect(find.text('Engel kaldırıldı.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('unblock-u-kaan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Engeli kaldır').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Engellediğin hesap yok.'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();

    // 1.15b çıkış onayı.
    await tester.tap(find.text('Çıkış yap'));
    await tester.pumpAndSettle();
    expect(find.text('Çıkış yapılsın mı?'), findsOneWidget);
    expect(find.text('Hesabından çıkacaksın.'), findsOneWidget);
    expect(find.text('Vazgeç'), findsOneWidget);
    expect(find.textContaining('bildirim'), findsNothing);
    await tester.tap(find.text('Çıkış yap').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Bende Var'), findsOneWidget);
    expect(find.text('Giriş yap'), findsOneWidget);
  });

  for (final (name, w, h, scale) in [
    ('320×568', 320.0, 568.0, 1.0),
    ('360×640 büyük yazı', 360.0, 640.0, 1.6),
  ]) {
    testWidgets('Ayarlar ekranları taşmaz: $name', (tester) async {
      useAndroidScreen(tester);
      tester.view.physicalSize = Size(w * 2, h * 2);
      tester.view.padding = const FakeViewPadding(bottom: 96, top: 96);
      tester.view.viewPadding = const FakeViewPadding(bottom: 96, top: 96);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final page in const [
        NotificationSettingsPage(),
        PrivacySupportPage(),
        BlockedAccountsPage(),
      ]) {
        final vm = SettingsViewModel(MockSettingsRepository());
        await tester.pumpWidget(
          ChangeNotifierProvider.value(value: vm, child: wrap(page)),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
