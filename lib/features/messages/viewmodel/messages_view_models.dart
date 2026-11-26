import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

enum MessageFilter { all, unread }

class MessagesViewModel extends ChangeNotifier {
  MessagesViewModel(this._repo) {
    _chats = _repo.current;
    _sub = _repo.watchChats().listen((c) {
      _chats = c;
      notifyListeners();
    });
  }

  final ChatRepository _repo;
  StreamSubscription<List<Chat>>? _sub;
  List<Chat> _chats = const [];
  MessageFilter _filter = MessageFilter.all;

  MessageFilter get filter => _filter;
  int get unreadCount => _chats.where((c) => c.unread > 0).length;

  List<Chat> get visible => _filter == MessageFilter.all
      ? _chats
      : _chats.where((c) => c.unread > 0).toList();

  void setFilter(MessageFilter f) {
    _filter = f;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._repo, this.chatId) {
    _chat = _repo.byId(chatId);
    _repo.markRead(chatId);
    _sub = _repo.watchChats().listen((_) {
      _chat = _repo.byId(chatId);
      notifyListeners();
    });
  }

  final ChatRepository _repo;
  final String chatId;
  StreamSubscription<List<Chat>>? _sub;
  Chat? _chat;

  Chat? get chat => _chat;

  /// Boş mesaj gönderilmez.
  Future<bool> send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return false;
    await _repo.sendMessage(chatId, t);
    return true;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel(this._repo) {
    _items = _repo.current;
    _sub = _repo.watchNotifications().listen((n) {
      _items = n;
      notifyListeners();
    });
  }

  final NotificationRepository _repo;
  StreamSubscription<List<AppNotification>>? _sub;
  List<AppNotification> _items = const [];

  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Yaklaşan iadeler: gecikmiş ve yaklaşan.
  List<AppNotification> get returns => _items
      .where(
        (n) =>
            n.type == NotificationType.overdue ||
            n.type == NotificationType.dueSoon,
      )
      .toList();

  List<AppNotification> today(DateTime now) =>
      _others.where((n) => _sameDay(n.createdAt, now)).toList();

  List<AppNotification> thisWeek(DateTime now) =>
      _others.where((n) => !_sameDay(n.createdAt, now)).toList();

  Iterable<AppNotification> get _others => _items.where(
    (n) =>
        n.type != NotificationType.overdue &&
        n.type != NotificationType.dueSoon,
  );

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> markAllRead() => _repo.markAllRead();
  Future<void> markRead(String id) => _repo.markRead(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
