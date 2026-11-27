// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get brandName => 'Bende Var';

  @override
  String get slogan => 'İhtiyacın topluluğunda.';

  @override
  String get welcomeTitle => 'Elinde olan paylaşır,\nihtiyacı olan bulur.';

  @override
  String get welcomeSubtitle =>
      'Okul mailinle giriş yap, kampüsün seni bekliyor.';

  @override
  String get login => 'Giriş yap';

  @override
  String get signup => 'Kayıt ol';

  @override
  String get loginTitle => 'Tekrar hoş geldin';

  @override
  String get loginSubtitle => 'Kurum e-postan ve şifrenle devam et.';

  @override
  String get emailLabel => 'Kurum e-postası';

  @override
  String get emailHint => 'ad.soyad@okul.edu.tr';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordHint => 'Şifreni gir';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get noAccount => 'Hesabın yok mu?';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get back => 'Geri';

  @override
  String get close => 'Kapat';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get more => 'Diğer';

  @override
  String get errorEmailEmpty => 'E-posta adresini gir.';

  @override
  String get errorEmailNotEdu =>
      'Kurum e-postanla (.edu.tr ile biten adres) giriş yapmalısın.';

  @override
  String get errorPasswordEmpty => 'Şifreni gir.';

  @override
  String get emailHintShort => 'ad.soyad@okul';

  @override
  String get errorAccountNotFound =>
      'Bu e-postayla kayıtlı bir hesap bulamadık. E-postanı kontrol et ya da kayıt ol.';

  @override
  String get errorPasswordWrong => 'Şifre yanlış. Tekrar dene.';

  @override
  String get errorTooManyAttempts =>
      'Çok fazla hatalı deneme yaptın. Biraz bekleyip tekrar dene ya da şifreni sıfırla.';

  @override
  String get resetPasswordAction => 'Şifremi sıfırla';

  @override
  String get errorNotVerified =>
      'Hesabın henüz doğrulanmamış. E-postana gönderdiğimiz bağlantıya tıkla.';

  @override
  String get resendVerification => 'Bağlantıyı tekrar gönder';

  @override
  String get verificationSent => 'Doğrulama bağlantısı gönderildi.';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navMessages => 'Mesajlar';

  @override
  String get navCreate => 'İlan veya ihtiyaç oluştur';

  @override
  String get navNotifications => 'Bildirimler';

  @override
  String get navProfile => 'Profil';

  @override
  String get communityLabel => 'Topluluk';

  @override
  String get searchHint => 'Ne arıyorsun? Ürün veya eşya...';

  @override
  String get voiceSearch => 'Sesli arama';

  @override
  String get filters => 'Filtreler';

  @override
  String tabListings(int n) {
    return 'İlanlar · $n';
  }

  @override
  String tabNeeds(int n) {
    return 'İhtiyaçlar · $n';
  }

  @override
  String countListings(int n) {
    return '$n ilan';
  }

  @override
  String countNeeds(int n) {
    return '$n ihtiyaç';
  }

  @override
  String get sortNewest => 'En yeni';

  @override
  String get sortOldest => 'En eski';

  @override
  String get emptyResults => 'Sonuç bulunamadı.';

  @override
  String get emptyFavorites => 'Henüz favorin yok.';

  @override
  String get showFavorites => 'Favorileri göster';

  @override
  String get showAll => 'Tümünü göster';

  @override
  String get favoriteAdd => 'Favorilere ekle';

  @override
  String get favoriteRemove => 'Favorilerden çıkar';

  @override
  String get respondHaveIt => 'Bende Var';

  @override
  String get comingSoonTitle => 'Yakında';

  @override
  String get comingSoonBody => 'Bu özellik henüz hazır değil.';

  @override
  String get comingSoonSnack => 'Bu özellik yakında geliyor.';

  @override
  String get categoryBook => 'Ders kitabı';

  @override
  String get categoryElectronics => 'Elektronik';

  @override
  String get categoryDorm => 'Yurt eşyası';

  @override
  String get categorySports => 'Spor';

  @override
  String get conditionNew => 'Yeni';

  @override
  String get conditionLightlyUsed => 'Az kullanılmış';

  @override
  String get conditionUsed => 'Kullanılmış';

  @override
  String get modeLend => 'Ödünç';

  @override
  String get modeSell => 'Satılık';

  @override
  String get priceFree => 'Ücretsiz';

  @override
  String get pricePaid => 'Ücretli';

  @override
  String get priceDaily => 'Günlük';

  @override
  String get priceTotal => 'Toplam';

  @override
  String get priceHint => 'Tutar (₺)';

  @override
  String get urgencyUrgent => 'Acil';

  @override
  String get urgencyThisWeek => 'Bu hafta';

  @override
  String get urgencyFlexible => 'Esnek';

  @override
  String get detailTitleListing => 'İlan detayı';

  @override
  String get detailTitleNeed => 'İhtiyaç detayı';

  @override
  String get badgeIlan => 'İLAN';

  @override
  String get badgeNeed => 'İHTİYAÇ';

  @override
  String get badgeIlanLarge => 'İLAN · VERİYORUM';

  @override
  String get badgeNeedLarge => 'İHTİYAÇ · ARIYORUM';

  @override
  String get statusPublished => 'YAYINDA';

  @override
  String get statusPublishedShort => 'Yayında';

  @override
  String get rowCategory => 'Kategori';

  @override
  String get rowCondition => 'Ürün durumu';

  @override
  String get rowMode => 'Veriliş şekli';

  @override
  String get rowPrice => 'Ücret';

  @override
  String get rowAvailable => 'Müsait';

  @override
  String get rowNeededWhen => 'Ne zaman lazım';

  @override
  String get rowUrgency => 'Aciliyet';

  @override
  String get rowCommunity => 'Topluluk';

  @override
  String get favorite => 'Favorile';

  @override
  String get favorited => 'Favorilerde';

  @override
  String get actionBorrow => 'Ödünç iste';

  @override
  String get actionBuy => 'Satın al';

  @override
  String get share => 'Paylaş';

  @override
  String get createIlanTitle => 'Bende var';

  @override
  String get createIlanSubtitle => 'Elindeki eşyayı ödünç ver';

  @override
  String get createNeedTitle => 'İhtiyacım var';

  @override
  String get createNeedSubtitle => 'Aradığın eşyayı ödünç al';

  @override
  String get newListingTitle => 'Yeni ilan';

  @override
  String get newNeedTitle => 'Yeni ihtiyaç';

  @override
  String get sectionItem => 'Eşya bilgileri';

  @override
  String get sectionTerms => 'Ödünç koşulları';

  @override
  String get fieldPhotos => 'Fotoğraflar *';

  @override
  String get photoAdd => 'Ekle';

  @override
  String get fieldTitle => 'Eşya adı *';

  @override
  String get fieldCategory => 'Kategori *';

  @override
  String get fieldCondition => 'Ürün durumu *';

  @override
  String get fieldDescription => 'Açıklama';

  @override
  String get fieldAvailability => 'Müsaitlik tarihleri *';

  @override
  String get fieldNeededWhen => 'Ne zaman lazım? *';

  @override
  String get fieldMode => 'Veriliş şekli';

  @override
  String get fieldUrgency => 'Aciliyet *';

  @override
  String get fieldPrice => 'Ücret *';

  @override
  String get datePick => 'Tarih seç';

  @override
  String get errorRequired => 'Bu alan boş bırakılamaz.';

  @override
  String get errorChoose => 'Bir seçenek seç.';

  @override
  String get errorDates =>
      'Başlangıç ve bitiş tarihini seç; bitiş başlangıçtan önce olamaz.';

  @override
  String get errorPrice => 'Geçerli bir tutar gir.';

  @override
  String get publish => 'Yayınla';

  @override
  String get publishedTitleListing => 'İlanın yayınlandı';

  @override
  String get publishedBodyListing =>
      'İlanın, seçilen toplulukların İlanlar sekmesinde görünür. Biri \"İhtiyacım Var\" dediğinde bildirim alırsın.';

  @override
  String get publishedTitleNeed => 'İhtiyacın yayınlandı';

  @override
  String get publishedBodyNeed =>
      'İhtiyacın, topluluğunun İhtiyaçlar sekmesinde görünür. Biri \"Bende Var\" dediğinde bildirim alırsın.';

  @override
  String get view => 'Görüntüle';

  @override
  String get backToHome => 'Ana sayfaya dön';

  @override
  String get messagesTitle => 'Mesajlar';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterUnread => 'Okunmamış';

  @override
  String get filterActive => 'Aktif';

  @override
  String get filterPast => 'Geçmiş';

  @override
  String get emptyMessages => 'Henüz mesajın yok.';

  @override
  String get respondedNeedIt => '“İhtiyacım Var” dedi';

  @override
  String get respondedHaveIt => '“Bende Var” dedi';

  @override
  String get bubbleNeedIt => 'İhtiyacım Var';

  @override
  String get bubbleHaveIt => 'Bende Var';

  @override
  String get accepted => 'Kabul edildi';

  @override
  String get agreementSummary => 'Anlaşma özeti';

  @override
  String get agreementDetail => 'Anlaşma detayı';

  @override
  String get messageHint => 'Mesaj yaz';

  @override
  String get send => 'Gönder';

  @override
  String get sendMessage => 'Mesaj gönder';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get markAllRead => 'Tümünü oku';

  @override
  String get sectionUpcomingReturns => 'Yaklaşan iadeler';

  @override
  String get sectionToday => 'Bugün';

  @override
  String get sectionThisWeek => 'Bu hafta';

  @override
  String daysLate(int n) {
    return '$n gün gecikti';
  }

  @override
  String get tomorrow => 'Yarın';

  @override
  String notifOverdueBody(String name) {
    return '$name adlı kişiye iade etmen gerekiyordu.';
  }

  @override
  String notifDueSoonBody(String name) {
    return '$name sana iade edecek.';
  }

  @override
  String get actionReturned => 'İade ettim';

  @override
  String get actionMessage => 'Mesaj at';

  @override
  String notifResponseRest(String item) {
    return '“$item” ilanına “İhtiyacım Var” dedi';
  }

  @override
  String notifMessageRest(String text) {
    return 'mesaj gönderdi: “$text”';
  }

  @override
  String notifAcceptedRest(String item) {
    return '“$item” için ihtiyacını kabul etti';
  }

  @override
  String get emptyNotifications => 'Yeni bildirimin yok.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get edit => 'Düzenle';

  @override
  String get statRating => 'Puan';

  @override
  String get statTransactions => 'İşlem';

  @override
  String get statOnTime => 'Zamanında';

  @override
  String get sectionPending => 'Bekleyenler';

  @override
  String pendingNewResponses(int n) {
    return '$n yeni karşılık';
  }

  @override
  String get pendingHandover => 'Teslim al';

  @override
  String get loansTitle => 'Ödünçlerim';

  @override
  String get borrowed => 'Aldıklarım';

  @override
  String get lent => 'Verdiklerim';

  @override
  String get myListingsAndNeeds => 'İhtiyaçlarım ve ilanlarım';

  @override
  String get themeAndLanguage => 'Tema ve dil';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get logoutTitle => 'Çıkış yapmak istiyor musun?';

  @override
  String get logoutLine1 => 'Bu telefondaki oturumun kapanır.';

  @override
  String get logoutLine2 =>
      'Tekrar girmek için kurum e-postan ve şifren gerekir.';

  @override
  String get logoutLine3 =>
      'Bu telefona bildirim gelmez; iade hatırlatmaları da durur.';

  @override
  String get statusOnLoan => 'Ödünçte';

  @override
  String get statusAwaiting => 'Teslim bekleniyor';

  @override
  String get statusReturned => 'İade edildi';

  @override
  String get actionReturn => 'İade et';

  @override
  String get actionEarlyReturn => 'Erken iade';

  @override
  String get actionScanQr => 'QR okut';

  @override
  String get actionShowQr => 'QR göster';

  @override
  String get qrScan => 'QR tara';

  @override
  String get sheetTitle => 'Görünüm ve dil';

  @override
  String get themeHeading => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get languageHeading => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageTr => 'Türkçe';

  @override
  String get languageEn => 'English';

  @override
  String get timeNow => 'Şimdi';

  @override
  String timeMinutesAgo(int n) {
    return '$n dk önce';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n sa önce';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n gün önce';
  }

  @override
  String get timeYesterday => 'Dün';

  @override
  String get signupTitle => 'Okul e-postanla başla';

  @override
  String get signupSubtitle =>
      'Topluluğun e-posta uzantısından bulunur. Sana bir doğrulama bağlantısı göndereceğiz.';

  @override
  String get signupExit => 'Kayıttan çık';

  @override
  String get stepAccount => 'Hesap';

  @override
  String get stepVerify => 'Doğrulama';

  @override
  String get stepName => 'Adın';

  @override
  String get signupJoinCommunity => 'Okul topluluğuna katılacaksın';

  @override
  String get signupNewCommunity => 'Topluluğun ilk kayıtla açılacak';

  @override
  String get signupPasswordHint => 'Şifre belirle';

  @override
  String get signupPasswordRule =>
      'En az 8 karakter, en az bir harf ve bir rakam.';

  @override
  String get errorPasswordWeak =>
      'Şifren en az 8 karakter olmalı, en az bir harf ve bir rakam içermeli.';

  @override
  String get errorTermsRequired => 'Devam etmek için şartları kabul etmelisin.';

  @override
  String get errorEmailInUse => 'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.';

  @override
  String get termsLead => '';

  @override
  String get termsLink => 'Kullanım şartlarını';

  @override
  String get termsMid => ' ve ';

  @override
  String get privacyLink => 'gizlilik politikasını';

  @override
  String get termsTail => ' okudum, kabul ediyorum.';

  @override
  String get haveAccount => 'Hesabın var mı?';

  @override
  String get sentTitle => 'Bağlantıyı gönderdik';

  @override
  String get sentSubtitle => 'Doğrulama bağlantısını şu adrese gönderdik:';

  @override
  String get sentInstruction =>
      'Okul e-postandaki bağlantıya tıkla, sonra buraya dön ve \"Bağlantıya tıkladım\" düğmesine bas. Bağlantı 24 saat geçerlidir.';

  @override
  String get sentWaiting => 'Doğrulama bekleniyor';

  @override
  String get openMailApp => 'Mail uygulamasını aç';

  @override
  String get clickedLink => 'Bağlantıya tıkladım';

  @override
  String resendIn(String time) {
    return 'Tekrar gönder ($time)';
  }

  @override
  String get resendLink => 'Tekrar gönder';

  @override
  String get fixEmail => 'E-postayı düzelt';

  @override
  String get notVerifiedYet =>
      'E-postan henüz doğrulanmadı. Bağlantıya tıkladığından emin ol.';

  @override
  String get linkResent => 'Bağlantı tekrar gönderildi.';

  @override
  String get nameTitle => 'Adın ne?';

  @override
  String get nameSubtitle =>
      'Diğer kullanıcılar seni bu adla görecek. Gerekirse düzenleyebilirsin.';

  @override
  String get nameLabel => 'Ad Soyad';

  @override
  String get nameHint => 'Adını ve soyadını yaz';

  @override
  String get errorNameEmpty => 'Adını gir.';

  @override
  String get finish => 'Tamamla';

  @override
  String get expiredTitle => 'Bağlantının süresi doldu';

  @override
  String get expiredBody =>
      'Doğrulama bağlantısı 24 saat geçerliydi. Sana yeni bir bağlantı gönderebiliriz.';

  @override
  String get sendNewLink => 'Yeni bağlantı gönder';

  @override
  String get legalTermsTitle => 'Kullanım şartları';

  @override
  String get legalPrivacyTitle => 'Gizlilik politikası';

  @override
  String get legalTermsBody =>
      'Bende Var, aynı okulda ya da yurtta bulunan kişilerin birbirinin ihtiyacını ödünç alıp vererek karşıladığı bir topluluk uygulamasıdır.\n\n1. Hesap\nKurum e-postanla kayıt olursun ve okulunun topluluğuna katılırsın. Hesabının güvenliğinden sen sorumlusun.\n\n2. İlan ve ihtiyaç\nİlanlar eşyanı ödünç vermek, ihtiyaçlar ise bir eşya aramak içindir. Paylaştığın bilgilerin doğru olması gerekir.\n\n3. Ödünç alma ve verme\nTaraflar teslim yeri, süre ve koşullar üzerinde mesajlaşarak anlaşır. Uygulamada ödeme alınmaz. Eşyayı zamanında ve aldığın durumda iade etmek ödünç alan kişinin sorumluluğundadır.\n\n4. Davranış\nDiğer kullanıcılara saygılı davranırsın. Yasa dışı, tehlikeli ya da başkalarına ait eşyaları paylaşamazsın.\n\n5. Hesabın kapatılması\nBu şartları ihlal eden hesaplar kapatılabilir.\n\nBu metin örnek amaçlıdır ve nihai hukuki metin değildir.';

  @override
  String get legalPrivacyBody =>
      'Bu politika, Bende Var\'ın hangi bilgileri neden kullandığını açıklar.\n\n1. Topladığımız bilgiler\nKurum e-posta adresin, adın, paylaştığın ilanlar ve ihtiyaçlar, mesajların ve puanlamaların.\n\n2. Bilgileri nasıl kullanırız\nSeni okulunun topluluğuyla eşleştirmek, ödünç alma ve verme süreçlerini yürütmek, iade hatırlatmaları göndermek ve uygulamayı geliştirmek için kullanırız.\n\n3. Paylaşım\nAdın ve ilanların yalnızca topluluğundaki kullanıcılara görünür. Bilgilerini üçüncü kişilere satmayız.\n\n4. Saklama ve silme\nHesabını kapattığında kişisel bilgilerin silinir.\n\n5. Haklar\nBilgilerine erişmeyi, düzeltmeyi ve silmeyi isteyebilirsin.\n\nBu metin örnek amaçlıdır ve nihai hukuki metin değildir.';
}
