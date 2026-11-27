/// Türkçe seed verisi. İçerik kullanıcı içeriği sayıldığı için çevrilmez.
library;

import '../models/models.dart';

const Community mockCommunity = Community(
  id: 'ytu',
  name: 'Yıldız Teknik Üniversitesi',
  shortName: 'YTÜ',
);

const AppUser mockUser = AppUser(
  id: 'u-elif',
  displayName: 'Elif Yıldırım',
  shortName: 'Elif Y.',
  email: 'elif.yildirim@std.yildiz.edu.tr',
  community: mockCommunity,
  department: 'Matematik Mühendisliği',
  bio: 'Kitap ve kamp malzemelerim paylaşıma açık. Davutpaşa yurdundayım.',
  rating: 4.8,
  transactions: 23,
  onTimeRate: 96,
);

DateTime _ago({int minutes = 0, int hours = 0, int days = 0}) => DateTime.now()
    .subtract(Duration(minutes: minutes, hours: hours, days: days));

List<Listing> seedListings() => [
  Listing(
    id: 'l1',
    kind: ListingKind.ilan,
    title: 'Casio fx-991EX hesap makinesi',
    category: ListingCategory.electronics,
    condition: ListingCondition.lightlyUsed,
    mode: ListingMode.lend,
    ownerName: 'Mert Y.',
    postedAt: _ago(hours: 2),
    description: 'Sınav haftası için ödünç verebilirim.',
    availableFrom: DateTime(DateTime.now().year, 11, 10),
    availableTo: DateTime(DateTime.now().year, 11, 24),
  ),
  Listing(
    id: 'l2',
    kind: ListingKind.ilan,
    title: 'Calculus ders kitabı',
    category: ListingCategory.book,
    condition: ListingCondition.used,
    mode: ListingMode.sell,
    price: 150,
    ownerName: 'Zeynep A.',
    postedAt: _ago(days: 1),
  ),
  Listing(
    id: 'l3',
    kind: ListingKind.ilan,
    title: 'Yoga matı',
    category: ListingCategory.sports,
    condition: ListingCondition.lightlyUsed,
    mode: ListingMode.lend,
    ownerName: 'Oğuz E.',
    postedAt: _ago(days: 1, hours: 3),
  ),
  Listing(
    id: 'l4',
    kind: ListingKind.ilan,
    title: 'Uzatma kablosu',
    category: ListingCategory.dorm,
    condition: ListingCondition.lightlyUsed,
    mode: ListingMode.lend,
    ownerName: 'Selin T.',
    postedAt: _ago(days: 1, hours: 5),
  ),
  Listing(
    id: 'l5',
    kind: ListingKind.ilan,
    title: 'Arduino başlangıç seti',
    category: ListingCategory.electronics,
    condition: ListingCondition.brandNew,
    mode: ListingMode.sell,
    price: 300,
    ownerName: 'Burak Ö.',
    postedAt: _ago(days: 2),
  ),
  Listing(
    id: 'l6',
    kind: ListingKind.ilan,
    title: 'Kamp sandalyesi',
    category: ListingCategory.sports,
    condition: ListingCondition.lightlyUsed,
    mode: ListingMode.lend,
    ownerName: 'Deniz K.',
    postedAt: _ago(days: 3),
  ),
  Listing(
    id: 'l7',
    kind: ListingKind.ilan,
    title: 'Basketbol topu',
    category: ListingCategory.sports,
    condition: ListingCondition.used,
    mode: ListingMode.lend,
    ownerName: 'Can D.',
    postedAt: _ago(days: 4),
  ),
  Listing(
    id: 'n1',
    kind: ListingKind.ihtiyac,
    title: 'Thomas Calculus 1. cilt',
    category: ListingCategory.book,
    mode: ListingMode.lend,
    ownerName: 'Ayşe K.',
    postedAt: _ago(hours: 5),
    description: 'Final haftası için 2 haftalığına ödünç alabilirim.',
    urgency: Urgency.thisWeek,
  ),
  Listing(
    id: 'n2',
    kind: ListingKind.ihtiyac,
    title: 'Lehim istasyonu',
    category: ListingCategory.electronics,
    mode: ListingMode.lend,
    price: 30,
    priceUnit: PriceUnit.daily,
    ownerName: 'Mert Y.',
    postedAt: _ago(days: 1),
    urgency: Urgency.urgent,
  ),
  Listing(
    id: 'n3',
    kind: ListingKind.ihtiyac,
    title: 'Su ısıtıcısı',
    category: ListingCategory.dorm,
    mode: ListingMode.lend,
    ownerName: 'Selin T.',
    postedAt: _ago(days: 2),
    urgency: Urgency.flexible,
  ),
  Listing(
    id: 'n4',
    kind: ListingKind.ihtiyac,
    title: 'Voleybol topu',
    category: ListingCategory.sports,
    mode: ListingMode.lend,
    ownerName: 'Burak Ö.',
    postedAt: _ago(days: 3),
    urgency: Urgency.flexible,
  ),
];

