import 'package:bende_var/features/auth/view/help_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  testWidgets('Yardım ve destek: Ayarlar\'dan açılır, 3 soru-cevap, e-posta', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gizlilik ve destek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yardım ve destek'));
    await tester.pumpAndSettle();

    // "Yakında" değil, gerçek sayfa.
    expect(find.text('Yakında'), findsNothing);
    expect(find.byType(HelpPage), findsOneWidget);
    expect(
      find.text('Takıldığın bir şey mi var? Sık sorulanlara göz at.'),
      findsOneWidget,
    );
    expect(find.byType(ExpansionTile), findsNWidgets(3));
    expect(find.text('destek@bendevar.app'), findsOneWidget);

    // Cevap önce kapalı, soruya dokununca açılır.
    expect(find.textContaining('6 haneli davet koduyla'), findsNothing);
    await tester.tap(find.text('Bir topluluğa nasıl katılırım?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6 haneli davet koduyla'), findsOneWidget);
    await tester.tap(find.text('Beni hatırla ne işe yarar?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('giriş yapmadan devam edersin'), findsOneWidget);
    await tester.tap(find.text('Şifremi unuttum, ne yapmalıyım?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('yenileme bağlantısı'), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Kullanım şartları'), findsOneWidget);
  });

  testWidgets('Yardım sayfası EN ve küçük ekranda taşmaz', (tester) async {
    useAndroidScreen(tester);
    tester.view.physicalSize = const Size(640, 1136);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(wrap(const HelpPage(), locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Help and support'), findsOneWidget);
    expect(
      find.text('support@bendevar.app', skipOffstage: false),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
