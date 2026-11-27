/// Soyut repository'ler. Mock: lib/data/mock. Firebase*Repository bunların
/// yerine DI'da (lib/app/di.dart) tek satırla takılır.
library;

import '../models/community_models.dart';
import '../models/models.dart';
import '../models/settings_models.dart';

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

  /// Başarısızlıkta [AuthException] fırlatır. [remember] açıksa (ve hesap
  /// doğrulanmışsa) oturum uygulama kapanıp açılınca korunur.
  Future<AppUser> signIn(
    String email,
    String password, {
    bool remember = false,
  });

  /// Açılışta: "Beni hatırla" ile kalan oturum varsa kullanıcıyı açar.
  Future<AppUser?> restoreSession();

  /// Oturumu kapatır ve hatırlanan oturumu siler.
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

  /// Üyesi olunan topluluklar (okul topluluğu en üstte, ayrılınamaz).
  /// [userId] kullanıcısının üyelikleri; okul topluluğuna otomatik üyedir.
  /// Sonraki arama/katılma/oluşturma çağrıları bu kullanıcı için yapılır.
  Future<List<CommunityInfo>> myCommunities({
    required String userId,
    required Community school,
  });

  /// 1.16g · Ada göre arama. Gizli topluluklar çıkmaz; okula özel olanlar
  /// yalnızca o okulun üyelerine çıkar.
  Future<List<CommunityInfo>> search(String query);

  Future<CommunityInfo> join(String id);

  /// 1.16b/1.16c · Davet koduyla katılır; geçersizse [CommunityException].
  Future<CommunityInfo> joinByCode(String code);

  /// Kodun topluluğunu KATILMADAN gösterir (önizleme). Geçersizse
  /// [CommunityFailure.invalidCode], zaten üyeyse [CommunityFailure.alreadyMember].
  Future<CommunityInfo> previewByCode(String code);

  /// 1.16d · Topluluk açar; açan kişi kurucu olur.
  Future<CommunityInfo> create({
    required String name,
    required String description,
    required CommunityVisibility visibility,
  });

  /// 1.17 · Topluluktan ayrılır.
  Future<void> leave(String id);

  /// 1.16f · Kurucu topluluğu siler.
  Future<void> delete(String id);
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

/// Ayarlar: bildirim tercihleri ve engellenen hesaplar.
/// Her kullanıcının kendi tercihleri ve engel listesi vardır ([userId]).
abstract class SettingsRepository {
  Future<NotificationPrefs> notificationPrefs(String userId);
  Future<void> saveNotificationPrefs(String userId, NotificationPrefs prefs);
  Future<List<BlockedUser>> blockedUsers(String userId);
  Future<void> unblock(String userId, String id);
}
