import 'package:bende_var/core/widgets/envelope_animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

double _badgeScale(WidgetTester tester) {
  final t = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byIcon(LucideIcons.check),
          matching: find.byType(Transform),
        )
        .first,
  );
  return t.transform.storage[0];
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('Zarf: bir kez oynar, açık zarf ve tikle durur', (tester) async {
    useAndroidScreen(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    // Başta tik yok (ölçek 0).
    expect(_badgeScale(tester), 0);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_badgeScale(tester), 0);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_badgeScale(tester), greaterThan(0));
    // Süre dolunca durur; tik 1,0'da kalır, animasyon sürmez.
    await tester.pumpAndSettle();
    expect(_badgeScale(tester), closeTo(1, 1e-6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Zarf: animasyonları azalt açıkken doğrudan son kare', (
    tester,
  ) async {
    useAndroidScreen(tester); // animasyonlar kapalı
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    expect(_badgeScale(tester), closeTo(1, 1e-6));
    expect(tester.takeException(), isNull);
  });
}