List<Chat> seedChats() => [
  Chat(
    id: 'c1',
    peerName: 'Mert Y.',
    peerInitials: 'MY',
    peerTone: AvatarTone.info,
    listingTitle: 'Fizik 1 soru bankası',
    listingKind: ListingKind.ilan,
    unread: 1,
    messages: [
      Message(
        id: 'm1',
        text: 'Bir haftalığına alabilir miyim?',
        sentAt: _ago(minutes: 30),
        fromMe: false,
        kind: MessageKind.response,
      ),
    ],
  ),
  Chat(
    id: 'c2',
    peerName: 'Ayşe K.',
    peerInitials: 'AK',
    peerTone: AvatarTone.error,
    listingTitle: 'Thomas Calculus 1. cilt',
    listingKind: ListingKind.ihtiyac,
    unread: 1,
    messages: [
      Message(
        id: 'm2',
        text: 'Yarın 12’de olur mu?',
        sentAt: _ago(hours: 1, minutes: 50),
        fromMe: false,
      ),
    ],
  ),
  Chat(
    id: 'c3',
    peerName: 'Oğuz E.',
    peerInitials: 'OE',
    peerTone: AvatarTone.success,
    listingTitle: 'Yoga matı',
    listingKind: ListingKind.ilan,
    agreement: Agreement(
      place: 'Kütüphane',
      from: DateTime(DateTime.now().year, 11, 3),
      to: DateTime(DateTime.now().year, 11, 10),
      price: null,
    ),
    messages: [
      Message(
        id: 'm3',
        text: 'Bir haftalığına alabilir miyim?',
        sentAt: _ago(days: 3, hours: 2),
        fromMe: true,
        kind: MessageKind.response,
        accepted: true,
      ),
      Message(id: 'm4', text: 'Anlaştık', sentAt: _ago(days: 3), fromMe: false),
    ],
  ),
  Chat(
    id: 'c4',
    peerName: 'Zeynep A.',
    peerInitials: 'ZA',
    peerTone: AvatarTone.warning,
    listingTitle: 'Masa lambası',
    listingKind: ListingKind.ilan,
    messages: [
      Message(
        id: 'm5',
        text: 'Lambayı yarın getiririm',
        sentAt: _ago(days: 1, hours: 1),
        fromMe: false,
      ),
    ],
  ),
];

List<AppNotification> seedNotifications() => [
  AppNotification(
    id: 'b1',
    type: NotificationType.overdue,
    createdAt: _ago(days: 1),
    peerName: 'Oğuz E.',
    peerInitials: 'OE',
    peerTone: AvatarTone.success,
    itemTitle: 'Yoga matı',
    daysLate: 1,
  ),
  AppNotification(
    id: 'b2',
    type: NotificationType.dueSoon,
    createdAt: _ago(hours: 6),
    peerName: 'Zeynep A.',
    peerInitials: 'ZA',
    peerTone: AvatarTone.warning,
    itemTitle: 'Masa lambası',
    isRead: true,
  ),
  AppNotification(
    id: 'b3',
    type: NotificationType.response,
    createdAt: _ago(minutes: 30),
    peerName: 'Mert Y.',
    peerInitials: 'MY',
    peerTone: AvatarTone.info,
    itemTitle: 'Fizik 1 soru bankası',
  ),
  AppNotification(
    id: 'b4',
    type: NotificationType.message,
    createdAt: _ago(hours: 1, minutes: 50),
    peerName: 'Ayşe K.',
    peerInitials: 'AK',
    peerTone: AvatarTone.error,
    messageText: 'Yarın 12’de kütüphanede olur mu?',
  ),
  AppNotification(
    id: 'b5',
    type: NotificationType.accepted,
    createdAt: _ago(days: 3),
    peerName: 'Oğuz E.',
    peerInitials: 'OE',
    peerTone: AvatarTone.success,
    itemTitle: 'Yoga matı',
    isRead: true,
  ),
];

