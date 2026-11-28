import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

/// Ekran görüntüsü üretir (görsel karşılaştırma için); SHOTS=1 ile çalışır.
void main() {
  setUpAll(initTestEnv);
  final enabled = Platform.environment['SHOTS'] == '1';

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('tool_shots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('shots $theme', (tester) async {
      final t = theme.name;
      await pumpApp(tester, theme: theme);
      await shot(tester, '1_welcome_$t');
      await signIn(tester);
      await shot(tester, '2_home_$t');
      await tester.tap(find.byIcon(LucideIcons.messageCircle));
      await tester.pumpAndSettle();
      await shot(tester, '3_messages_$t');
      await tester.tap(find.byIcon(LucideIcons.bell));
      await tester.pumpAndSettle();
      await shot(tester, '4_notifications_$t');
      await tester.tap(find.byIcon(LucideIcons.user));
      await tester.pumpAndSettle();
      await shot(tester, '5_profile_$t');
      await tester.tap(find.byIcon(LucideIcons.house));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-logo')));
      await tester.pumpAndSettle();
      await shot(tester, '6_create_sheet_$t');
    }, skip: !enabled);
  }
}
