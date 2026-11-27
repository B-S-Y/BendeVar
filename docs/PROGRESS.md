# İlerleme

Kurallar: `CLAUDE.md`. Sapmalar: `docs/DEVIATIONS.md`. Ek token'lar: `docs/DESIGN_TOKENS_EK.md`.

## Faz 1: Kaynak kontrolü — [x]
Tüm dosyalar vardı (zip'ler açıldı). Ek ölçüler ve eksik koyu roller belgelendi.

## Faz 2: İskelet — [x]
flutter create (minSdk 23), Inter TTF, logo, açık+koyu tema token'ları, Theme/Locale controller, ARB (TR/EN), ortak widget'lar, modeller, repository + mock, DI, go_router. `flutter analyze` temiz.

## Faz 3: Ekranlar — [x]
- [x] 1.01 Karşılama, 1.02 Giriş (sahte giriş, .edu.tr doğrulaması)
- [x] 2.01 Ana Sayfa (arama, segment, kategori çipi, sıralama, favori), 2.14 Detay
- [x] 3.01 panel, 3.02 ilan formu, 3.11 ihtiyaç formu, 3.07 yayınlandı (doğrulama; yeni kayıt en üstte)
- [x] 4.01 Mesajlar, 4.05 Sohbet (mesaj gönderme), 4.07 Bildirimler
- [x] 5.01 Profil, 5.07 Ödünçlerim, tema/dil sheet, 1.15b çıkış onayı

## Faz 4: Doğrulama ve teslim — [x]
33 test geçiyor (validator, ViewModel, alt menü, 4 tema×dil kombinasyonu, tam akış), `flutter analyze` temiz, sabit değer grep'i temiz, debug APK derlendi: `build/app/outputs/flutter-apk/app-debug.apk`, README yazıldı.

## Sıradaki adım
- Gerçek cihazda/emülatörde görsel karşılaştırma (PNG ile) ve ince ayar.
- Koyu tema "geçici" renklerini belge güncellenince `app_colors.dart`'ta düzelt.
- Kapsam dışı ekranlar: kayıt, filtre paneli, QR, ayarlar; sonra Firebase (README).

## Eda · 1.xx modülü (dal: eda/giris-kayit-ayarlar)
- [x] Görev 1 (yeniden yapıldı, ANIMASYON_1.01.md'ye göre): tek `AuthStage` sahnesi; tek açılış controller'ı + Interval'ler (3,52 sn), 130 yıldız ve leke ayrı sürekli controller, halka/parçacık patlaması, panel 330→700 ve form öğelerinin sıralı gelişi, geri dönüşte ters oynatma. "Animasyonları azalt" açıkken son kare. 1.09 zarf animasyonu Görev 3'te. Dosyalar: `features/auth/view/auth_{stage,motion,backdrop,burst,stars}.dart`, `login_form.dart`.
- [x] `EnvelopeAnimation` (1.09 zarfı, `lib/core/widgets/envelope_animation.dart`): bir kez oynar, açık zarf + tikte durur, azalt açıksa son kare. Ekrana Görev 3'te konacak.
- [x] Görev 2: ortak `InstitutionEmailField`/`InstitutionEmailController` (`core/widgets/institution_email_field.dart`, giriş ve kayıtta ortak), giriş hataları 1.03a/b/c ve 1.04 (`AuthFailure`, `AuthException`, `AuthNotice`), `Validators.schoolId`, `AuthRepository.sendVerification`. 50 test geçiyor.
- [x] Görev 2 düzeltme: mock giriş yalnızca kayıtlı hesaplarla (6 hesap, şifre `sifre123`, Sudem doğrulanmamış), `accountNotFound` hatası, e-posta alanında Türkçe karakter → ASCII + küçük harf. 54 test geçiyor.
- [x] Görev 3: Kayıt. 1.08/1.08a karşılama panelinde (giriş ↔ kayıt geçişi aynı panelde), 1.09 (zarf animasyonlu, geri sayım, resume kontrolü), 1.10 Adın ne?, 1.10a/b yasal sayfalar (`/legal/terms`, `/legal/privacy`; Ayarlar'da 1.19a/b için de kullanılacak), 1.12 süresi doldu. `AuthRepository` (signUp, checkVerification, completeSignUp), `CommunityRepository` (mock, DI'da), `AuthViewModel` genişledi. Kayıtta ortak `InstitutionEmailField`. 65 test geçiyor.
- [x] Görev 4: Şifre sıfırlama 1.05 (`/forgot`), 1.06 (`/forgot/sent`, zarf animasyonlu), 1.07 (`/forgot/new`). `AuthRepository.requestPasswordReset/checkPasswordReset/confirmPasswordReset`, `AuthViewModel` genişledi. 73 test geçiyor.
- [x] Düzeltme: 1.03c kutusundan "Şifremi sıfırla" kaldırıldı, kilit 30 sn (`MockAuthRepository.lockDuration`), 1.07'de iki şifre alanının bağımsız göz ikonları. 74 test geçiyor.
- [x] Görev 5: Ayarlar. 1.15 (`/settings`), 1.15b çıkış onayı (mevcut sheet), 1.18 (`/settings/notifications`), 1.19 (`/settings/privacy`), 1.19a/b (`/settings/terms`, `/settings/privacy-policy`), 1.20 (`/settings/blocked`), 1.21 onay sheet'i. `SettingsRepository` (mock, DI'da), `SettingsViewModel` (app seviyesinde). Profil'deki dişli ikonu henüz `/settings`'e bağlı değil (başkasının dosyası). 79 test geçiyor.

- Profil dişli ikonu artık /settings (1.15) rotasına gidiyor (profile_page.dart tek satır). Topluluklarım satırı Görev 6'ya kadar ComingSoon.

- Görev 6 (Topluluklar 1.16–1.17) bitti: `CommunityRepository` genişletildi (arama, katıl, kod, oluştur, ayrıl, sil; mock bellekte), `CommunityViewModel`, `community_pages.dart` (1.16/1.16g/1.16b-c/1.16d/1.16e/1.16f/1.17), rotalar `/communities`, `/communities/create`. Testler: `test/community_test.dart`.
- Düzeltme turu A: giriş kutusu en üste kayar (A4), e-posta ASCII ipucu (A5); A1-A3 önceden yapılmıştı. Testler: test/polish_test.dart.
- Düzeltme turu B: kod değişikliği gerekmedi (B1, B2 önceden yapılmıştı); notlar DEVIATIONS.md'de.
- Düzeltme turu C: arama girişte sıfırlanır, davet kodu yalnızca gizli topluluklarda; testler community_test.dart.
- Düzeltme turu D: hareket token'ları (app_motion.dart), ortak sayfa geçişi, düğme basılma, alan titremesi, liste girişi, yumuşak tema geçişi. D4 için ayrı 'kayıt tamamlandı' ekranı yok (zarf+tik 1.06/1.09'da var). Testler: test/motion_test.dart.
- D6 geri alındı (tema geçişi eski hâlinde); D1/D2/D3/D5 duruyor.
- Kayıt tamamlandı ekranı (/signup/done): SuccessCheck + SignupDonePage, 1.10 sonrası; test/signup_done_test.dart.
- Çıkış onayı sadeleştirildi (başlık + tek satır).
- Beni hatırla: AppCheckbox, signIn(remember), restoreSession (main.dart); testler test/remember_test.dart.
- Giriş → Ana Sayfa solma/büyüme geçişi (router.dart _authEntryPage/_shellPage); test/login_transition_test.dart.
- Kısa açılış kapısı (/splash, SplashPage): Beni hatırla açılışında logo animasyonu + solma ile Ana Sayfa; testler test/splash_test.dart.
- Kontrol turu commit 1: kullanıcıya göre topluluk üyeliği, restore try/finally, DI zorunlu, redirect, çıkışta VM sıfırlama, CurvedAnimation dispose; test/fixes_test.dart.
- Kontrol turu commit 2: yükleniyor/hata/Tekrar dene, alt güvenli alan; test/error_states_test.dart.
- Kontrol turu commit 3: emailHint silindi, adım etiketi ARB'de, sihirli sayılar token'da (DESIGN_TOKENS_EK.md), koyu tema tablosu tamamlandı, nameFromEmail testi, IDE/derleme dosyaları git takibinden çıktı.
- Okul kimliği testleri (boun, std.bogazici, ogr.msgsu, rakamlı, .edu.tr sınırı) ve okula özel doğrudan katılma denetimi.
- Revize 4: kullanıcı kimliği tam e-posta (topluluk sızıntısı kök nedeni); test/community_leak_test.dart.
- Revize 7: TextSearch (Türkçe duyarlı arama); test/text_search_test.dart.
- Revize 6: okul topluluğu satırı etiketsiz, koyu çerçeveli.
- Revize 8: 6 haneli rakam davet kodu, sayısal alan, pasif Devam, önizleme + Katıl/Vazgeç.
- Revize 3: okul kartı debounce (500 ms, >=3 harf), bilinen okul listesi, kişisel e-posta engeli; test/school_card_test.dart.
- Revize 1: kısa açılışta halkalar (BurstPainter, parçacıksız).
- Revize 2: zarf tasarım C (daire + halka, envelopeDisc/Body/Ring tokenları).
- Revize 5: şifre sıfırlama ekranları sadeleştirildi.
- Revize 10: Yardım ve destek sayfası. Revize 9: tek başına/uygulama içi ekran görüntüsüyle artık bulunamadı, kod değişmedi.
- Revize 11: klavye açıkken panel tabanı kalktı (küçük ekranda başlık dışarı itilmez); otomatik odak yok; test/login_keyboard_test.dart.
