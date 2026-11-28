import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @brandName.
  ///
  /// In tr, this message translates to:
  /// **'Bende Var'**
  String get brandName;

  /// No description provided for @slogan.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacın topluluğunda.'**
  String get slogan;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Elinde olan paylaşır,\nihtiyacı olan bulur.'**
  String get welcomeTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signup;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldin'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kurum e-postası'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni gir'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @showPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @more.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get more;

  /// No description provided for @errorEmailEmpty.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini gir.'**
  String get errorEmailEmpty;

  /// No description provided for @errorEmailNotEdu.
  ///
  /// In tr, this message translates to:
  /// **'Okul e-postanı kullan (edu.tr).'**
  String get errorEmailNotEdu;

  /// No description provided for @errorPasswordEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni gir.'**
  String get errorPasswordEmpty;

  /// No description provided for @emailHintShort.
  ///
  /// In tr, this message translates to:
  /// **'ad.soyad@okul'**
  String get emailHintShort;

  /// No description provided for @errorAccountNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-postayla hesap bulunamadı.'**
  String get errorAccountNotFound;

  /// No description provided for @errorPasswordWrong.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yanlış.'**
  String get errorPasswordWrong;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme; biraz sonra tekrar dene.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorNotVerified.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın doğrulanmamış. E-postandaki bağlantıya tıkla.'**
  String get errorNotVerified;

  /// No description provided for @resendVerification.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı tekrar gönder'**
  String get resendVerification;

  /// No description provided for @verificationSent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama bağlantısı gönderildi.'**
  String get verificationSent;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get navHome;

  /// No description provided for @navMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get navMessages;

  /// No description provided for @navCreate.
  ///
  /// In tr, this message translates to:
  /// **'İlan veya ihtiyaç oluştur'**
  String get navCreate;

  /// No description provided for @navNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @communityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get communityLabel;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ne arıyorsun? Ürün veya eşya...'**
  String get searchHint;

  /// No description provided for @voiceSearch.
  ///
  /// In tr, this message translates to:
  /// **'Sesli arama'**
  String get voiceSearch;

  /// No description provided for @filters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filters;

  /// No description provided for @tabListings.
  ///
  /// In tr, this message translates to:
  /// **'İlanlar · {n}'**
  String tabListings(int n);

  /// No description provided for @tabNeeds.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyaçlar · {n}'**
  String tabNeeds(int n);

  /// No description provided for @countListings.
  ///
  /// In tr, this message translates to:
  /// **'{n} ilan'**
  String countListings(int n);

  /// No description provided for @countNeeds.
  ///
  /// In tr, this message translates to:
  /// **'{n} ihtiyaç'**
  String countNeeds(int n);

  /// No description provided for @sortNewest.
  ///
  /// In tr, this message translates to:
  /// **'En yeni'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In tr, this message translates to:
  /// **'En eski'**
  String get sortOldest;

  /// No description provided for @emptyResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı.'**
  String get emptyResults;

  /// No description provided for @emptyFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favorin yok.'**
  String get emptyFavorites;

  /// No description provided for @showFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorileri göster'**
  String get showFavorites;

  /// No description provided for @showAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü göster'**
  String get showAll;

  /// No description provided for @favoriteAdd.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get favoriteRemove;

  /// No description provided for @respondHaveIt.
  ///
  /// In tr, this message translates to:
  /// **'Bende Var'**
  String get respondHaveIt;

  /// No description provided for @comingSoonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik henüz hazır değil.'**
  String get comingSoonBody;

  /// No description provided for @comingSoonSnack.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik yakında geliyor.'**
  String get comingSoonSnack;

  /// No description provided for @categoryBook.
  ///
  /// In tr, this message translates to:
  /// **'Ders kitabı'**
  String get categoryBook;

  /// No description provided for @categoryElectronics.
  ///
  /// In tr, this message translates to:
  /// **'Elektronik'**
  String get categoryElectronics;

  /// No description provided for @categoryDorm.
  ///
  /// In tr, this message translates to:
  /// **'Yurt eşyası'**
  String get categoryDorm;

  /// No description provided for @categorySports.
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get categorySports;

  /// No description provided for @conditionNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get conditionNew;

  /// No description provided for @conditionLightlyUsed.
  ///
  /// In tr, this message translates to:
  /// **'Az kullanılmış'**
  String get conditionLightlyUsed;

  /// No description provided for @conditionUsed.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılmış'**
  String get conditionUsed;

  /// No description provided for @modeLend.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç'**
  String get modeLend;

  /// No description provided for @modeSell.
  ///
  /// In tr, this message translates to:
  /// **'Satılık'**
  String get modeSell;

  /// No description provided for @priceFree.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz'**
  String get priceFree;

  /// No description provided for @pricePaid.
  ///
  /// In tr, this message translates to:
  /// **'Ücretli'**
  String get pricePaid;

  /// No description provided for @priceDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get priceDaily;

  /// No description provided for @priceTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get priceTotal;

  /// No description provided for @priceHint.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (₺)'**
  String get priceHint;

  /// No description provided for @urgencyUrgent.
  ///
  /// In tr, this message translates to:
  /// **'Acil'**
  String get urgencyUrgent;

  /// No description provided for @urgencyThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get urgencyThisWeek;

  /// No description provided for @urgencyFlexible.
  ///
  /// In tr, this message translates to:
  /// **'Esnek'**
  String get urgencyFlexible;

  /// No description provided for @detailTitleListing.
  ///
  /// In tr, this message translates to:
  /// **'İlan detayı'**
  String get detailTitleListing;

  /// No description provided for @detailTitleNeed.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyaç detayı'**
  String get detailTitleNeed;

  /// No description provided for @badgeIlan.
  ///
  /// In tr, this message translates to:
  /// **'İLAN'**
  String get badgeIlan;

  /// No description provided for @badgeNeed.
  ///
  /// In tr, this message translates to:
  /// **'İHTİYAÇ'**
  String get badgeNeed;

  /// No description provided for @badgeIlanLarge.
  ///
  /// In tr, this message translates to:
  /// **'İLAN · VERİYORUM'**
  String get badgeIlanLarge;

  /// No description provided for @badgeNeedLarge.
  ///
  /// In tr, this message translates to:
  /// **'İHTİYAÇ · ARIYORUM'**
  String get badgeNeedLarge;

  /// No description provided for @statusPublished.
  ///
  /// In tr, this message translates to:
  /// **'YAYINDA'**
  String get statusPublished;

  /// No description provided for @statusPublishedShort.
  ///
  /// In tr, this message translates to:
  /// **'Yayında'**
  String get statusPublishedShort;

  /// No description provided for @rowCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get rowCategory;

  /// No description provided for @rowCondition.
  ///
  /// In tr, this message translates to:
  /// **'Ürün durumu'**
  String get rowCondition;

  /// No description provided for @rowMode.
  ///
  /// In tr, this message translates to:
  /// **'Veriliş şekli'**
  String get rowMode;

  /// No description provided for @rowPrice.
  ///
  /// In tr, this message translates to:
  /// **'Ücret'**
  String get rowPrice;

  /// No description provided for @rowAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Müsait'**
  String get rowAvailable;

  /// No description provided for @rowNeededWhen.
  ///
  /// In tr, this message translates to:
  /// **'Ne zaman lazım'**
  String get rowNeededWhen;

  /// No description provided for @rowUrgency.
  ///
  /// In tr, this message translates to:
  /// **'Aciliyet'**
  String get rowUrgency;

  /// No description provided for @rowCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get rowCommunity;

  /// No description provided for @favorite.
  ///
  /// In tr, this message translates to:
  /// **'Favorile'**
  String get favorite;

  /// No description provided for @favorited.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerde'**
  String get favorited;

  /// No description provided for @actionBorrow.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç iste'**
  String get actionBorrow;

  /// No description provided for @actionBuy.
  ///
  /// In tr, this message translates to:
  /// **'Satın al'**
  String get actionBuy;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @createIlanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bende var'**
  String get createIlanTitle;

  /// No description provided for @createIlanSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Elindeki eşyayı ödünç ver'**
  String get createIlanSubtitle;

  /// No description provided for @createNeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacım var'**
  String get createNeedTitle;

  /// No description provided for @createNeedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın eşyayı ödünç al'**
  String get createNeedSubtitle;

  /// No description provided for @newListingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni ilan'**
  String get newListingTitle;

  /// No description provided for @newNeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni ihtiyaç'**
  String get newNeedTitle;

  /// No description provided for @sectionItem.
  ///
  /// In tr, this message translates to:
  /// **'Eşya bilgileri'**
  String get sectionItem;

  /// No description provided for @sectionTerms.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç koşulları'**
  String get sectionTerms;

  /// No description provided for @fieldPhotos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar *'**
  String get fieldPhotos;

  /// No description provided for @photoAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get photoAdd;

  /// No description provided for @fieldTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşya adı *'**
  String get fieldTitle;

  /// No description provided for @fieldCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori *'**
  String get fieldCategory;

  /// No description provided for @fieldCondition.
  ///
  /// In tr, this message translates to:
  /// **'Ürün durumu *'**
  String get fieldCondition;

  /// No description provided for @fieldDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get fieldDescription;

  /// No description provided for @fieldAvailability.
  ///
  /// In tr, this message translates to:
  /// **'Müsaitlik tarihleri *'**
  String get fieldAvailability;

  /// No description provided for @fieldNeededWhen.
  ///
  /// In tr, this message translates to:
  /// **'Ne zaman lazım? *'**
  String get fieldNeededWhen;

  /// No description provided for @fieldMode.
  ///
  /// In tr, this message translates to:
  /// **'Veriliş şekli'**
  String get fieldMode;

  /// No description provided for @fieldUrgency.
  ///
  /// In tr, this message translates to:
  /// **'Aciliyet *'**
  String get fieldUrgency;

  /// No description provided for @fieldPrice.
  ///
  /// In tr, this message translates to:
  /// **'Ücret *'**
  String get fieldPrice;

  /// No description provided for @datePick.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seç'**
  String get datePick;

  /// No description provided for @errorRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan boş bırakılamaz.'**
  String get errorRequired;

  /// No description provided for @errorChoose.
  ///
  /// In tr, this message translates to:
  /// **'Bir seçenek seç.'**
  String get errorChoose;

  /// No description provided for @errorDates.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç ve bitiş tarihini seç; bitiş başlangıçtan önce olamaz.'**
  String get errorDates;

  /// No description provided for @errorPrice.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar gir.'**
  String get errorPrice;

  /// No description provided for @publish.
  ///
  /// In tr, this message translates to:
  /// **'Yayınla'**
  String get publish;

  /// No description provided for @publishedTitleListing.
  ///
  /// In tr, this message translates to:
  /// **'İlanın yayınlandı'**
  String get publishedTitleListing;

  /// No description provided for @publishedBodyListing.
  ///
  /// In tr, this message translates to:
  /// **'İlanın, seçilen toplulukların İlanlar sekmesinde görünür. Biri \"İhtiyacım Var\" dediğinde bildirim alırsın.'**
  String get publishedBodyListing;

  /// No description provided for @publishedTitleNeed.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacın yayınlandı'**
  String get publishedTitleNeed;

  /// No description provided for @publishedBodyNeed.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacın, topluluğunun İhtiyaçlar sekmesinde görünür. Biri \"Bende Var\" dediğinde bildirim alırsın.'**
  String get publishedBodyNeed;

  /// No description provided for @view.
  ///
  /// In tr, this message translates to:
  /// **'Görüntüle'**
  String get view;

  /// No description provided for @backToHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfaya dön'**
  String get backToHome;

  /// No description provided for @messagesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messagesTitle;

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In tr, this message translates to:
  /// **'Okunmamış'**
  String get filterUnread;

  /// No description provided for @filterActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get filterActive;

  /// No description provided for @filterPast.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get filterPast;

  /// No description provided for @emptyMessages.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesajın yok.'**
  String get emptyMessages;

  /// No description provided for @respondedNeedIt.
  ///
  /// In tr, this message translates to:
  /// **'“İhtiyacım Var” dedi'**
  String get respondedNeedIt;

  /// No description provided for @respondedHaveIt.
  ///
  /// In tr, this message translates to:
  /// **'“Bende Var” dedi'**
  String get respondedHaveIt;

  /// No description provided for @bubbleNeedIt.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacım Var'**
  String get bubbleNeedIt;

  /// No description provided for @bubbleHaveIt.
  ///
  /// In tr, this message translates to:
  /// **'Bende Var'**
  String get bubbleHaveIt;

  /// No description provided for @accepted.
  ///
  /// In tr, this message translates to:
  /// **'Kabul edildi'**
  String get accepted;

  /// No description provided for @agreementSummary.
  ///
  /// In tr, this message translates to:
  /// **'Anlaşma özeti'**
  String get agreementSummary;

  /// No description provided for @agreementDetail.
  ///
  /// In tr, this message translates to:
  /// **'Anlaşma detayı'**
  String get agreementDetail;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yaz'**
  String get messageHint;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @sendMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönder'**
  String get sendMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü oku'**
  String get markAllRead;

  /// No description provided for @sectionUpcomingReturns.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan iadeler'**
  String get sectionUpcomingReturns;

  /// No description provided for @sectionToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get sectionToday;

  /// No description provided for @sectionThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get sectionThisWeek;

  /// No description provided for @daysLate.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün gecikti'**
  String daysLate(int n);

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @notifOverdueBody.
  ///
  /// In tr, this message translates to:
  /// **'{name} adlı kişiye iade etmen gerekiyordu.'**
  String notifOverdueBody(String name);

  /// No description provided for @notifDueSoonBody.
  ///
  /// In tr, this message translates to:
  /// **'{name} sana iade edecek.'**
  String notifDueSoonBody(String name);

  /// No description provided for @actionReturned.
  ///
  /// In tr, this message translates to:
  /// **'İade ettim'**
  String get actionReturned;

  /// No description provided for @actionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj at'**
  String get actionMessage;

  /// No description provided for @notifResponseRest.
  ///
  /// In tr, this message translates to:
  /// **'“{item}” ilanına “İhtiyacım Var” dedi'**
  String notifResponseRest(String item);

  /// No description provided for @notifMessageRest.
  ///
  /// In tr, this message translates to:
  /// **'mesaj gönderdi: “{text}”'**
  String notifMessageRest(String text);

  /// No description provided for @notifAcceptedRest.
  ///
  /// In tr, this message translates to:
  /// **'“{item}” için ihtiyacını kabul etti'**
  String notifAcceptedRest(String item);

  /// No description provided for @emptyNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildirimin yok.'**
  String get emptyNotifications;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @statRating.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get statRating;

  /// No description provided for @statTransactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlem'**
  String get statTransactions;

  /// No description provided for @statOnTime.
  ///
  /// In tr, this message translates to:
  /// **'Zamanında'**
  String get statOnTime;

  /// No description provided for @sectionPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyenler'**
  String get sectionPending;

  /// No description provided for @pendingNewResponses.
  ///
  /// In tr, this message translates to:
  /// **'{n} yeni karşılık'**
  String pendingNewResponses(int n);

  /// No description provided for @pendingHandover.
  ///
  /// In tr, this message translates to:
  /// **'Teslim al'**
  String get pendingHandover;

  /// No description provided for @loansTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödünçlerim'**
  String get loansTitle;

  /// No description provided for @borrowed.
  ///
  /// In tr, this message translates to:
  /// **'Aldıklarım'**
  String get borrowed;

  /// No description provided for @lent.
  ///
  /// In tr, this message translates to:
  /// **'Verdiklerim'**
  String get lent;

  /// No description provided for @myListingsAndNeeds.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyaçlarım ve ilanlarım'**
  String get myListingsAndNeeds;

  /// No description provided for @themeAndLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Tema ve dil'**
  String get themeAndLanguage;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılsın mı?'**
  String get logoutTitle;

  /// No description provided for @logoutLine1.
  ///
  /// In tr, this message translates to:
  /// **'Hesabından çıkacaksın.'**
  String get logoutLine1;

  /// No description provided for @statusOnLoan.
  ///
  /// In tr, this message translates to:
  /// **'Ödünçte'**
  String get statusOnLoan;

  /// No description provided for @statusAwaiting.
  ///
  /// In tr, this message translates to:
  /// **'Teslim bekleniyor'**
  String get statusAwaiting;

  /// No description provided for @statusReturned.
  ///
  /// In tr, this message translates to:
  /// **'İade edildi'**
  String get statusReturned;

  /// No description provided for @actionReturn.
  ///
  /// In tr, this message translates to:
  /// **'İade et'**
  String get actionReturn;

  /// No description provided for @actionEarlyReturn.
  ///
  /// In tr, this message translates to:
  /// **'Erken iade'**
  String get actionEarlyReturn;

  /// No description provided for @actionScanQr.
  ///
  /// In tr, this message translates to:
  /// **'QR okut'**
  String get actionScanQr;

  /// No description provided for @actionShowQr.
  ///
  /// In tr, this message translates to:
  /// **'QR göster'**
  String get actionShowQr;

  /// No description provided for @qrScan.
  ///
  /// In tr, this message translates to:
  /// **'QR tara'**
  String get qrScan;

  /// No description provided for @sheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve dil'**
  String get sheetTitle;

  /// No description provided for @themeHeading.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get themeHeading;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @languageHeading.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languageHeading;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get languageSystem;

  /// No description provided for @languageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTr;

  /// No description provided for @languageEn.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @timeNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get timeNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} dk önce'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} sa önce'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün önce'**
  String timeDaysAgo(int n);

  /// No description provided for @timeYesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get timeYesterday;

  /// No description provided for @signupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Okul e-postanla başla'**
  String get signupTitle;

  /// No description provided for @signupExit.
  ///
  /// In tr, this message translates to:
  /// **'Kayıttan çık'**
  String get signupExit;

  /// No description provided for @stepAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get stepAccount;

  /// No description provided for @stepVerify.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama'**
  String get stepVerify;

  /// No description provided for @stepName.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get stepName;

  /// No description provided for @signupJoinCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Okul topluluğuna katılacaksın'**
  String get signupJoinCommunity;

  /// No description provided for @signupNewCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğun ilk kayıtla açılacak'**
  String get signupNewCommunity;

  /// No description provided for @signupPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifre belirle'**
  String get signupPasswordHint;

  /// No description provided for @signupPasswordRule.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter, bir harf ve bir rakam.'**
  String get signupPasswordRule;

  /// No description provided for @errorPasswordWeak.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter, bir harf ve bir rakam.'**
  String get errorPasswordWeak;

  /// No description provided for @errorTermsRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şartları kabul et.'**
  String get errorTermsRequired;

  /// No description provided for @errorEmailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı.'**
  String get errorEmailInUse;

  /// No description provided for @termsLead.
  ///
  /// In tr, this message translates to:
  /// **''**
  String get termsLead;

  /// No description provided for @termsLink.
  ///
  /// In tr, this message translates to:
  /// **'Şartları'**
  String get termsLink;

  /// No description provided for @termsMid.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get termsMid;

  /// No description provided for @privacyLink.
  ///
  /// In tr, this message translates to:
  /// **'gizliliği'**
  String get privacyLink;

  /// No description provided for @termsTail.
  ///
  /// In tr, this message translates to:
  /// **' kabul ediyorum.'**
  String get termsTail;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın var mı?'**
  String get haveAccount;

  /// No description provided for @sentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı gönderdik'**
  String get sentTitle;

  /// No description provided for @sentInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıya tıkla, sonra buraya dön.'**
  String get sentInstruction;

  /// No description provided for @sentWaiting.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama bekleniyor'**
  String get sentWaiting;

  /// No description provided for @openMailApp.
  ///
  /// In tr, this message translates to:
  /// **'Mail uygulamasını aç'**
  String get openMailApp;

  /// No description provided for @clickedLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıya tıkladım'**
  String get clickedLink;

  /// No description provided for @resendIn.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder ({time})'**
  String resendIn(String time);

  /// No description provided for @resendLink.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder'**
  String get resendLink;

  /// No description provided for @fixEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı düzelt'**
  String get fixEmail;

  /// No description provided for @notVerifiedYet.
  ///
  /// In tr, this message translates to:
  /// **'E-postan henüz doğrulanmadı.'**
  String get notVerifiedYet;

  /// No description provided for @linkResent.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı tekrar gönderildi.'**
  String get linkResent;

  /// No description provided for @nameTitle.
  ///
  /// In tr, this message translates to:
  /// **'Adın ne?'**
  String get nameTitle;

  /// No description provided for @nameSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Diğer kullanıcılar seni bu adla görecek.'**
  String get nameSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adını ve soyadını yaz'**
  String get nameHint;

  /// No description provided for @errorNameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Adını gir.'**
  String get errorNameEmpty;

  /// No description provided for @finish.
  ///
  /// In tr, this message translates to:
  /// **'Tamamla'**
  String get finish;

  /// No description provided for @expiredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantının süresi doldu'**
  String get expiredTitle;

  /// No description provided for @sendNewLink.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bağlantı gönder'**
  String get sendNewLink;

  /// No description provided for @legalTermsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım şartları'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsBody.
  ///
  /// In tr, this message translates to:
  /// **'Bende Var, aynı okulda ya da yurtta bulunan kişilerin birbirinin ihtiyacını ödünç alıp vererek karşıladığı bir topluluk uygulamasıdır.\n\n1. Hesap\nKurum e-postanla kayıt olursun ve okulunun topluluğuna katılırsın. Hesabının güvenliğinden sen sorumlusun.\n\n2. İlan ve ihtiyaç\nİlanlar eşyanı ödünç vermek, ihtiyaçlar ise bir eşya aramak içindir. Paylaştığın bilgilerin doğru olması gerekir.\n\n3. Ödünç alma ve verme\nTaraflar teslim yeri, süre ve koşullar üzerinde mesajlaşarak anlaşır. Uygulamada ödeme alınmaz. Eşyayı zamanında ve aldığın durumda iade etmek ödünç alan kişinin sorumluluğundadır.\n\n4. Davranış\nDiğer kullanıcılara saygılı davranırsın. Yasa dışı, tehlikeli ya da başkalarına ait eşyaları paylaşamazsın.\n\n5. Hesabın kapatılması\nBu şartları ihlal eden hesaplar kapatılabilir.\n\nBu metin örnek amaçlıdır ve nihai hukuki metin değildir.'**
  String get legalTermsBody;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu politika, Bende Var\'ın hangi bilgileri neden kullandığını açıklar.\n\n1. Topladığımız bilgiler\nKurum e-posta adresin, adın, paylaştığın ilanlar ve ihtiyaçlar, mesajların ve puanlamaların.\n\n2. Bilgileri nasıl kullanırız\nSeni okulunun topluluğuyla eşleştirmek, ödünç alma ve verme süreçlerini yürütmek, iade hatırlatmaları göndermek ve uygulamayı geliştirmek için kullanırız.\n\n3. Paylaşım\nAdın ve ilanların yalnızca topluluğundaki kullanıcılara görünür. Bilgilerini üçüncü kişilere satmayız.\n\n4. Saklama ve silme\nHesabını kapattığında kişisel bilgilerin silinir.\n\n5. Haklar\nBilgilerine erişmeyi, düzeltmeyi ve silmeyi isteyebilirsin.\n\nBu metin örnek amaçlıdır ve nihai hukuki metin değildir.'**
  String get legalPrivacyBody;

  /// No description provided for @forgotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni mi unuttun?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı yaz, sana bir bağlantı gönderelim.'**
  String get forgotSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı gönder'**
  String get sendResetLink;

  /// No description provided for @resetSentInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıya tıkla, sonra buraya dön.'**
  String get resetSentInstruction;

  /// No description provided for @resetExpired.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantının süresi doldu, yenisini iste.'**
  String get resetExpired;

  /// No description provided for @newPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre belirle'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreni gir'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreyi tekrar gir'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni tekrar yaz'**
  String get confirmPasswordHint;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get errorPasswordMismatch;

  /// No description provided for @savePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi kaydet'**
  String get savePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Şifren güncellendi.'**
  String get passwordUpdated;

  /// No description provided for @myCommunities.
  ///
  /// In tr, this message translates to:
  /// **'Topluluklarım'**
  String get myCommunities;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim ayarları'**
  String get notificationSettings;

  /// No description provided for @privacySupport.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve destek'**
  String get privacySupport;

  /// No description provided for @notifMessages.
  ///
  /// In tr, this message translates to:
  /// **'Yeni mesajlar'**
  String get notifMessages;

  /// No description provided for @notifMessagesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sana mesaj geldiğinde'**
  String get notifMessagesDesc;

  /// No description provided for @notifResponses.
  ///
  /// In tr, this message translates to:
  /// **'Yeni karşılıklar'**
  String get notifResponses;

  /// No description provided for @notifResponsesDesc.
  ///
  /// In tr, this message translates to:
  /// **'İhtiyacına biri “Bende var” dediğinde'**
  String get notifResponsesDesc;

  /// No description provided for @notifReminders.
  ///
  /// In tr, this message translates to:
  /// **'İade hatırlatması'**
  String get notifReminders;

  /// No description provided for @notifRemindersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ödünç aldığın ya da verdiğin eşyanın iade günü yaklaşınca'**
  String get notifRemindersDesc;

  /// No description provided for @notifRemindWhen.
  ///
  /// In tr, this message translates to:
  /// **'Ne zaman hatırlatalım?'**
  String get notifRemindWhen;

  /// No description provided for @notifRemindTwoDays.
  ///
  /// In tr, this message translates to:
  /// **'İade gününden 2 gün önce'**
  String get notifRemindTwoDays;

  /// No description provided for @notifRemindDayBefore.
  ///
  /// In tr, this message translates to:
  /// **'1 gün önce ve iade günü'**
  String get notifRemindDayBefore;

  /// No description provided for @notifRemindDayOf.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca iade günü'**
  String get notifRemindDayOf;

  /// No description provided for @blockedAccounts.
  ///
  /// In tr, this message translates to:
  /// **'Engellenenler'**
  String get blockedAccounts;

  /// No description provided for @helpSupport.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve destek'**
  String get helpSupport;

  /// No description provided for @blockedEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Engellediğin hesap yok.'**
  String get blockedEmpty;

  /// No description provided for @unblock.
  ///
  /// In tr, this message translates to:
  /// **'Engeli kaldır'**
  String get unblock;

  /// No description provided for @unblockTitle.
  ///
  /// In tr, this message translates to:
  /// **'Engeli kaldırmak istiyor musun?'**
  String get unblockTitle;

  /// No description provided for @unblockLine1.
  ///
  /// In tr, this message translates to:
  /// **'{name} sana yeniden mesaj gönderebilir.'**
  String unblockLine1(String name);

  /// No description provided for @unblockLine2.
  ///
  /// In tr, this message translates to:
  /// **'Onun ilanlarını ve ihtiyaçlarını yeniden görürsün.'**
  String get unblockLine2;

  /// No description provided for @unblocked.
  ///
  /// In tr, this message translates to:
  /// **'Engel kaldırıldı.'**
  String get unblocked;

  /// No description provided for @communitiesSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk ara'**
  String get communitiesSearchHint;

  /// No description provided for @communitiesMine.
  ///
  /// In tr, this message translates to:
  /// **'Topluluklarım'**
  String get communitiesMine;

  /// No description provided for @communitiesResults.
  ///
  /// In tr, this message translates to:
  /// **'Arama sonuçları'**
  String get communitiesResults;

  /// No description provided for @communitiesNoResults.
  ///
  /// In tr, this message translates to:
  /// **'Bu aramaya uygun topluluk bulunamadı.'**
  String get communitiesNoResults;

  /// No description provided for @communityMembers.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 üye} other{{count} üye}}'**
  String communityMembers(int count);

  /// No description provided for @communityFounderBadge.
  ///
  /// In tr, this message translates to:
  /// **'Kurucu'**
  String get communityFounderBadge;

  /// No description provided for @communityNewBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get communityNewBadge;

  /// No description provided for @communityJoin.
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get communityJoin;

  /// No description provided for @communityMember.
  ///
  /// In tr, this message translates to:
  /// **'Üyesin'**
  String get communityMember;

  /// No description provided for @communityJoined.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğa katıldın.'**
  String get communityJoined;

  /// No description provided for @communityLeave.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıl'**
  String get communityLeave;

  /// No description provided for @joinWithCode.
  ///
  /// In tr, this message translates to:
  /// **'Davet koduyla katıl'**
  String get joinWithCode;

  /// No description provided for @createCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk oluştur'**
  String get createCommunity;

  /// No description provided for @inviteCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet koduyla katıl'**
  String get inviteCodeTitle;

  /// No description provided for @inviteCodeHint.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get inviteCodeHint;

  /// No description provided for @inviteCodeInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Bu kod geçerli değil. Kodu kontrol edip tekrar dene.'**
  String get inviteCodeInvalid;

  /// No description provided for @inviteCodeAlready.
  ///
  /// In tr, this message translates to:
  /// **'Bu topluluğun zaten üyesisin.'**
  String get inviteCodeAlready;

  /// No description provided for @inviteCodeSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğa katıldın'**
  String get inviteCodeSuccessTitle;

  /// No description provided for @inviteCodeSuccessBody.
  ///
  /// In tr, this message translates to:
  /// **'{name} topluluğuna katıldın.'**
  String inviteCodeSuccessBody(String name);

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @createCommunityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk oluştur'**
  String get createCommunityTitle;

  /// No description provided for @communityNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk adı'**
  String get communityNameLabel;

  /// No description provided for @communityNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Kamp Kulübü'**
  String get communityNameHint;

  /// No description provided for @communityNameError.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk adı en az 3 karakter olmalı.'**
  String get communityNameError;

  /// No description provided for @communityNameAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu ad kullanılabilir.'**
  String get communityNameAvailable;

  /// No description provided for @communityNameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu ad zaten kullanılıyor.'**
  String get communityNameTaken;

  /// No description provided for @communityIconLabel.
  ///
  /// In tr, this message translates to:
  /// **'Simge'**
  String get communityIconLabel;

  /// No description provided for @communityCreateSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get communityCreateSubmit;

  /// No description provided for @communityVisibilityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kim görebilir?'**
  String get communityVisibilityLabel;

  /// No description provided for @visibilityOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get visibilityOpen;

  /// No description provided for @visibilityOpenDesc.
  ///
  /// In tr, this message translates to:
  /// **'Herkes adıyla arayıp katılabilir.'**
  String get visibilityOpenDesc;

  /// No description provided for @visibilitySchool.
  ///
  /// In tr, this message translates to:
  /// **'Okula özel'**
  String get visibilitySchool;

  /// No description provided for @visibilitySchoolDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sadece okulundaki kişiler adıyla arayıp katılabilir.'**
  String get visibilitySchoolDesc;

  /// No description provided for @visibilitySecret.
  ///
  /// In tr, this message translates to:
  /// **'Gizli'**
  String get visibilitySecret;

  /// No description provided for @visibilitySecretDesc.
  ///
  /// In tr, this message translates to:
  /// **'Aramada çıkmaz. Sadece davet koduyla girilir.'**
  String get visibilitySecretDesc;

  /// No description provided for @visibilityOpenHint.
  ///
  /// In tr, this message translates to:
  /// **'Açık: herkes adıyla arayıp katılabilir.'**
  String get visibilityOpenHint;

  /// No description provided for @visibilitySchoolHint.
  ///
  /// In tr, this message translates to:
  /// **'Okula özel: sadece okulundaki kişiler adıyla arayıp katılabilir.'**
  String get visibilitySchoolHint;

  /// No description provided for @visibilitySecretHint.
  ///
  /// In tr, this message translates to:
  /// **'Gizli: aramada çıkmaz, sadece davet koduyla girilir.'**
  String get visibilitySecretHint;

  /// No description provided for @communityCreated.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk oluşturuldu.'**
  String get communityCreated;

  /// No description provided for @founderActionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kurucu işlemleri'**
  String get founderActionsTitle;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu kopyalandı.'**
  String get inviteCodeCopied;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Davet kodu'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCopyAction.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get inviteCopyAction;

  /// No description provided for @inviteShareAction.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get inviteShareAction;

  /// No description provided for @inviteShareCopied.
  ///
  /// In tr, this message translates to:
  /// **'Davet metni kopyalandı.'**
  String get inviteShareCopied;

  /// No description provided for @inviteShareText.
  ///
  /// In tr, this message translates to:
  /// **'“{name}” topluluğuna katıl! Bende Var uygulamasında “Davet koduyla katıl” bölümüne {code} kodunu gir.'**
  String inviteShareText(String name, String code);

  /// No description provided for @deleteCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğu sil'**
  String get deleteCommunity;

  /// No description provided for @deleteCommunityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğu silmek istiyor musun?'**
  String get deleteCommunityTitle;

  /// No description provided for @deleteCommunityLine1.
  ///
  /// In tr, this message translates to:
  /// **'{name} topluluğu ve üyelikler kalıcı olarak silinir.'**
  String deleteCommunityLine1(String name);

  /// No description provided for @deleteCommunityLine2.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz.'**
  String get deleteCommunityLine2;

  /// No description provided for @communityDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk silindi.'**
  String get communityDeleted;

  /// No description provided for @leaveCommunityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluktan ayrılmak istiyor musun?'**
  String get leaveCommunityTitle;

  /// No description provided for @leaveCommunityLine1.
  ///
  /// In tr, this message translates to:
  /// **'{name} topluluğundan ayrılırsan ilanlarını ve ihtiyaçlarını orada göremezsin.'**
  String leaveCommunityLine1(String name);

  /// No description provided for @leaveCommunityLine2.
  ///
  /// In tr, this message translates to:
  /// **'İstersen sonra yeniden katılabilirsin.'**
  String get leaveCommunityLine2;

  /// No description provided for @communityLeft.
  ///
  /// In tr, this message translates to:
  /// **'Topluluktan ayrıldın.'**
  String get communityLeft;

  /// No description provided for @emailAsciiHint.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe karakter ve büyük harfi düzelttik.'**
  String get emailAsciiHint;

  /// No description provided for @doneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin, {name}!'**
  String doneTitle(String name);

  /// No description provided for @doneSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{community} topluluğuna katıldın.'**
  String doneSubtitle(String community);

  /// No description provided for @doneSlogan.
  ///
  /// In tr, this message translates to:
  /// **'Elinde olanı paylaş, ihtiyacın olanı bul.'**
  String get doneSlogan;

  /// No description provided for @doneStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get doneStart;

  /// No description provided for @rememberMe.
  ///
  /// In tr, this message translates to:
  /// **'Beni hatırla'**
  String get rememberMe;

  /// No description provided for @loadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get loadFailed;

  /// No description provided for @actionFailed.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı.'**
  String get actionFailed;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @stepSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{label} ({step}/{total})'**
  String stepSemantics(String label, int step, int total);

  /// No description provided for @inviteContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get inviteContinue;

  /// No description provided for @helpIntro.
  ///
  /// In tr, this message translates to:
  /// **'Takıldığın bir şey mi var? Sık sorulanlara göz at.'**
  String get helpIntro;

  /// No description provided for @helpQ1.
  ///
  /// In tr, this message translates to:
  /// **'Bir topluluğa nasıl katılırım?'**
  String get helpQ1;

  /// No description provided for @helpA1.
  ///
  /// In tr, this message translates to:
  /// **'Okul topluluğuna kurum e-postanla otomatik katılırsın. Diğerlerini Topluluklarım\'da arayabilir ya da 6 haneli davet koduyla katılabilirsin.'**
  String get helpA1;

  /// No description provided for @helpQ2.
  ///
  /// In tr, this message translates to:
  /// **'Beni hatırla ne işe yarar?'**
  String get helpQ2;

  /// No description provided for @helpA2.
  ///
  /// In tr, this message translates to:
  /// **'Açıkken uygulamayı kapatıp açınca giriş yapmadan devam edersin. Çıkış yapınca unutulur.'**
  String get helpA2;

  /// No description provided for @helpQ3.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum, ne yapmalıyım?'**
  String get helpQ3;

  /// No description provided for @helpA3.
  ///
  /// In tr, this message translates to:
  /// **'Giriş ekranında \"Şifremi unuttum\"a dokun; e-postana bir yenileme bağlantısı gönderelim.'**
  String get helpA3;

  /// No description provided for @helpContact.
  ///
  /// In tr, this message translates to:
  /// **'Hâlâ çözemedin mi? Bize yaz:'**
  String get helpContact;

  /// No description provided for @helpContactEmail.
  ///
  /// In tr, this message translates to:
  /// **'destek@bendevar.app'**
  String get helpContactEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
