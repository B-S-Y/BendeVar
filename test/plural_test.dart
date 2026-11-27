import 'package:bende_var/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test(
    'Üye sayısı ICU çoğulu: EN 1 member / 2 members, TR tek biçim',
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final tr = await AppLocalizations.delegate.load(const Locale('tr'));
      expect(en.communityMembers(1), '1 member');
      expect(en.communityMembers(2), '2 members');
      expect(en.communityMembers(0), '0 members');
      expect(tr.communityMembers(1), '1 üye');
      expect(tr.communityMembers(2), '2 üye');
    },
  );
}
