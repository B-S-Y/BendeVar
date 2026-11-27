import 'dart:async';

import '../models/models.dart';
import '../repositories/repositories.dart';
import 'mock_data.dart';

const Duration _latency = Duration(milliseconds: 250);

class _PendingSignUp {
  _PendingSignUp(this.password, this.sentAt);
  final String password;
  DateTime sentAt;
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    List<MockAccount>? accounts,
    this.verifyAfter = const Duration(seconds: 8),
  }) : _accounts = List.of(accounts ?? mockAccounts);

  final List<MockAccount> _accounts;
  final Map<String, _PendingSignUp> _pending = {};
  AppUser? _user;
  final Map<String, int> _failures = {};

  /// Bu kadar yanlış şifreden sonra hesap geçici kilitlenir (uygulama
  /// yeniden açılana kadar).
  static const int maxFailures = 3;

  /// Kayıtta doğrulama bağlantısına "tıklanması" bu süre sonra taklit edilir.
  final Duration verifyAfter;

  /// Bu önekle başlayan e-postalarda bağlantı süresi dolar (1.12).
  static const String expiredPrefix = 'suredoldu';

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final pending = _pending[key];
    final account = _accounts.where((a) => a.email == key).firstOrNull;
    if (account == null && pending == null) {
      throw const AuthException(AuthFailure.accountNotFound);
    }
    if ((_failures[key] ?? 0) >= maxFailures) {
      throw const AuthException(AuthFailure.tooManyAttempts);
    }
    final expected = account?.password ?? pending!.password;
    if (password != expected) {
      _failures[key] = (_failures[key] ?? 0) + 1;
      throw const AuthException(AuthFailure.wrongPassword);
    }
    _failures.remove(key);
    // Gerçekte: giriş olur, sonra e-posta doğrulaması denetlenir (1.04).
    if (account == null || !account.verified) {
      throw const AuthException(AuthFailure.notVerified);
    }
    _user = account.user;
    return account.user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(_latency);
    _user = null;
  }

  @override
  Future<void> sendVerification(String email) async {
    await Future<void>.delayed(_latency);
    _pending[email.trim().toLowerCase()]?.sentAt = DateTime.now();
  }

  @override
  Future<void> signUp(String email, String password) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    if (_accounts.any((a) => a.email == key) || _pending.containsKey(key)) {
      throw const AuthException(AuthFailure.emailInUse);
    }
    _pending[key] = _PendingSignUp(password, DateTime.now());
  }

  @override
  Future<VerificationStatus> checkVerification(String email) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final pending = _pending[key];
    if (pending == null) return VerificationStatus.verified;
    if (DateTime.now().difference(pending.sentAt) < verifyAfter) {
      return VerificationStatus.pending;
    }
    return key.startsWith(expiredPrefix)
        ? VerificationStatus.expired
        : VerificationStatus.verified;
  }

  @override
  Future<AppUser> completeSignUp({
    required String email,
    required String displayName,
    required Community community,
  }) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final pending = _pending.remove(key);
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final short = parts.length > 1
        ? '${parts.first} ${parts.last[0].toUpperCase()}.'
        : parts.first;
    final user = AppUser(
      id: 'u-${key.split('@').first}',
      displayName: displayName.trim(),
      shortName: short,
      email: key,
      community: community,
      department: '',
      bio: '',
      rating: 0,
      transactions: 0,
      onTimeRate: 0,
    );
    _accounts.add(
      MockAccount(
        email: key,
        password: pending?.password ?? mockPassword,
        user: user,
      ),
    );
    _user = user;
    return user;
  }
}

class MockCommunityRepository implements CommunityRepository {
  MockCommunityRepository()
    : _bySchool = {'yildiz': mockCommunity, 'marmara': mockMarmara};

  final Map<String, Community> _bySchool;

  @override
  Future<Community?> findBySchool(String schoolId) async => _bySchool[schoolId];

  @override
  Future<Community> joinOrCreate(String schoolId) async {
    await Future<void>.delayed(_latency);
    return _bySchool.putIfAbsent(schoolId, () {
      final name = schoolId[0].toUpperCase() + schoolId.substring(1);
      return Community(id: schoolId, name: name, shortName: name);
    });
  }
}

