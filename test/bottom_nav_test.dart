import 'package:bende_var/core/widgets/bende_var_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  Widget nav({
    int? selected = 0,
    int badge = 3,
    void Function(int)? onSelect,
    VoidCallback? onLogo,
  }) => wrap(
    Align(
      alignment: Alignment.bottomCenter,
      child: BendeVarBottomNav(
        selectedIndex: selected,
        notificationBadge: badge,
        onSelect: onSelect ?? (_) {},
        onLogoTap: onLogo ?? () {},
      ),
    ),
  );

  testWidgets('beş öğe: ev, mesaj, logo, zil, kullanıcı; etiket yok', (
    tester,
  ) async {
    useAndroidScreen(tester);
    await tester.pumpWidget(nav());
    expect(find.byIcon(LucideIcons.house), findsOneWidget);
    expect(find.byIcon(LucideIcons.messageCircle), findsOneWidget);
    expect(find.byKey(const Key('nav-logo')), findsOneWidget);
    expect(find.byIcon(LucideIcons.bell), findsOneWidget);
    expect(find.byIcon(LucideIcons.user), findsOneWidget);
    // Sadece rozet sayısı metin olarak görünür.
    expect(find.byType(Text), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('yükseklik 76, dokunma alanları en az 48', (tester) async {
    useAndroidScreen(tester);
    await tester.pumpWidget(nav());
    expect(tester.getSize(find.byType(BendeVarBottomNav)).height, 76);
    final logo = tester.getSize(find.byKey(const Key('nav-logo')));
    expect(logo.width, greaterThanOrEqualTo(48));
    expect(logo.height, greaterThanOrEqualTo(48));
  });

  testWidgets('rozet 0 ise gizlenir', (tester) async {
    useAndroidScreen(tester);
    await tester.pumpWidget(nav(badge: 0));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('sekme ve logo dokunuşları', (tester) async {
    useAndroidScreen(tester);
    final taps = <int>[];
    var logo = 0;
    await tester.pumpWidget(nav(onSelect: taps.add, onLogo: () => logo++));
    await tester.tap(find.byIcon(LucideIcons.messageCircle));
    await tester.tap(find.byIcon(LucideIcons.bell));
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.tap(find.byKey(const Key('nav-logo')));
    expect(taps, [1, 2, 3]);
    expect(logo, 1);
  });

  testWidgets(
    'seçili sekme işaretli, logo paneli açıkken hiçbiri seçili değil',
    (tester) async {
      useAndroidScreen(tester);
      bool selected(String label) => tester
          .getSemantics(find.bySemanticsLabel(RegExp('^$label')))
          .flagsCollection
          .isSelected
          .toString()
          .contains('isTrue');
      await tester.pumpWidget(nav(selected: 1));
      expect(selected('Mesajlar'), isTrue);
      expect(selected('Ana sayfa'), isFalse);
      await tester.pumpWidget(nav(selected: null));
      for (final label in ['Ana sayfa', 'Mesajlar', 'Bildirimler', 'Profil']) {
        expect(selected(label), isFalse, reason: label);
      }
    },
  );
}
