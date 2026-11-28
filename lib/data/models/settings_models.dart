/// İade hatırlatması ne zaman gelsin (1.18).
enum ReminderTiming {
  /// İade gününden 2 gün önce.
  twoDaysBefore,

  /// 1 gün önce ve iade günü.
  dayBeforeAndDay,

  /// Yalnızca iade günü.
  dayOf,
}

/// Bildirim tercihleri (1.18). Hepsi varsayılan açık.
class NotificationPrefs {
  const NotificationPrefs({
    this.messages = true,
    this.responses = true,
    this.reminders = true,
    this.reminderTiming = ReminderTiming.dayBeforeAndDay,
  });

  final bool messages;

  /// İlanına ya da ihtiyacına gelen karşılıklar.
  final bool responses;
  final bool reminders;

  /// [reminders] açıkken geçerli.
  final ReminderTiming reminderTiming;

  NotificationPrefs copyWith({
    bool? messages,
    bool? responses,
    bool? reminders,
    ReminderTiming? reminderTiming,
  }) => NotificationPrefs(
    messages: messages ?? this.messages,
    responses: responses ?? this.responses,
    reminders: reminders ?? this.reminders,
    reminderTiming: reminderTiming ?? this.reminderTiming,
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
