/// Veri modelleri. Terminoloji: ilan = listing, ihtiyaç = need.
library;

enum ListingKind { ilan, ihtiyac }

enum ListingMode { lend, sell }

enum ListingCategory { book, electronics, dorm, sports }

enum ListingCondition { brandNew, lightlyUsed, used }

enum Urgency { urgent, thisWeek, flexible }

enum PriceUnit { daily, total }

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.shortName,
  });
  final String id;
  final String name;
  final String shortName;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.email,
    required this.community,
    required this.department,
    required this.bio,
    required this.rating,
    required this.transactions,
    required this.onTimeRate,
  });

  final String id;
  final String displayName;

  /// "Mert Y." biçimi.
  final String shortName;
  final String email;
  final Community community;
  final String department;
  final String bio;
  final double rating;
  final int transactions;
  final int onTimeRate;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final a = parts.first.isEmpty ? '' : parts.first.substring(0, 1);
    final b = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (a + b).toUpperCase();
  }
}

class Listing {
  const Listing({
    required this.id,
    required this.kind,
    required this.title,
    required this.category,
    required this.mode,
    required this.ownerName,
    required this.postedAt,
    this.condition,
    this.price,
    this.priceUnit,
    this.description = '',
    this.availableFrom,
    this.availableTo,
    this.urgency,
    this.communityShort = 'YTÜ',
    this.isFavorite = false,
  });

  final String id;
  final ListingKind kind;
  final String title;
  final ListingCategory category;
  final ListingMode mode;
  final String ownerName;
  final DateTime postedAt;

  /// Yalnızca ilanlarda.
  final ListingCondition? condition;

  /// null veya 0 = ücretsiz.
  final double? price;
  final PriceUnit? priceUnit;
  final String description;
  final DateTime? availableFrom;
  final DateTime? availableTo;

  /// Yalnızca ihtiyaçlarda.
  final Urgency? urgency;
  final String communityShort;
  final bool isFavorite;

  bool get isFree => price == null || price == 0;

  Listing copyWith({bool? isFavorite}) => Listing(
    id: id,
    kind: kind,
    title: title,
    category: category,
    mode: mode,
    ownerName: ownerName,
    postedAt: postedAt,
    condition: condition,
    price: price,
    priceUnit: priceUnit,
    description: description,
    availableFrom: availableFrom,
    availableTo: availableTo,
    urgency: urgency,
    communityShort: communityShort,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}

enum MessageKind { text, response }

class Message {
  const Message({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.fromMe,
    this.kind = MessageKind.text,
    this.accepted = false,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final bool fromMe;
  final MessageKind kind;

  /// `response` mesajlarında "Kabul edildi" durumu.
  final bool accepted;
}

class Agreement {
  const Agreement({
    required this.place,
    required this.from,
    required this.to,
    required this.price,
  });

  final String place;
  final DateTime from;
  final DateTime to;

  /// null = ücretsiz.
  final double? price;
}

class Chat {
  const Chat({
    required this.id,
    required this.peerName,
    required this.peerInitials,
    required this.peerTone,
    required this.listingTitle,
    required this.listingKind,
    required this.messages,
    this.unread = 0,
    this.agreement,
  });

  final String id;
  final String peerName;
  final String peerInitials;
  final AvatarTone peerTone;
  final String listingTitle;
  final ListingKind listingKind;
  final List<Message> messages;
  final int unread;
  final Agreement? agreement;

  Message get last => messages.last;

  Chat copyWith({List<Message>? messages, int? unread}) => Chat(
    id: id,
    peerName: peerName,
    peerInitials: peerInitials,
    peerTone: peerTone,
    listingTitle: listingTitle,
    listingKind: listingKind,
    messages: messages ?? this.messages,
    unread: unread ?? this.unread,
    agreement: agreement,
  );
}

/// Avatar zemin rengi; renk eşlemesi UI'da tema üzerinden yapılır.
enum AvatarTone { info, error, success, warning }

enum NotificationType { overdue, dueSoon, response, message, accepted }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.peerName,
    required this.peerInitials,
    required this.peerTone,
    this.itemTitle = '',
    this.messageText = '',
    this.daysLate = 0,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final DateTime createdAt;
  final String peerName;
  final String peerInitials;
  final AvatarTone peerTone;
  final String itemTitle;
  final String messageText;
  final int daysLate;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    createdAt: createdAt,
    peerName: peerName,
    peerInitials: peerInitials,
    peerTone: peerTone,
    itemTitle: itemTitle,
    messageText: messageText,
    daysLate: daysLate,
    isRead: isRead ?? this.isRead,
  );
}

enum LoanDirection { borrowed, lent }

enum LoanStatus { overdue, onLoan, awaitingHandover, returned }

class Loan {
  const Loan({
    required this.id,
    required this.title,
    required this.peerName,
    required this.direction,
    required this.status,
    required this.date,
    this.daysLate = 0,
  });

  final String id;
  final String title;
  final String peerName;
  final LoanDirection direction;
  final LoanStatus status;
  final DateTime date;
  final int daysLate;

  bool get isActive => status != LoanStatus.returned;
}

enum PendingKind { newResponses, overdue, handover }

class PendingItem {
  const PendingItem({
    required this.kind,
    required this.itemTitle,
    this.count = 0,
    this.when,
  });

  final PendingKind kind;
  final String itemTitle;
  final int count;

  /// Teslim zamanı (ör. "Cuma") mock içerik olarak tarih tutulur.
  final DateTime? when;
}