class MockListingRepository implements ListingRepository {
  MockListingRepository() : _items = seedListings();

  final List<Listing> _items;
  final StreamController<List<Listing>> _ctrl =
      StreamController<List<Listing>>.broadcast();
  int _seq = 100;

  void _emit() => _ctrl.add(List.unmodifiable(_items));

  @override
  List<Listing> get current => List.unmodifiable(_items);

  @override
  Stream<List<Listing>> watchListings() => Stream.multi((c) {
    c.add(current);
    final sub = _ctrl.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  @override
  Listing? byId(String id) {
    for (final l in _items) {
      if (l.id == id) return l;
    }
    return null;
  }

  @override
  Future<String> nextId() async => 'new-${_seq++}';

  @override
  Future<Listing> add(Listing listing) async {
    await Future<void>.delayed(_latency);
    _items.insert(0, listing);
    _emit();
    return listing;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final i = _items.indexWhere((l) => l.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isFavorite: !_items[i].isFavorite);
    _emit();
  }
}

class MockChatRepository implements ChatRepository {
  MockChatRepository() : _chats = seedChats();

  final List<Chat> _chats;
  final StreamController<List<Chat>> _ctrl =
      StreamController<List<Chat>>.broadcast();
  int _seq = 0;

  @override
  List<Chat> get current => List.unmodifiable(_chats);

  @override
  Stream<List<Chat>> watchChats() => Stream.multi((c) {
    c.add(current);
    final sub = _ctrl.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  @override
  Chat? byId(String id) {
    for (final c in _chats) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _emit() => _ctrl.add(List.unmodifiable(_chats));

  @override
  Future<void> sendMessage(String chatId, String text) async {
    final i = _chats.indexWhere((c) => c.id == chatId);
    if (i < 0) return;
    final msg = Message(
      id: 'sent-${_seq++}',
      text: text,
      sentAt: DateTime.now(),
      fromMe: true,
    );
    final chat = _chats.removeAt(i);
    // Son yazışma en üstte görünür.
    _chats.insert(0, chat.copyWith(messages: [...chat.messages, msg]));
    _emit();
  }

  @override
  Future<void> markRead(String chatId) async {
    final i = _chats.indexWhere((c) => c.id == chatId);
    if (i < 0 || _chats[i].unread == 0) return;
    _chats[i] = _chats[i].copyWith(unread: 0);
    _emit();
  }
}

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository() : _items = seedNotifications();

  final List<AppNotification> _items;
  final StreamController<List<AppNotification>> _ctrl =
      StreamController<List<AppNotification>>.broadcast();

  @override
  List<AppNotification> get current => List.unmodifiable(_items);

  @override
  Stream<List<AppNotification>> watchNotifications() => Stream.multi((c) {
    c.add(current);
    final sub = _ctrl.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  void _emit() => _ctrl.add(List.unmodifiable(_items));

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    _emit();
  }

  @override
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isRead: true);
    _emit();
  }
}

class MockUserRepository implements UserRepository {
  final List<Loan> _loans = seedLoans();

  @override
  Future<List<Loan>> loans(LoanDirection direction) async {
    await Future<void>.delayed(_latency);
    return _loans.where((l) => l.direction == direction).toList();
  }

  @override
  Future<int> count(LoanDirection direction) async =>
      _loans.where((l) => l.direction == direction).length;

  @override
  Future<List<PendingItem>> pending() async {
    await Future<void>.delayed(_latency);
    return [
      const PendingItem(
        kind: PendingKind.newResponses,
        itemTitle: 'Kamp sandalyesi',
        count: 2,
      ),
      const PendingItem(kind: PendingKind.overdue, itemTitle: 'Darbeli matkap'),
      PendingItem(
        kind: PendingKind.handover,
        itemTitle: 'Kamp sandalyesi',
        when: DateTime(DateTime.now().year, 11, 21, 14),
      ),
    ];
  }
}
