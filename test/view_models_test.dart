import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/models.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/create_listing/viewmodel/create_listing_view_model.dart';
import 'package:bende_var/features/home/viewmodel/home_view_model.dart';
import 'package:bende_var/features/messages/viewmodel/messages_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthViewModel', () {
    test('iki alan dolmadan gönderilemez', () {
      final vm = AuthViewModel(MockAuthRepository());
      expect(vm.canSubmit, isFalse);
      vm.setEmail('ad@okul.edu.tr');
      expect(vm.canSubmit, isFalse);
      vm.setPassword('123');
      expect(vm.canSubmit, isTrue);
    });

    test('.edu.tr olmayan e-posta ile giriş başarısız', () async {
      final vm = AuthViewModel(MockAuthRepository())
        ..setEmail('ad@gmail.com')
        ..setPassword('123');
      expect(await vm.signIn(), isFalse);
      expect(vm.isSignedIn, isFalse);
      expect(vm.emailError, isNotNull);
    });

    test('geçerli bilgilerle giriş ve çıkış', () async {
      final vm = AuthViewModel(MockAuthRepository())
        ..setEmail('ad@okul.edu.tr')
        ..setPassword('123');
      expect(await vm.signIn(), isTrue);
      expect(vm.isSignedIn, isTrue);
      await vm.signOut();
      expect(vm.isSignedIn, isFalse);
    });
  });

  group('HomeViewModel', () {
    late HomeViewModel vm;
    setUp(() => vm = HomeViewModel(MockListingRepository()));
    tearDown(() => vm.dispose());

    test('varsayılan olarak ilanlar, en yeni önde', () {
      expect(vm.kind, ListingKind.ilan);
      final list = vm.visible;
      expect(list, isNotEmpty);
      expect(list.every((l) => l.kind == ListingKind.ilan), isTrue);
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].postedAt.isAfter(list[i].postedAt), isTrue);
      }
    });

    test('ihtiyaçlara geçince yalnız ihtiyaçlar gelir', () {
      vm.setKind(ListingKind.ihtiyac);
      expect(vm.visible.every((l) => l.kind == ListingKind.ihtiyac), isTrue);
    });

    test('kategori ve arama filtreleri çalışır', () {
      vm.setCategory(ListingCategory.sports);
      expect(
        vm.visible.every((l) => l.category == ListingCategory.sports),
        isTrue,
      );
      vm.setCategory(ListingCategory.sports); // tekrar basınca kalkar
      expect(vm.category, isNull);
      vm.setQuery('casio');
      expect(vm.visible.single.title, contains('Casio'));
    });

    test('favori aç/kapa ve favori filtresi', () async {
      await vm.toggleFavorite('l1');
      await Future<void>.delayed(Duration.zero);
      vm.toggleOnlyFavorites();
      expect(vm.visible.map((l) => l.id), ['l1']);
      await vm.toggleFavorite('l1');
      await Future<void>.delayed(Duration.zero);
      expect(vm.visible, isEmpty);
    });
  });

  group('CreateListingViewModel', () {
    test('boş form yayınlanmaz, hata gösterilir', () async {
      final repo = MockListingRepository();
      final vm = CreateListingViewModel(
        kind: ListingKind.ilan,
        repo: repo,
        ownerName: 'Elif Y.',
      );
      expect(await vm.publish(), isNull);
      expect(vm.titleError, isNotNull);
      expect(vm.categoryError, isTrue);
      expect(vm.conditionError, isTrue);
      expect(vm.datesError, isTrue);
    });

    test('geçerli ilan yayınlanır ve listenin en üstüne eklenir', () async {
      final repo = MockListingRepository();
      final vm =
          CreateListingViewModel(
              kind: ListingKind.ilan,
              repo: repo,
              ownerName: 'Elif Y.',
            )
            ..setTitle('Fizik 1 soru bankası')
            ..setCategory(ListingCategory.book)
            ..setCondition(ListingCondition.lightlyUsed)
            ..setFrom(DateTime(2026, 11, 10))
            ..setTo(DateTime(2026, 11, 24));
      final listing = await vm.publish();
      expect(listing, isNotNull);
      expect(repo.current.first.id, listing!.id);
      expect(repo.current.first.title, 'Fizik 1 soru bankası');
    });

    test('ihtiyaçta ücretli seçilip tutar girilmezse yayınlanmaz', () async {
      final vm =
          CreateListingViewModel(
              kind: ListingKind.ihtiyac,
              repo: MockListingRepository(),
              ownerName: 'Elif Y.',
            )
            ..setTitle('Calculus')
            ..setCategory(ListingCategory.book)
            ..setFrom(DateTime(2026, 12, 1))
            ..setTo(DateTime(2026, 12, 14))
            ..setPaid(true);
      expect(await vm.publish(), isNull);
      expect(vm.priceError, isTrue);
      vm.setPriceText('30');
      expect(await vm.publish(), isNotNull);
    });

    test('bitiş tarihi başlangıçtan önce olamaz', () {
      final vm =
          CreateListingViewModel(
              kind: ListingKind.ihtiyac,
              repo: MockListingRepository(),
              ownerName: 'x',
            )
            ..setFrom(DateTime(2026, 12, 10))
            ..setTo(DateTime(2026, 12, 1));
      expect(vm.isValid, isFalse);
    });
  });

  group('Mesajlar', () {
    test('gönderilen mesaj sohbete eklenir, boş mesaj gönderilmez', () async {
      final repo = MockChatRepository();
      final vm = ChatViewModel(repo, 'c3');
      final before = vm.chat!.messages.length;
      expect(await vm.send('   '), isFalse);
      expect(await vm.send('Teşekkürler'), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(vm.chat!.messages.length, before + 1);
      expect(vm.chat!.last.text, 'Teşekkürler');
      expect(vm.chat!.last.fromMe, isTrue);
      vm.dispose();
    });

    test('okunmamış filtresi ve sohbet açılınca okundu', () async {
      final repo = MockChatRepository();
      final list = MessagesViewModel(repo);
      expect(list.unreadCount, 2);
      list.setFilter(MessageFilter.unread);
      expect(list.visible.length, 2);
      final chat = ChatViewModel(repo, 'c1');
      await Future<void>.delayed(Duration.zero);
      expect(list.unreadCount, 1);
      chat.dispose();
      list.dispose();
    });

    test('bildirimler: tümünü okundu yap rozeti sıfırlar', () async {
      final vm = NotificationsViewModel(MockNotificationRepository());
      expect(vm.unreadCount, 3);
      await vm.markAllRead();
      await Future<void>.delayed(Duration.zero);
      expect(vm.unreadCount, 0);
      vm.dispose();
    });
  });
}
