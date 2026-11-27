/// Soyut repository'ler. Mock: lib/data/mock. Firebase*Repository bunların
/// yerine DI'da (lib/app/di.dart) tek satırla takılır.
library;

import '../models/models.dart';

/// Giriş hatası türleri (1.03b, 1.03c, 1.04).
enum AuthFailure {
  accountNotFound,
  wrongPassword,
  tooManyAttempts,
  notVerified,
  emailInUse,
}

/// Doğrulama bağlantısı durumu (1.09 → 1.10 / 1.12).
enum VerificationStatus { pending, verified, expired }

class AuthException implements Exception {
  const AuthException(this.failure);
  final AuthFailure failure;

  @override
  String toString() => 'AuthException($failure)';
}

abstract class AuthRepository {
  AppUser? get currentUser;

  /// Başarısızlıkta [AuthException] fırlatır.
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();

  /// Doğrulama bağlantısını (yeniden) gönderir.
  Future<void> sendVerification(String email);

  /// Kayıt (1.08): hesabı açar ve doğrulama bağlantısını gönderir.
  /// E-posta kayıtlıysa [AuthFailure.emailInUse] fırlatır.
  Future<void> signUp(String email, String password);

  /// Bağlantıya tıklandı mı? (Firebase: kullanıcıyı yenile, `emailVerified`.)
  Future<VerificationStatus> checkVerification(String email);

  /// Şifre sıfırlama bağlantısı gönderir (1.05). Hesap var mı yok mu
  /// açıklanmaz (güvenlik): her geçerli e-posta için başarılı döner.
  Future<void> requestPasswordReset(String email);

  /// Sıfırlama bağlantısına tıklandı mı? (1.06; Firebase'de bağlantı uygulamayı
  /// açar ve kod doğrulanır.)
  Future<VerificationStatus> checkPasswordReset(String email);

  /// Yeni şifreyi kaydeder (1.07).
  Future<void> confirmPasswordReset(String email, String newPassword);

  /// Ad Soyad (1.10) ile kaydı bitirir ve oturumu açar.
  Future<AppUser> completeSignUp({
    required String email,
    required String displayName,
    required Community community,
  });
}

/// Topluluklar. Okul kimliği = `.edu.tr`'den önceki son kelime.
abstract class CommunityRepository {
  /// Okul kimliğine ait topluluk; yoksa null.
  Future<Community?> findBySchool(String schoolId);

  /// Varsa katılır, yoksa ilk kayıtta topluluğu açar.
  Future<Community> joinOrCreate(String schoolId);
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
