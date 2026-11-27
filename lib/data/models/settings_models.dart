/// Bildirim tercihleri (1.18). Hepsi varsayılan açık.
class NotificationPrefs {
  const NotificationPrefs({
    this.messages = true,
    this.responses = true,
    this.reminders = true,
    this.announcements = true,
  });

  final bool messages;
  final bool responses;
  final bool reminders;
  final bool announcements;

  NotificationPrefs copyWith({
    bool? messages,
    bool? responses,
    bool? reminders,
    bool? announcements,
  }) => NotificationPrefs(
    messages: messages ?? this.messages,
    responses: responses ?? this.responses,
    reminders: reminders ?? this.reminders,
    announcements: announcements ?? this.announcements,
  );
}

/// Engellenen hesap (1.20).
class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.name,
    required this.initials,
    required this.communityName,
  });

  final String id;

  /// "Mert Y." biçimi.
  final String name;
  final String initials;
  final String communityName;
}
