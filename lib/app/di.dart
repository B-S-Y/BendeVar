import '../data/mock/mock_repositories.dart';
import '../data/repositories/repositories.dart';

/// Bağımlılık kurulumu. Mock'tan Firebase'e geçiş: aşağıdaki satırlarda
/// `Mock*Repository` yerine `Firebase*Repository` verilir (README).
class AppDependencies {
  AppDependencies({
    AuthRepository? auth,
    ListingRepository? listings,
    ChatRepository? chats,
    NotificationRepository? notifications,
    UserRepository? users,
    CommunityRepository? communities,
  }) : auth = auth ?? MockAuthRepository(),
       listings = listings ?? MockListingRepository(),
       chats = chats ?? MockChatRepository(),
       notifications = notifications ?? MockNotificationRepository(),
       users = users ?? MockUserRepository(),
       communities = communities ?? MockCommunityRepository();

  final AuthRepository auth;
  final ListingRepository listings;
  final ChatRepository chats;
  final NotificationRepository notifications;
  final UserRepository users;
  final CommunityRepository communities;
}
