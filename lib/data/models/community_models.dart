/// Topluluk görünürlüğü (1.16d).
enum CommunityVisibility {
  /// Aramada çıkar, herkes katılabilir.
  open,

  /// Aramada yalnızca okul üyelerine çıkar, yalnızca onlar katılabilir.
  schoolOnly,

  /// Aramada çıkmaz; yalnızca davet koduyla katılınır.
  secret,
}

/// Topluluk satırı (1.16 listesi, 1.16g arama sonucu).
class CommunityInfo {
  const CommunityInfo({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.visibility,
    this.description = '',
    this.schoolId,
    this.isSchool = false,
    this.isFounder = false,
    this.joined = false,
    this.inviteCode,
    this.iconKey = kDefaultCommunityIcon,
    this.joinedAt,
  });

  final String id;
  final String name;
  final String description;
  final int memberCount;
  final CommunityVisibility visibility;

  /// Okula özel topluluklarda hangi okula ait olduğu.
  final String? schoolId;

  /// Kayıtta otomatik katılınan okul topluluğu (ayrılınamaz).
  final bool isSchool;
  final bool isFounder;
  final bool joined;

  /// Davet kodu: yalnızca gizli topluluklarda (açık: herkes katılır, okula
  /// özel: aynı okulun üyeleri katılır; ikisinde kod yok).
  final String? inviteCode;

  /// Simge anahtarı (1.16d); `core/utils/community_icons.dart` ikona çevirir.
  final String iconKey;

  /// Bu kullanıcının katılma zamanı (1.16 "Yeni" rozeti). Kuran ve okul
  /// topluluğu için boş.
  final DateTime? joinedAt;

  /// Katılalı [kNewBadgeDuration]'dan az geçtiyse true.
  bool isNew(DateTime now) =>
      joinedAt != null && now.difference(joinedAt!) < kNewBadgeDuration;

  /// "Yıldız Teknik" → "YT".
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  CommunityInfo copyWith({
    bool? joined,
    int? memberCount,
    bool? isFounder,
    DateTime? joinedAt,
  }) => CommunityInfo(
    id: id,
    name: name,
    description: description,
    memberCount: memberCount ?? this.memberCount,
    visibility: visibility,
    schoolId: schoolId,
    isSchool: isSchool,
    isFounder: isFounder ?? this.isFounder,
    joined: joined ?? this.joined,
    inviteCode: inviteCode,
    iconKey: iconKey,
    joinedAt: joinedAt ?? this.joinedAt,
  );

  /// Görünürlüğü değiştirir (1.16e). Davet kodu ve okul bağı yeni türe göre
  /// verilir; boş geçmek siler.
  CommunityInfo withVisibility(
    CommunityVisibility next, {
    String? inviteCode,
    String? schoolId,
  }) => CommunityInfo(
    id: id,
    name: name,
    description: description,
    memberCount: memberCount,
    visibility: next,
    schoolId: schoolId,
    isSchool: isSchool,
    isFounder: isFounder,
    joined: joined,
    inviteCode: inviteCode,
    iconKey: iconKey,
    joinedAt: joinedAt,
  );
}

/// 1.16d simge ızgarası: görseldeki sırayla 12 Lucide simgesinin anahtarı
/// (6×2).
const List<String> kCommunityIconKeys = [
  'book-open',
  'coffee',
  'house',
  'laptop',
  'gamepad-2',
  'trophy',
  'music',
  'palette',
  'utensils',
  'bike',
  'flask-conical',
  'users',
];

/// Okul topluluğunun simgesi; seçim ızgarasında yok.
const String kSchoolCommunityIcon = 'graduation-cap';

/// Simge seçilmediğinde kullanılan anahtar (1.16d listesinin ilk simgesi).
const String kDefaultCommunityIcon = 'book-open';

/// "Yeni" rozeti, katılımdan sonra bu süre boyunca görünür (1.16).
const Duration kNewBadgeDuration = Duration(hours: 24);

/// Davet kodu: yalnızca rakam, 6 hane (ön ek yok).
const int kInviteCodeLength = 6;

enum CommunityFailure {
  invalidCode,
  alreadyMember,

  /// Beklenmeyen hata (bağlantı vb.).
  unknown,
}

class CommunityException implements Exception {
  const CommunityException(this.failure);
  final CommunityFailure failure;
}
