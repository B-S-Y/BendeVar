import 'package:bende_var/core/widgets/sheets.dart';
import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/community_pages.dart';
import 'package:bende_var/features/auth/view/help_page.dart';
import 'package:bende_var/features/auth/view/legal_page.dart';
import 'package:bende_var/features/auth/view/settings_pages.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:bende_var/app/locale_controller.dart';
import 'package:bende_var/app/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

final _pages = <String, Widget>{
  'settings': const SettingsPage(),
  'notif': const NotificationSettingsPage(),
  'privacy': const PrivacySupportPage(),
  'blocked': const BlockedAccountsPage(),
  'help': const HelpPage(),
  'communities': const CommunitiesPage(),
  'create': const CreateCommunityPage(),
  'terms': const LegalPage(kind: LegalKind.terms, inSettings: true),
};

void main() {
  setUpAll(initTestEnv);
  for (final (w, h) in [(360.0, 800.0), (412.0, 917.0)]) {
    for (final scale in [1.3, 1.5]) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets(
          'Ayarlar alt sayfaları: ${w.toInt()}×${h.toInt()} ×$scale ${mode.name}',
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
            SharedPreferences.setMockInitialValues({});
            final prefs = await SharedPreferences.getInstance();
            final entries = [
              ..._pages.entries,
              MapEntry('theme_sheet', const SettingsPage()),
            ];
            for (final e in entries) {
              final communities = CommunityViewModel(MockCommunityRepository())
                ..load(mockUser);
              await tester.pumpWidget(
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(
                      value: SettingsViewModel(MockSettingsRepository()),
                    ),
                    ChangeNotifierProvider.value(value: communities),
                    ChangeNotifierProvider(
                      create: (_) => AuthViewModel(
                        MockAuthRepository(),
                        communities: MockCommunityRepository(),
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => ThemeController(prefs),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => LocaleController(prefs),
                    ),
                  ],
                  child: wrap(RepaintBoundary(child: e.value), theme: mode),
                ),
              );
              await tester.pump(const Duration(seconds: 1));
              await tester.pumpAndSettle();
              if (e.key == 'theme_sheet') {
                showThemeLanguageSheet(
                  tester.element(find.byType(SettingsPage)),
                );
                await tester.pumpAndSettle();
                // Sheet alt sistem çubuğunun üstünde biter.
                expect(
                  tester.getRect(find.text('Kapat')).bottom,
                  lessThanOrEqualTo(h - 48),
                );
              }
              if (e.key == 'blocked') {
                // Ad tek satır, okul en fazla iki satır (büyük yazıda sıkışmasın).
                final name = tester.widget<Text>(
                  find.byKey(const Key('blocked-name-u-mert')),
                );
                final school = tester.widget<Text>(
                  find.byKey(const Key('blocked-community-u-mert')),
                );
                expect(name.maxLines, 1);
                expect(school.maxLines, 2);
              }
              expect(
                tester.takeException(),
                isNull,
                reason: '${e.key} $w×$h $scale ${mode.name}',
              );
              // Alt güvenli alan: sona kaydırınca son içerik sistem çubuğunun üstünde mi?
              final scrollables = find.byType(Scrollable);
              if (e.key != 'theme_sheet' && scrollables.evaluate().isNotEmpty) {
                final st = tester.state<ScrollableState>(scrollables.first);
                st.position.jumpTo(st.position.maxScrollExtent);
                await tester.pump();
                final viewport = tester.getRect(scrollables.first);
                // İçeriğin en alt noktası (son çocuk) için: tüm Text'lerin alt kenarı.
                double maxBottom = 0;
                for (final t
                    in find
                        .descendant(
                          of: scrollables.first,
                          matching: find.byType(Text),
                        )
                        .evaluate()) {
                  final r = tester.getRect(find.byWidget(t.widget).first);
                  if (r.bottom > maxBottom && r.bottom <= viewport.bottom + 1) {
                    maxBottom = r.bottom;
                  }
                }
                final safeBottom = h - 48; // 96 px / 2
                expect(
                  maxBottom,
                  lessThanOrEqualTo(safeBottom),
                  reason:
                      'alt güvenli alan: ${e.key} $w×$h $scale ${mode.name}',
                );
              }
            }
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
