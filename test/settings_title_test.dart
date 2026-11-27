import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/view/community_pages.dart';
import 'package:bende_var/features/auth/view/help_page.dart';
import 'package:bende_var/features/auth/view/legal_page.dart';
import 'package:bende_var/features/auth/view/settings_pages.dart';
import 'package:bende_var/features/auth/view/settings_widgets.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/settings_view_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

/// Ayarlar ailesinin tüm SettingsScaffold sayfaları.
const _pages = <Widget>[
  SettingsPage(),
  NotificationSettingsPage(),
  PrivacySupportPage(),
  BlockedAccountsPage(),
  HelpPage(),
  CommunitiesPage(),
  CreateCommunityPage(),
  LegalPage(kind: LegalKind.terms, inSettings: true),
  LegalPage(kind: LegalKind.privacy, inSettings: true),
];

Widget _host(Widget page, Locale locale) {
  final communities = CommunityViewModel(MockCommunityRepository())
    ..load(mockUser);
  return MultiProvider(
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
    ],
    child: wrap(page, locale: locale),
  );
}

void main() {
  setUpAll(initTestEnv);

  for (final (w, h) in [(360.0, 800.0), (412.0, 917.0)]) {
    for (final scale in [1.5, 2.0]) {
      for (final locale in [const Locale('tr'), const Locale('en')]) {
        testWidgets(
          'Ayarlar başlıkları tek satır, kesilmez: ${w.toInt()}×${h.toInt()} '
          '×$scale ${locale.languageCode}',
          (tester) async {
            useAndroidScreen(tester);
            tester.view.physicalSize = Size(w * 2, h * 2);
            tester.view.padding = const FakeViewPadding(top: 80, bottom: 96);
            tester.view.viewPadding = const FakeViewPadding(
              top: 80,
              bottom: 96,
            );
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            for (final page in _pages) {
              await tester.pumpWidget(_host(page, locale));
              await tester.pump(const Duration(seconds: 1));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: '$page');
              final title = find.byKey(const Key('settings-title'));
              expect(title, findsOneWidget, reason: '$page');
              final text = tester.widget<Text>(title);
              expect(text.maxLines, 1);
              final paragraph = tester.renderObject<RenderParagraph>(
                find.descendant(of: title, matching: find.byType(RichText)),
              );
              // Tek satıra sığar: ne ikinci satır ne üç nokta.
              expect(
                paragraph.didExceedMaxLines,
                isFalse,
                reason: '${text.data} ($page)',
              );
              // Ölçek sınırı uygulanır.
              final scaler = MediaQuery.textScalerOf(tester.element(title));
              expect(
                scaler.scale(10) / 10,
                lessThanOrEqualTo(SettingsScaffold.maxTitleTextScale + 1e-6),
              );
              // Başlık üst barın içinde kalır.
              final bar = tester.getRect(
                find
                    .ancestor(of: title, matching: find.byType(Container))
                    .first,
              );
              final r = tester.getRect(title);
              expect(r.bottom, lessThanOrEqualTo(bar.bottom), reason: '$page');
            }
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
