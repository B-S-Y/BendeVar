import 'package:bende_var/core/utils/text_search.dart';
import 'package:bende_var/data/mock/mock_data.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalize: Türkçe harfler ve büyük/küçük harf', () {
    expect(TextSearch.normalize('İstanbul'), 'istanbul');
    expect(TextSearch.normalize('ISTANBUL'), 'istanbul');
    expect(TextSearch.normalize('ıspanak'), 'ispanak');
    expect(TextSearch.normalize('Açık Şğüö'), 'acik sguo');
    expect(TextSearch.normalize('  T  '), 't');
  });

  test('matches: iki yönde aynı fonksiyon', () {
    expect(TextSearch.matches('Topluluk', 'T'), isTrue);
    expect(TextSearch.matches('Topluluk', 't'), isTrue);
    expect(TextSearch.matches('Açık Hava', 'AÇIK'), isTrue);
    expect(TextSearch.matches('Açık Hava', 'acik'), isTrue);
    expect(TextSearch.matches('İstanbul Gezginleri', 'İstanbul'), isTrue);
    expect(TextSearch.matches('İstanbul Gezginleri', 'istanbul'), isTrue);
    expect(TextSearch.matches('Istanbul', 'İSTANBUL'), isTrue);
    expect(TextSearch.matches('Kamp', 'zzz'), isFalse);
  });

  test('Topluluk araması: T, t, AÇIK, acik, İstanbul', () async {
    final vm = CommunityViewModel(MockCommunityRepository());
    await vm.load(mockUser);
    Future<List<String>> ids(String q) async {
      await vm.setQuery(q);
      return vm.results.map((c) => c.id).toList();
    }

    // "T"/"t": adında t geçenler (Yurt, Topluluğu, İstanbul, Hava Sporları...).
    expect(await ids('T'), await ids('t'));
    expect(await ids('t'), contains('yurt'));
    expect(await ids('t'), contains('istanbul'));
    expect(await ids('AÇIK'), ['acik']);
    expect(await ids('acik'), ['acik']);
    expect(await ids('açık'), ['acik']);
    expect(await ids('İstanbul'), ['istanbul']);
    expect(await ids('istanbul'), ['istanbul']);
    expect(await ids('ISTANBUL'), ['istanbul']);
  });
}
