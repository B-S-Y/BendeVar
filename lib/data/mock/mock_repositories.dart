import 'dart:async';

import '../models/models.dart';
import '../repositories/repositories.dart';
import 'mock_data.dart';

const Duration _latency = Duration(milliseconds: 250);

class MockAuthRepository implements AuthRepository {
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(_latency);
    _user = mockUser;
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(_latency);
    _user = null;
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