List<Loan> seedLoans() => [
  Loan(
    id: 'o1',
    title: 'Darbeli matkap',
    peerName: 'Can D.',
    direction: LoanDirection.borrowed,
    status: LoanStatus.overdue,
    date: DateTime(DateTime.now().year, 11, 7),
    daysLate: 1,
  ),
  Loan(
    id: 'o2',
    title: 'Grafik hesap makinesi',
    peerName: 'Zeynep T.',
    direction: LoanDirection.borrowed,
    status: LoanStatus.onLoan,
    date: DateTime(DateTime.now().year, 11, 14),
  ),
  Loan(
    id: 'o3',
    title: 'Kamp sandalyesi',
    peerName: 'Deniz K.',
    direction: LoanDirection.borrowed,
    status: LoanStatus.awaitingHandover,
    date: DateTime(DateTime.now().year, 11, 21, 14),
  ),
  Loan(
    id: 'o4',
    title: 'Calculus ders kitabı',
    peerName: 'Ayşe K.',
    direction: LoanDirection.lent,
    status: LoanStatus.onLoan,
    date: DateTime(DateTime.now().year, 11, 18),
  ),
  Loan(
    id: 'o5',
    title: 'Uzatma kablosu',
    peerName: 'Selin T.',
    direction: LoanDirection.lent,
    status: LoanStatus.returned,
    date: DateTime(DateTime.now().year, 10, 30),
  ),
  Loan(
    id: 'o6',
    title: 'Yoga matı',
    peerName: 'Mert Y.',
    direction: LoanDirection.lent,
    status: LoanStatus.returned,
    date: DateTime(DateTime.now().year, 10, 12),
  ),
];

// ── Giriş için mock hesaplar (sadece bunlar giriş yapabilir) ──

/// Bilinen okullar (mock). Anahtar = okul kimliği (`.edu.tr`'den önceki kelime).
/// Aynı okulun birden çok kimliği olabilir (boun / bogazici).
const Community mockBogazici = Community(
  id: 'bogazici',
  name: 'Boğaziçi Üniversitesi',
  shortName: 'BÜ',
);
const Community mockItu = Community(
  id: 'itu',
  name: 'İstanbul Teknik Üniversitesi',
  shortName: 'İTÜ',
);
const Community mockMsgsu = Community(
  id: 'msgsu',
  name: 'Mimar Sinan Güzel Sanatlar Üniversitesi',
  shortName: 'MSGSÜ',
);
const Community mockOdtu = Community(
  id: 'odtu',
  name: 'Orta Doğu Teknik Üniversitesi',
  shortName: 'ODTÜ',
);

const Community mockKoc = Community(
  id: 'ku',
  name: 'Koç Üniversitesi',
  shortName: 'KU',
);
const Community mockIuc = Community(
  id: 'iuc',
  name: 'İstanbul Üniversitesi-Cerrahpaşa',
  shortName: 'İÜC',
);

const Map<String, Community> mockKnownSchools = {
  'ku': mockKoc,
  'iuc': mockIuc,
  'yildiz': mockCommunity,
  'marmara': mockMarmara,
  'boun': mockBogazici,
  'bogazici': mockBogazici,
  'itu': mockItu,
  'msgsu': mockMsgsu,
  'odtu': mockOdtu,
  'metu': mockOdtu,
};

const Community mockMarmara = Community(
  id: 'marmara',
  name: 'Marmara Üniversitesi',
  shortName: 'MÜ',
);

/// Mock kayıtlı hesap. Hepsinin şifresi [mockPassword].
class MockAccount {
  const MockAccount({
    required this.email,
    required this.user,
    this.verified = true,
    this.password = mockPassword,
  });

  final String email;
  final String password;
  final bool verified;
  final AppUser user;
}

const String mockPassword = 'sifre123';

AppUser _teamUser(String id, String short, Community community) => AppUser(
  id: id,
  displayName: short,
  shortName: short,
  email: '',
  community: community,
  department: '',
  bio: '',
  rating: 0,
  transactions: 0,
  onTimeRate: 0,
);

/// Ekip test hesapları + farklı okuldan bir hesap. Elif, mevcut [mockUser]
/// verisiyle açılır (profil/ödünç mock'ları ona bağlı).
final List<MockAccount> mockAccounts = [
  MockAccount(
    email: 'eda@std.yildiz.edu.tr',
    user: _teamUser('u-eda', 'Eda H.', mockCommunity),
  ),
  MockAccount(
    email: 'emine@yildiz.edu.tr',
    user: _teamUser('u-emine', 'Emine B.', mockCommunity),
  ),
  const MockAccount(email: 'elif@std.yildiz.edu.tr', user: mockUser),
  MockAccount(
    email: 'sudem@yildiz.edu.tr',
    verified: false, // doğrulanmamış hesap (1.04)
    user: _teamUser('u-sudem', 'Sudem Y.', mockCommunity),
  ),
  MockAccount(
    email: 'sena@std.yildiz.edu.tr',
    user: _teamUser('u-sena', 'Sena G.', mockCommunity),
  ),
  MockAccount(
    email: 'test@std.marmara.edu.tr',
    user: _teamUser('u-test', 'Test M.', mockMarmara),
  ),
];
