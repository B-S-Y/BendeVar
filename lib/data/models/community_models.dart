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

  /// Üyelerin paylaşabildiği davet kodu.
  final String? inviteCode;

  /// "Yıldız Teknik" → "YT".
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  CommunityInfo copyWith({bool? joined, int? memberCount}) => CommunityInfo(
    id: id,
    name: name,
    description: description,
    memberCount: memberCount ?? this.memberCount,
    visibility: visibility,
    schoolId: schoolId,
    isSchool: isSchool,
    isFounder: isFounder,
    joined: joined ?? this.joined,
    inviteCode: inviteCode,
  );
}

enum CommunityFailure { invalidCode, alreadyMember }

class CommunityException implements Exception {
  const CommunityException(this.failure);
  final CommunityFailure failure;
}
