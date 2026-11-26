import '../../data/models/models.dart';
import '../../l10n/app_localizations.dart';
import 'formatters.dart';

/// Enum → ARB metni eşlemeleri (UI metni Dart'ta tutulmaz).
class Labels {
  const Labels._();

  static String category(AppLocalizations l, ListingCategory c) => switch (c) {
    ListingCategory.book => l.categoryBook,
    ListingCategory.electronics => l.categoryElectronics,
    ListingCategory.dorm => l.categoryDorm,
    ListingCategory.sports => l.categorySports,
  };

  static String condition(AppLocalizations l, ListingCondition c) =>
      switch (c) {
        ListingCondition.brandNew => l.conditionNew,
        ListingCondition.lightlyUsed => l.conditionLightlyUsed,
        ListingCondition.used => l.conditionUsed,
      };

  static String mode(AppLocalizations l, ListingMode m) =>
      m == ListingMode.lend ? l.modeLend : l.modeSell;

  static String urgency(AppLocalizations l, Urgency u) => switch (u) {
    Urgency.urgent => l.urgencyUrgent,
    Urgency.thisWeek => l.urgencyThisWeek,
    Urgency.flexible => l.urgencyFlexible,
  };

  static String price(AppLocalizations l, Listing x, String locale) {
    if (x.isFree) return l.priceFree;
    final base = Formatters.money(x.price!, locale);
    return switch (x.priceUnit) {
      PriceUnit.daily => '$base / ${l.priceDaily.toLowerCase()}',
      PriceUnit.total => '$base ${l.priceTotal.toLowerCase()}',
      null => base,
    };
  }

  /// "Elektronik · Az kullanılmış · Ödünç · Ücretsiz"
  static String meta(AppLocalizations l, Listing x, String locale) {
    final parts = <String>[
      category(l, x.category),
      if (x.condition != null) condition(l, x.condition!),
      mode(l, x.mode),
      price(l, x, locale),
    ];
    return parts.join(' · ');
  }

  static String notificationTitle(AppLocalizations l, AppNotification n) =>
      switch (n.type) {
        NotificationType.overdue => l.notifOverdueBody(n.peerName),
        NotificationType.dueSoon => l.notifDueSoonBody(n.peerName),
        _ => '',
      };
}
