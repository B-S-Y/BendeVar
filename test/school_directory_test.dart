import 'dart:convert';
import 'dart:io';

import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/core/utils/text_search.dart';
import 'package:bende_var/core/utils/validators.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/school_directory.dart';
import 'package:bende_var/features/auth/view/signup_page.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  late SchoolDirectory dir;
  setUpAll(() async => dir = await SchoolDirectory.loadShared());

  group('JSON bütünlüğü', () {
    final raw = jsonDecode(
      File(SchoolDirectory.assetPath).readAsStringSync(encoding: utf8),
    ) as List;
    final rows = raw.cast<Map<String, dynamic>>();

    test('id\'ler benzersiz', () {
      final ids = rows.map((r) => r['id'] as String).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('alias hiçbir id ya da başka alias ile çakışmıyor', () {
      final seen = <String>{};
      for (final r in rows) {
        seen.add(TextSearch.normalize(r['id'] as String));
      }
      expect(
        seen.length,
        rows.length,
        reason: 'id\'ler normalize edilince de benzersiz',
      );
      for (final r in rows) {
        for (final a in (r['aliases'] as List).cast<String>()) {
          expect(
            seen.add(TextSearch.normalize(a)),
            isTrue,
            reason: 'alias çakışması: $a',
          );
        }
      }
    });

    test('her kayıtta name_tr ve name_en dolu', () {
      for (final r in rows) {
        expect(
          (r['name_tr'] as String?)?.trim(),
          isNotEmpty,
          reason: '${r['id']}',
        );
        expect(
          (r['name_en'] as String?)?.trim(),
          isNotEmpty,
          reason: '${r['id']}',
        );
        expect(r.containsKey('name_tr_taslak'), isFalse);
      }
    });

    test('eski kimlikler alias, kayıt değil', () {
      for (final old in [
        'ybu',
        'ohu',
        'gata',
        'gyte',
        'karaelmas',
        'dho',
        'hho',
      ]) {
        expect(rows.any((r) => r['id'] == old), isFalse, reason: old);
      }
    });
  });

  group('okul bulma', () {
    test('bilinen kimlik', () {
      expect(dir.find('yildiz')?.nameTr, 'Yıldız Teknik Üniversitesi');
      expect(dir.find('ku')?.nameTr, 'Koç Üniversitesi');
    });

    test('alias → asıl okul', () {
      expect(dir.find('ybu')?.id, 'aybu');
      expect(dir.find('ybu')?.nameTr, 'Ankara Yıldırım Beyazıt Üniversitesi');
      expect(dir.find('gyte')?.nameTr, 'Gebze Teknik Üniversitesi');
      expect(dir.find('ohu')?.id, 'nigde');
      expect(dir.find('gata')?.id, 'sbu');
      expect(dir.find('karaelmas')?.id, 'beun');
      expect(dir.find('dho')?.id, 'msu');
      expect(dir.find('hho')?.id, 'msu');
      expect(dir.find('boun')?.id, 'bogazici');
      expect(dir.find('ayvansaray')?.id, 'topkapi');
      expect(
        dir.find('msgsu')?.nameTr,
        'Mimar Sinan Güzel Sanatlar Üniversitesi',
      );
      expect(dir.find('msu')?.nameEn, 'National Defence University');
    });

    test('bilinmeyen kimlik', () {
      expect(dir.find('xyz'), isNull);
      expect(dir.find('gmail'), isNull);
    });

    test('büyük/küçük harf ve Türkçe karakter fark etmez', () {
      expect(dir.find('YILDIZ')?.id, 'yildiz');
      expect(dir.find('Yıldız')?.id, 'yildiz');
      expect(dir.find('YILDIZ')?.id, 'yildiz');
      expect(dir.find('İstanbul')?.id, 'istanbul');
      expect(dir.find('ISTANBUL')?.id, 'istanbul');
      expect(dir.find('boğaziçi')?.id, 'bogazici');
      expect(dir.find('KOÇ'), isNull); // 'koc' kimlik değil
      expect(dir.find('Ku')?.id, 'ku');
    });

    test('ön ekli adres okul kimliğini bozmaz', () {
      expect(Validators.schoolId('ali@st.biruni.edu.tr'), 'biruni');
      expect(
        dir.find(Validators.schoolId('ali@st.biruni.edu.tr')!)?.id,
        'biruni',
      );
      expect(Validators.schoolId('ali@ogr.msgsu.edu.tr'), 'msgsu');
      expect(Validators.schoolId('ali@sabanciuniv.edu'), isNull);
    });
  });

  group('okul topluluğu (repository)', () {
    final repo = MockCommunityRepository();

    test('TR ve EN ad', () async {
      final c = (await repo.findBySchool('gyte'))!;
      expect(c.id, 'gtu');
      expect(c.localizedName('tr'), 'Gebze Teknik Üniversitesi');
      expect(c.localizedName('en'), 'Gebze Technical University');
    });

    test('bilinmeyen okul ilk kayıtla açılır', () async {
      expect(await repo.findBySchool('yenikurum'), isNull);
      final c = await repo.joinOrCreate('yenikurum');
      expect(c.id, 'yenikurum');
      expect((await repo.findBySchool('yenikurum'))?.id, 'yenikurum');
    });

    test('alias ile katılınca asıl okul topluluğu gelir', () async {
      final c = await repo.joinOrCreate('ybu');
      expect(c.id, 'aybu');
    });
  });

  testWidgets('okul kartı seçili dilde (EN) gösterir', (tester) async {
    useAndroidScreen(tester);
    final vm = AuthViewModel(
      MockAuthRepository(verifyAfter: Duration.zero),
      communities: MockCommunityRepository(),
      schoolLookupDelay: AppMotion.schoolLookupDelay,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: wrap(const SignupPage(), locale: const Locale('en')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const Key('signup-email-field')),
      'ali@gyte.edu.tr',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Gebze Technical University'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
