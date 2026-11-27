import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/community_models.dart';
import '../models/models.dart';
import '../models/settings_models.dart';
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
    DateTime Function()? now,
  }) : _accounts = List.of(accounts ?? mockAccounts),
       _now = now ?? DateTime.now;

  /// Saat (testte sahte saat verilebilir).
  final DateTime Function() _now;

  final List<MockAccount> _accounts;
  final Map<String, _PendingSignUp> _pending = {};
  final Map<String, DateTime> _resets = {};
  AppUser? _user;
  final Map<String, int> _failures = {};
  final Map<String, DateTime> _lockedUntil = {};

  /// Bu kadar yanlış şifreden sonra hesap geçici kilitlenir.
  static const int maxFailures = 3;

  /// Kilit süresi (tek sabit). Dolunca kilit kalkar, yanlış deneme sayacı
  /// sıfırlanır. Arayüzde geri sayım gösterilmez.
  static const Duration lockDuration = Duration(seconds: 30);

  /// Kayıtta doğrulama bağlantısına "tıklanması" bu süre sonra taklit edilir.
  final Duration verifyAfter;

  /// Bu önekle başlayan e-postalarda bağlantı süresi dolar (1.12).
  static const String expiredPrefix = 'suredoldu';

  @override
  AppUser? get currentUser => _user;

  /// "Beni hatırla" için kalıcı anahtar (shared_preferences; Firebase'de
  /// oturum kalıcılığı SDK'da olacak). Mock'ta en iyi çaba: erişilemezse yok sayılır.
  static const String rememberKey = 'remember_email';

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final prefs = await _prefs();
    final email = prefs?.getString(rememberKey);
    if (email == null) return null;
    // Yalnızca doğrulanmış hesap hatırlanır.
    final account = _accounts
        .where((a) => a.email == email && a.verified)
        .firstOrNull;
    if (account == null) {
      await prefs?.remove(rememberKey);
      return null;
    }
    return _user = account.user;
  }

  @override
  Future<AppUser> signIn(
    String email,
    String password, {
    bool remember = false,
  }) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final pending = _pending[key];
    final account = _accounts.where((a) => a.email == key).firstOrNull;
    if (account == null && pending == null) {
      throw const AuthException(AuthFailure.accountNotFound);
    }
    final lockedUntil = _lockedUntil[key];
    if (lockedUntil != null) {
      if (_now().isBefore(lockedUntil)) {
        throw const AuthException(AuthFailure.tooManyAttempts);
      }
      // Süre doldu: kilit kalkar, sayaç sıfırlanır.
      _lockedUntil.remove(key);
      _failures.remove(key);
    }
    final expected = account?.password ?? pending!.password;
    if (password != expected) {
      final count = (_failures[key] ?? 0) + 1;
      _failures[key] = count;
      if (count >= maxFailures) _lockedUntil[key] = _now().add(lockDuration);
      throw const AuthException(AuthFailure.wrongPassword);
    }
    _failures.remove(key);
    _lockedUntil.remove(key);
    // Gerçekte: giriş olur, sonra e-posta doğrulaması denetlenir (1.04).
    if (account == null || !account.verified) {
      throw const AuthException(AuthFailure.notVerified);
    }
    _user = account.user;
    // Doğrulanmamış hesap yukarıda reddedildi; buraya yalnızca doğrulanmış
    // hesap gelir. Hatırlama kapalıysa eski kayıt da silinir.
    final prefs = await _prefs();
    if (remember) {
      await prefs?.setString(rememberKey, account.email);
    } else {
      await prefs?.remove(rememberKey);
    }
    return account.user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(_latency);
    _user = null;
    await (await _prefs())?.remove(rememberKey);
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
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    _resets[email.trim().toLowerCase()] = DateTime.now();
  }

  @override
  Future<VerificationStatus> checkPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final sent = _resets[key];
    // Kayıtsız e-postaya bağlantı gitmez: hiç "tıklanmaz" (hesap sızdırılmaz).
    final known =
        _accounts.any((a) => a.email == key) || _pending.containsKey(key);
    if (sent == null || !known) return VerificationStatus.pending;
    if (DateTime.now().difference(sent) < verifyAfter) {
      return VerificationStatus.pending;
    }
    return key.startsWith(expiredPrefix)
        ? VerificationStatus.expired
        : VerificationStatus.verified;
  }

  @override
  Future<void> confirmPasswordReset(String email, String newPassword) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    final i = _accounts.indexWhere((a) => a.email == key);
    if (i >= 0) {
      final a = _accounts[i];
      _accounts[i] = MockAccount(
        email: a.email,
        user: a.user,
        verified: a.verified,
        password: newPassword,
      );
    }
    _failures.remove(key); // kilit de açılır
    _lockedUntil.remove(key);
    _resets.remove(key);
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

  /// Tüm topluluklar (okul toplulukları ilk girişte eklenir).
  final Map<String, CommunityInfo> _all = {
    'yurt': const CommunityInfo(
      id: 'yurt',
      name: 'Yıldız Yurt Topluluğu',
      description: 'Yurtta kalanlar için ödünç alma ve verme.',
      memberCount: 86,
      visibility: CommunityVisibility.schoolOnly,
      schoolId: 'ytu',
    ),
    'kamp': const CommunityInfo(
      id: 'kamp',
      name: 'Kamp Kulübü',
      description: 'Kamp malzemelerini paylaşan herkes.',
      memberCount: 42,
      visibility: CommunityVisibility.open,
    ),
    'yoga': const CommunityInfo(
      id: 'yoga',
      name: 'Yoga ve Esneme',
      memberCount: 18,
      visibility: CommunityVisibility.open,
    ),
    'proje': const CommunityInfo(
      id: 'proje',
      name: 'Proje Ekibi',
      memberCount: 6,
      visibility: CommunityVisibility.secret,
      inviteCode: 'PROJE-24',
    ),
  };

  String _schoolId = '';
  int _seq = 0;

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

  @override
  Future<List<CommunityInfo>> myCommunities(Community school) async {
    await Future<void>.delayed(_latency);
    _schoolId = school.id;
    _all.putIfAbsent(
      school.id,
      () => CommunityInfo(
        id: school.id,
        name: school.name,
        memberCount: 1240,
        visibility: CommunityVisibility.schoolOnly,
        schoolId: school.id,
        isSchool: true,
        joined: true,
      ),
    );
    final mine = _all.values.where((c) => c.joined).toList();
    mine.sort((a, b) => a.isSchool == b.isSchool ? 0 : (a.isSchool ? -1 : 1));
    return mine;
  }

  bool _visibleToMe(CommunityInfo c) =>
      c.visibility == CommunityVisibility.open ||
      (c.visibility == CommunityVisibility.schoolOnly &&
          c.schoolId == _schoolId);

  @override
  Future<List<CommunityInfo>> search(String query) async {
    await Future<void>.delayed(_latency);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _all.values
        .where((c) => _visibleToMe(c) && c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<CommunityInfo> join(String id) async {
    await Future<void>.delayed(_latency);
    final c = _all[id]!;
    if (c.joined) return c;
    return _all[id] = c.copyWith(joined: true, memberCount: c.memberCount + 1);
  }

  @override
  Future<CommunityInfo> joinByCode(String code) async {
    await Future<void>.delayed(_latency);
    final key = code.trim().toLowerCase();
    final found = _all.values.where(
      (c) => c.inviteCode != null && c.inviteCode!.toLowerCase() == key,
    );
    if (key.isEmpty || found.isEmpty) {
      throw const CommunityException(CommunityFailure.invalidCode);
    }
    final c = found.first;
    if (c.joined) {
      throw const CommunityException(CommunityFailure.alreadyMember);
    }
    return _all[c.id] = c.copyWith(
      joined: true,
      memberCount: c.memberCount + 1,
    );
  }

  @override
  Future<CommunityInfo> create({
    required String name,
    required String description,
    required CommunityVisibility visibility,
  }) async {
    await Future<void>.delayed(_latency);
    _seq++;
    final id = 'c$_seq';
    final info = CommunityInfo(
      id: id,
      name: name.trim(),
      description: description.trim(),
      memberCount: 1,
      visibility: visibility,
      schoolId: visibility == CommunityVisibility.schoolOnly ? _schoolId : null,
      isFounder: true,
      joined: true,
      // Davet kodu yalnızca gizli topluluklarda var; açık ve okula özel
      // topluluklara kodsuz katılınır.
      inviteCode: visibility == CommunityVisibility.secret
          ? 'BV-${1000 + _seq * 7}'
          : null,
    );
    _all[id] = info;
    return info;
  }

  @override
  Future<void> leave(String id) async {
    await Future<void>.delayed(_latency);
    final c = _all[id];
    if (c == null || c.isSchool) return;
    _all[id] = c.copyWith(joined: false, memberCount: c.memberCount - 1);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(_latency);
    _all.remove(id);
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

class MockSettingsRepository implements SettingsRepository {
  NotificationPrefs _prefs = const NotificationPrefs();
  final List<BlockedUser> _blocked = [
    const BlockedUser(
      id: 'u-mert',
      name: 'Mert Y.',
      initials: 'MY',
      communityName: 'Yıldız Teknik Üniversitesi',
    ),
    const BlockedUser(
      id: 'u-kaan',
      name: 'Kaan D.',
      initials: 'KD',
      communityName: 'Yıldız Teknik Üniversitesi',
    ),
  ];

  @override
  Future<NotificationPrefs> notificationPrefs() async {
    await Future<void>.delayed(_latency);
    return _prefs;
  }

  @override
  Future<void> saveNotificationPrefs(NotificationPrefs prefs) async {
    _prefs = prefs;
  }

  @override
  Future<List<BlockedUser>> blockedUsers() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_blocked);
  }

  @override
  Future<void> unblock(String id) async {
    await Future<void>.delayed(_latency);
    _blocked.removeWhere((b) => b.id == id);
  }
}
