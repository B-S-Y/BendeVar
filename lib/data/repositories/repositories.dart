/// Soyut repository'ler. Mock: lib/data/mock. Firebase*Repository bunların
/// yerine DI'da (lib/app/di.dart) tek satırla takılır.
library;

import '../models/models.dart';

abstract class AuthRepository {
  AppUser? get currentUser;
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
}

abstract class ListingRepository {
  Stream<List<Listing>> watchListings();
  List<Listing> get current;
  Listing? byId(String id);
  Future<Listing> add(Listing listing);
  Future<void> toggleFavorite(String id);
  Future<String> nextId();
}

abstract class ChatRepository {
  Stream<List<Chat>> watchChats();
  List<Chat> get current;
  Chat? byId(String id);
  Future<void> sendMessage(String chatId, String text);
  Future<void> markRead(String chatId);
}

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications();
  List<AppNotification> get current;
  Future<void> markAllRead();
  Future<void> markRead(String id);
}

abstract class UserRepository {
  Future<List<Loan>> loans(LoanDirection direction);
  Future<List<PendingItem>> pending();
  Future<int> count(LoanDirection direction);
}
