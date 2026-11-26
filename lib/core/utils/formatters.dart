import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Tarih, saat ve para biçimleri seçili dile göre `intl` ile yapılır.
class Formatters {
  const Formatters._();

  /// 150 ₺
  static String money(double amount, String locale) {
    final f = NumberFormat.currency(
      locale: locale,
      symbol: '₺',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return f.format(amount).replaceAll(' ', ' ');
  }

  /// 10 Kas
  static String dayMonth(DateTime d, String locale) =>
      DateFormat('d MMM', locale).format(d);

  /// 14:20
  static String time(DateTime d, String locale) =>
      DateFormat.Hm(locale).format(d);

  /// Cuma / Friday
  static String weekdayLong(DateTime d, String locale) =>
      DateFormat('EEEE', locale).format(d);

  /// 4,8
  static String decimal(double v, String locale) =>
      NumberFormat('0.0', locale).format(v);

  /// %96 / 96%
  static String percent(int v, String locale) =>
      NumberFormat.percentPattern(locale).format(v / 100);

  /// Pzt / Mon
  static String weekdayShort(DateTime d, String locale) =>
      DateFormat('E', locale).format(d);

  /// "2 sa önce", "Dün", "2 gün önce"
  static String relative(AppLocalizations l, DateTime d, DateTime now) {
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return l.timeNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (days <= 1) return l.timeYesterday;
    return l.timeDaysAgo(days);
  }

  /// Sohbet listesi zamanı: bugünse saat, bu hafta ise gün adı, değilse "Dün"/tarih.
  static String chatTime(
    AppLocalizations l,
    DateTime d,
    DateTime now,
    String locale,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final days = today.difference(day).inDays;
    if (days <= 0) return time(d, locale);
    if (days == 1) return l.timeYesterday;
    if (days < 7) return weekdayShort(d, locale);
    return dayMonth(d, locale);
  }
}
