# Sapmalar ve geçici kararlar

## Figma / belge sapmaları
- **Terminoloji**: Figma'daki "Teklif/Talep" etiketleri (4.01, 4.05, 2.14, 5.01, 4.07) uygulamada "İlan/İhtiyaç"; "Teklif detayı" → "İlan detayı", "talebini kabul etti" → "ihtiyacını kabul etti", "2 yeni teklif" → "2 yeni karşılık", "Taleplerim ve teklifler" → "İhtiyaçlarım ve ilanlarım".
- **2.01 segment**: Figma'da yalnız "İlanlar · N / İhtiyaçlar · N" var (Tümü yok); Figma esas alındı.
- **2.01 üst bar kalbi**: Favoriler ekranı kapsam dışı; kalp, listeyi favorilerle sınırlar (aç/kapa).
- **2.01 kategori çipleri**: Figma 2.01'de yok; form kategorileriyle aynı dört kategori eklendi.
- **3.02 / 3.11 form**: PNG'ler kaydırmada kesik; görünmeyen alanlar (veriliş şekli, ücret, aciliyet) en yakın örnekle tamamlandı. "Önizle" düğmesi önizleme ekranı olmadığı için "Yayınla" yapıldı. Fotoğraf seçimi MVP dışı (ek paket yok): karolara basınca "Yakında"; fotoğraf zorunlu değil.
- **Bildirim metinleri**: "Oğuz E.'ye iade etmen gerekiyordu" (Türkçe ek uyumu isimlerle güvenilir kurulamadığı için) → "Oğuz E. adlı kişiye iade etmen gerekiyordu".
- **Alt menü**: PNG'lerdeki ekran alt menüleri değil, "Alt menü durumları (ortak)" ve belge esas alındı.
- **Lucide dolu kalp**: Pakette dolu varyant yok; aynı Lucide yolu `fill` ile `FavoriteIcon`'da çizildi.
- **Paket**: Flutter 3.50'de `package:flutter/material.dart` deprecated; `material_ui` (SDK'nın ayrılmış Material paketi, ücretsiz/açık kaynak) kullanıldı. `GlobalCupertinoLocalizations` kaldırıldı (Cupertino kullanılmıyor).
- **Yazı tipi**: `google_fonts` yerine Inter statik TTF (OFL) `assets/fonts/`.
- **Tasarım klasörü**: `design/_zN/` açılmış klasörleri temizlendi; zip'ler duruyor (gerekirse yeniden açılır).
- Figma MCP/Chrome kullanılmadı (PNG'ler yeterliydi).

## Koyu tema: belgede olmayan, geçici değerler
Hepsi `lib/core/theme/app_colors.dart` içinde `// TODO(koyu-tema): belgede yok, geçici`:
| Rol | Geçici değer | Not |
|---|---|---|
| primaryPressed | #7699DB | Birincil düğme basılı |
| silver | #6E7A93 | Pasif ikon / süs |
| secondaryFg / secondaryBorder | #E8ECF4 / #8FB0F0 | İkincil düğme |
| secondaryPressedBg | #1C2540 | İkincil basılı |
| hero | #0A1226 | Karşılama / giriş zemini (koyu zemin) |
| appBarFieldFill / appBarFieldBorder | #1C2540 / #2A3552 | Üst bar içi alan |
| scrim | siyah %70 | Alt sayfa arka perdesi |
| unreadTint | #18233F | Okunmamış satır zemini |

## 1.01 Karşılama animasyonu (ANIMASYON_1.01.md)
- Toplam süre 3,52 sn: belge "≈3,5 sn" diyor ama son öğe (panel içeriği) 3,52'de bitiyor; Interval 1'i aşmasın diye controller 3,52 sn.
- "Bende Var" yazısı belgede Bold 800; Inter'in 800 ağırlığı pakette yok (400/500/600/700), 700 kullanıldı.
- Arka plan lekeleri (blob): belge yalnızca davranışı (morph 12 sn, süzülme 16/−20 px, 22°, 10 sn) veriyor; mockup HTML'inde leke öğesi yok. Konum (sol-üst ve sağ-orta), boyut (260×240, 300×280), renk (`heroBlue`/`heroDeep`, %12) ve bulanıklık (σ 36) tahmini.
- Yıldız sayısı/konumu/gecikmesi mockup HTML'inden birebir (`auth_stars.dart`); ekran boyutuna 412×917 uzayından ölçeklenir.
- Parçacık/halka merkezi, mockup'taki (195,385) yerine logonun gerçek merkezi (ekran ortası, logo üstü + 52).
- Koyu tema: `heroTop` (#050A18) geçici; halka/parçacık renkleri iki temada aynı. `// TODO(koyu-tema)`.
- Panel köşesi bu panelde 28 (belge); genel `AppRadius.sheet` 24 kaldı.
- "Kayıt ol" şimdilik ComingSoon'a gider (1.08 Görev 3'te aynı panele bağlanacak).
- Giriş artık ayrı sayfa değil, karşılama panelinin dönüşümü (`AuthStage`); `/login` doğrudan açılırsa panel açık, animasyonsuz gelir.
- Testlerde "animasyonları azalt" açık varsayılır (sürekli yıldız/leke animasyonu pumpAndSettle'ı bekletmesin).

## 1.01 panel safe area
- Ana panel yüksekliği artık sabit 330 değil: `max(330, ölçülen içerik) + alt sistem çubuğu payı` (yazı boyutuna göre TextPainter ile ölçülür). Açık panel de bunun altına inmez. 330→700 büyümesi aynı kalır.

## 1.01 soğuk açılış ve çentik düzeltmesi
- Açılış animasyonu artık ilk kare + 250 ms sonra başlar; tek karede en fazla 50 ms ilerler (soğuk açılışta ilk karelerin ağırlığı animasyonu yutuyordu). "Animasyonları azalt" kararı başlangıçta yeniden okunur; ilk karede geçici true görünürse animasyon baştan oynar.
- Logo grubu üst safe area + 12 dp altına iner (`logoTopGap`); açık panelin üst payı da buna göre artar. Tasarım uzayındaki 30 dp, çentiksiz ekranda aynı kalır.

## Görev 2 · Giriş (1.02) hataları
- 1.03a/b/c ve 1.04 için PNG yok; en yakın örnek 1.02 düzeni. Hata metinleri (ARB) ve görünüm tahmini: 1.03a mevcut alan hatası (kurum dışı e-posta), 1.03b şifre alanı altında kırmızı hata, 1.03c kırmızı kutu + "Şifremi sıfırla" (ComingSoon, Görev 4'te 1.05'e bağlanacak), 1.04 sarı kutu + "Bağlantıyı tekrar gönder" (SnackBar). Figma metinleri gelince ARB güncellenecek.
- Mock giriş (güncel): yalnızca kayıtlı mock hesaplar girebilir (`mockAccounts`, `mock_data.dart` sonu). Kayıtsız e-posta → "hesap bulunamadı" (1.03 ailesinden e-posta alanı hatası, PNG yok, metin tahmini); yanlış şifre → 1.03b; hesap başına 3 yanlıştan sonra 1.03c (uygulama yeniden açılana kadar); doğrulanmamış hesap (Sudem) doğru şifreyle bile ana sayfaya geçmez, 1.04 sarı kutusu gösterilir (PNG yok, en yakın örnek).
- E-posta alanı Türkçe karakterleri yazarken ASCII'ye çevirir (ı→i, ğ→g, ü→u, ş→s, ö→o, ç→c, İ→i) ve küçültür. Neden: kurum e-postaları ASCII'dir; Türkçe klavyede yazan kullanıcıya hata göstermek yerine düzeltmek daha az sürtünme, harf sayısı değişmediği için imleç yerinde kalır.
- E-posta alanı: `.edu.tr` alanın içinde sabit sonek (metin rengi ikincil); kurum dışı e-posta yapıştırılırsa olduğu gibi kalır ve 1.03a hatası verir. İpucu "ad.soyad@okul" (@ yazılmadan önce).

## Görev 3 · Kayıt (1.08 – 1.12)
- PNG yok (yalnızca design/Kayit2_1.09_mockup.html ve Main_1.01_mockup.html'deki 1.08/1.09 taslakları var): 1.08 ve 1.08a karşılama panelinde (ANIMASYON_1.01.md "Giriş/Kayıt geçişi"), 1.09 mockup'a göre; 1.10, 1.12, 1.10a/b için en yakın örnek (aynı yıldızlı şerit + panel düzeni, `AuthShell`). 1.08a = kurum dışı e-posta hatası (giriş 1.03a ile aynı metin).
- 1.10a/b (ve 1.19a/b) yasal metinler örnek içeriktir, nihai hukuki metin değildir (ARB: `legalTermsBody`, `legalPrivacyBody`); satış/şirket geçmez, ödeme alınmadığı belirtilir. Gerçek metin gelince ARB güncellenecek.
- 1.12 (süresi doldu) görseli tahmini: sarı yuvarlak içinde saat ikonu + başlık + açıklama + "Yeni bağlantı gönder".
- "Mail uygulamasını aç" ComingSoon'a gider (url_launcher eklenmedi; "gereksiz paket yok").
- Doğrulama kontrolü: uygulama öne dönünce (`didChangeAppLifecycleState.resumed`) ve "Bağlantıya tıkladım" ile.
- Mock doğrulama: kayıttan 8 sn sonra bağlantıya "tıklanmış" sayılır; e-postası `suredoldu` ile başlayanda bağlantı süresi dolar (1.12). Yeni okul (örn. `@std.bogazici.edu.tr`) ilk kayıtta topluluk açar (ad: okul kimliğinin baş harfi büyük hâli, örn. "Bogazici").
- Kullanıcı adının kısaltması ("Ad S.") ad-soyaddan üretilir; tek kelimeyse olduğu gibi.
- Büyük yazı boyutunda (>1.15×) adım göstergesinde yalnızca geçerli adımın etiketi görünür (taşmasın diye).
- Adım göstergesindeki geçerli adım halkası `infoBg` ile çizildi (mockup #D6E2FA, `infoBg` #E3EEFB'ye yakın).

## Görev 4 · Şifre sıfırlama (1.05 – 1.07)
- PNG yok; 1.05/1.06/1.07 en yakın örnekle (aynı şerit + panel düzeni, `AuthShell`; 1.06 zarf animasyonu 1.09 ile aynı widget). Metinler tahmini (ARB).
- 1.07: yeni şifre + "Şifreyi tekrar gir" iki alan (kayıttaki şifre kuralı: en az 8 karakter, harf + rakam). Kayıttan sonra "Girişe" döner, SnackBar "Şifren güncellendi".
- Güvenlik: kayıtsız e-posta için de "bağlantı gönderildi" görünür (hesap var mı açıklanmaz); mock'ta o durumda bağlantı hiç "tıklanmaz".
- Mock: bağlantı 8 sn sonra "tıklanmış" sayılır; `suredoldu...` e-postasında süre dolar (SnackBar; 1.12 yalnızca kayıt için). Şifre sıfırlanınca eski şifre geçmez ve 1.03c kilidi açılır.
- Girişteki "Şifremi unuttum" ve 1.03c "Şifremi sıfırla" artık 1.05'e gider; girişte yazılan e-posta 1.05'te hazır gelir.

## Giriş kilidi ve şifre alanları (düzeltme)
- 1.03c kutusundan "Şifremi sıfırla" bağlantısı kaldırıldı: gereksiz tekrar olduğu için (şifre sıfırlamaya giden tek yol formdaki "Şifremi unuttum"). 1.03c için PNG yok; Figma'da bu buton varsa bu bilinçli bir sapmadır. Kutu metni: "Çok fazla hatalı deneme yaptın. Biraz bekleyip tekrar dene."
- Kilit (3 yanlış şifre) artık 30 sn sürer (`MockAuthRepository.lockDuration`, tek sabit); süre dolunca kilit kalkar ve sayaç sıfırlanır. Geri sayım gösterilmez. Gerçek (Firebase) davranışı sunucuya bağlı olacak.
- 1.07: "Yeni şifre" ve "Yeni şifreyi tekrar gir" alanlarının her birinin kendi göz ikonu var, bağımsız çalışır. 1.07 için PNG yok; Figma'daki hâl farklıysa (tek ikon vb.) bu sapmadır. Kayıt formunda (1.08) tek şifre alanı var ve kendi göz ikonu zaten var; ikinci alan yok.
- Ayrı bir "ortak şifre alanı" widget'ı yok; ortak `AppTextField` (obscureText + suffix) kullanıldı, yeni widget yazılmadı.

## Görev 5 · Ayarlar (1.15 – 1.21)
- PNG yalnızca 1.15b için var (çıkış onayı: mevcut `showConfirmSheet`, PNG'ye uygun, aynen kullanıldı). 1.15, 1.18, 1.19, 1.19a/b, 1.20, 1.21 için PNG yok; en yakın örnek: 5.07 üst barı (koyu `appBar` + geri + başlık) ve Profil'deki menü satırı kartı. Metinler tahmini (ARB).
- 1.15 satırları: Tema ve dil (bottom sheet), Bildirim ayarları, Topluluklarım (şimdilik ComingSoon, Görev 6'da 1.16), Gizlilik ve destek, Çıkış yap. 1.19: Engellenen hesaplar, Kullanım şartları (1.19a), Gizlilik politikası (1.19b), Yardım ve destek (ComingSoon SnackBar).
- 1.19a/b, kayıttaki 1.10a/b ile aynı metni (`LegalPage`, `inSettings: true`) Ayarlar iskeletiyle gösterir; metinler örnek içeriktir.
- 1.18'de 4 anahtar: Mesajlar, Karşılıklar, İade hatırlatmaları, Topluluk duyuruları (hepsi varsayılan açık; mock'ta bellekte tutulur, gerçek bildirim gönderimi yok).
- 1.20/1.21: engellenenler mock (Mert Y., Kaan D.); "Engeli kaldır" 1.21 onay sheet'ini açar, onaylanınca listeden çıkar ve SnackBar gösterir. "Engelle" eylemi bu görevde yok (sohbet/profil ekranlarında, başka modül).
- Ayarlar'a giriş: `/settings` rotası hazır; Profil ekranındaki dişli ikonu (`profile_page.dart`, `onPressed: () => context.push('/coming-soon')`) başkasının dosyası olduğu için DEĞİŞTİRİLMEDİ. Profil sahibi bunu `context.push('/settings')` yapmalı.

## Görev 6 · Topluluklar (1.16 – 1.17)
- PNG yok; düzen için Ayarlar ailesi (`SettingsScaffold`, `SettingsRow`) ve Mesajlar/Profil'deki satır örnekleri kullanıldı. Metinler tahmini (ARB).
- 1.16 Topluluklarım: üstte arama kutusu, altında üyesi olunan topluluklar, "Davet koduyla katıl" ve "Topluluk oluştur" düğmeleri. Arama yazılınca liste 1.16g sonuçlarına döner (Katıl / Üyesin).
- Okul topluluğu kayıtta otomatik katılınan topluluktur: listenin başında "Okulun" etiketiyle durur, ayrılma düğmesi yoktur (ayrılınamaz). Figma'da farklıysa bu bilinçli sapmadır.
- Görünürlük: Açık (aramada çıkar, herkes katılır), Okula özel (aramada yalnızca aynı okulun üyelerine çıkar), Gizli (aramada çıkmaz, yalnızca davet koduyla).
- 1.16b/1.16c davet kodu ayrı sayfa değil alt sayfa (bottom sheet): hata kodun altında, başarıda aynı sheet "Topluluğa katıldın" özetine döner. Mock kod: `PROJE-24` (Gizli "Proje Ekibi"); büyük/küçük harf ve boşluk önemsiz. Zaten üye olunan topluluğun kodu ayrı bir mesaj verir.
- 1.16e kurucu işlemleri: kurucu olunan satırda "⋯" düğmesi → sheet (Davet kodunu kopyala, Topluluğu sil). 1.16f silme onayı ve 1.17 ayrılma onayı mevcut `showConfirmSheet` ile.
- Oluşturulan her topluluğa mock davet kodu (`BV-xxxx`) üretilir; üyeler listesi/üye çıkarma bu görevde yok.
- Mock topluluklar: Yıldız Yurt Topluluğu (okula özel), Kamp Kulübü, Yoga ve Esneme (açık), Proje Ekibi (gizli). Üye sayıları örnektir.
- Ayarlar → "Topluluklarım" artık `/communities` rotasına gider.

## Düzeltme turu · A (giriş ve şifre)
- A1–A3 Görev 4 düzeltmesinde zaten yapılmıştı (kilit kutusunda "Şifremi sıfırla" yok, kilit 30 sn tek sabit, 1.07'de bağımsız göz ikonları; kayıt formunda tek şifre alanı var). Kod değişmedi.
- A4: hata kutusu (kilit, doğrulanmamış hesap) açılınca giriş formu en üste kayar; başlık kesik kalmaz.
- A5: e-postada ilk Türkçe karakter/büyük harf dönüşümünde alanın altında 4 sn süren ipucu (`emailAsciiHint`); ortak `InstitutionEmailField` içinde, giriş ve kayıtta aynı; alan başına yalnızca bir kez. Süreler `AppMotion` token'larında (`lib/core/theme/app_motion.dart`).

## Düzeltme turu · B (Ayarlar ve Profil)
- B1: Profil'deki dişli ikonu zaten `/settings`'e bağlıydı (commit 648deda; `profile_page.dart` tek satır). Ayarlar'da ComingSoon'a/yakında mesajına giden tek satır: "Yardım ve destek" (Figma'da hedef ekran yok, SnackBar). "Topluluklarım" Görev 6'da 1.16'ya bağlandı.
- B2: Tema ve dil sheet'i zaten tek ortak widget'tı (`showThemeLanguageSheet`, `lib/core/widgets/sheets.dart`); Profil ve Ayarlar ikisi de onu çağırıyor, kopya yok. Kod değişmedi.

## Düzeltme turu · C (Topluluklar)
- C1: Topluluklarım'a her girişte arama temizlenir (`CommunityViewModel.resetSearch`, sessiz; ekran kurulurken çağrılır), tüm topluluklar görünür.
- C2: Davet kodu yalnızca Gizli topluluklarda. Açık: kod yok, herkes doğrudan katılır. Okula özel: kod yok, yalnızca aynı okulun üyeleri aramada görür ve doğrudan katılır. Gizli: kod var, aramada çıkmaz, yalnızca kodla bulunur. Kurucu sheet'inde "Davet kodunu kopyala" yalnızca gizlide görünür. "Kapalı" türü yok. Mock: oluşturulan açık/okula özel topluluklara kod üretilmez.

## Düzeltme turu · D (animasyon ve his)
- Tüm süre, eğri ve ölçüler `lib/core/theme/app_motion.dart` token'larında; renk eklenmedi, yeni paket yok. "Animasyonları azalt" açıkken (MediaQuery.disableAnimations) hiçbiri oynamaz.
- D1: ortak sayfa geçişi `AppPageTransitionsBuilder` (hafif yana kayma + solma), `go_router` sayfaları `MaterialPage` olduğu için tek noktadan tema (`pageTransitionsTheme`) üzerinden TÜM rotalara uygulanır; rota başına ayrı tanım yok. Giriş/Kayıt/Karşılama aynı panelde (`AuthStage`) kendi animasyonuyla değiştiği için rota geçişi yoktur; geçiş Kayıt→Gönderildi→Ad, Şifre sıfırlama adımları ve Ayarlar rotalarında görünür. Alt menü sekmeleri (indexedStack) geçişsizdir.
- D2: `PressScale` ortak widget'ı (scale 0,97) `PrimaryButton/SecondaryButton/DangerButton` ve `AppIconButton`'a bağlandı. `TextLinkButton`'a eklenmedi (metin bağlantısı).
- D3: `ShakeOnError`, ortak `AppTextField` içinde; hata metni belirince/değişince titrer. Giriş formunda aynı hata tekrar gelse de titremesi için deneme sayacı (`AuthViewModel.errorSeq`, `errorSignal`) kullanıldı. Kayıt/şifre sıfırlama alanlarında yalnızca hata ilk belirince/değişince titrer.
- D4: YAPILMADI/değişmedi: 1.06 (sıfırlama maili gönderildi) ve 1.09 (kayıt bağlantısı gönderildi) zaten aynı `EnvelopeAnimation` (açılan zarf + tik rozeti) kullanıyor. "Kayıt tamamlandı" adlı ayrı bir ekran yok (1.10 adını girince doğrudan Ana Sayfa'ya gidiliyor); Figma'da böyle bir ekran varsa söylenmeli.
- D5: `AppEntrance` (sıralı yukarı kayma + solma, bir kez): Topluluklarım listesi/arama sonuçları, Ayarlar (1.15), Bildirim ayarları (1.18) ve Gizlilik ve destek (1.19) satırları. Engellenen hesaplar listesine eklenmedi.
- D6 (GERİ ALINDI, bkz. aşağıdaki not): `AppColors.lerp` tüm renkleri `Color.lerp` ile geçiriyor (eskiden yarıda sıçrıyordu); `MaterialApp.themeAnimationDuration` = `AppMotion.theme`, azaltılınca sıfır.

- D6 geri alındı: tema geçişi çok yavaş hissedildiği için `AppColors.lerp` ve `themeAnimationDuration` D6 öncesi hâline döndü (varsayılan MaterialApp tema geçişi). D1, D2, D3, D5 aynen duruyor.

## Kayıt tamamlandı ekranı (1.10 sonrası)
- Figma'da bu ekran için PNG yok; en yakın örnek 1.09 düzeni (koyu yıldızlı zemin + alt açık panel, `AuthBackdrop`, `c.sheet` panel, ortak `PrimaryButton`). Rota: `/signup/done`; 1.10 "Bitir"den sonra açılır, "Başla" `go('/home')` ile yığını temizleyerek Ana Sayfa'ya gider.
- Tik: yeni bir animasyon yazılmadı; 1.09 zarfındaki rozetle aynı zamanlama/eğri/aşım (`EnvelopeAnimation.badgePop/badgeSettle/badgeOvershoot`, 0 → 1,2 → 1) yeniden kullanıldı. Zarftaki rozet zarfın içinde özel olduğu için bağımsız `SuccessCheck` widget'ı (96 dp mavi `accent` daire, beyaz tik) aynı sabitlerle yazıldı.
- Sıra: tik (~0,56 sn) → başlık (0,5 sn) → 0,2 sn sonra alt metin (0,5 sn); ikisi yukarı kayarak ve solarak gelir (`AppMotion.listSlide`). "Animasyonları azalt" açıksa son kare doğrudan, yıldızlar durağan.
- "Hoş geldin, {ad}!" için ad: girilen Ad Soyad'ın ilk kelimesi (ör. "Elif Yıldırım" → "Elif"). Topluluk adı kullanıcının topluluğundan gelir.
- Alt panel metni "İhtiyacın topluluğunda. Elinde olanı paylaş, ihtiyacın olanı bul." (EN: "Whatever you need, in your community. Share what you have, find what you need.").

## Çıkış onayı sadeleştirildi
- 1.15b çıkış onayı: başlık "Çıkış yapılsın mı?", tek satır "Hesabından çıkacaksın.", butonlar "Vazgeç" / "Çıkış yap". Eski üç satırlık açıklama (`logoutLine2/3`) kaldırıldı. Aynı metin Profil'deki çıkış onayında da kullanıldığı için `profile_page.dart`'ta yalnızca `messages` listesi tek satıra indirildi (başka değişiklik yok). PNG'deki (1.15b) uzun metinden bilinçli sapmadır.

## Beni hatırla (giriş)
- Giriş formunda şifre alanının altında "Beni hatırla" onay kutusu (varsayılan boş; ortak `AppCheckbox`, yeni dosya `lib/core/widgets/app_checkbox.dart`). Kayıt formundaki şartlar kutusu kendi içinde yazılı olduğu için dokunulmadı.
- Açıkken giriş: `AuthRepository.signIn(..., remember: true)` e-postayı `shared_preferences`'a (`remember_email`) yazar. Açılışta `main.dart` `restoreSession()` çağırır; kayıt varsa Giriş istenmeden Ana Sayfa açılır. Kapalıyken (ya da kapalı girişte) kayıt silinir, her açılışta giriş istenir. Çıkış yapınca (`signOut`) silinir.
- Doğrulanmamış hesap giriş aşamasında reddedildiği için hatırlanmaz; elle yazılmış eski kayıt olsa bile açılışta kullanılmaz ve silinir.
- Mock'ta yalnızca e-posta saklanır (şifre asla). Firebase'e geçince oturum kalıcılığı SDK'da olur; `restoreSession` oradaki `currentUser`'ı döndürür.

## Giriş → Ana Sayfa geçişi
- Giriş başarılı olunca: giriş ekranı ~0,45 sn solar, Ana Sayfa aynı sürede %96'dan %100'e büyüyerek ve belirginleşerek gelir (`AppMotion.loginToHome`, `homeScaleFrom`). Yalnızca girişin hemen ardından oynar (`AuthViewModel.fadeToHome` bayrağı, geçiş bitince sessizce iner); diğer `/home` girişleri ortak kayma+solma geçişini kullanır.
- "Animasyonları azalt" açıkken efekt yok, doğrudan geçer. `go('/home')` yığını temizlediği için geri tuşu giriş ekranına dönmez.
- Uygulama soğuk açılışında (Beni hatırla) geçiş oynamaz; ilk sayfa animasyonsuz açılır.

## Kısa açılış (Beni hatırla ile açılan oturum)
- Uygulama artık `/splash` açılış kapısıyla başlar (`SplashPage`). Oturum kontrolü (`AuthViewModel.restore` → `restoreSession`, shared_preferences) bu kapıda, animasyon süresi içinde yapılır; `main.dart` artık kontrolü beklemez.
- Oturum yok: bekletmeden Karşılama'ya geçilir (tam 3,5 sn karşılama animasyonu orada, değişmedi); logo/ad hiç görünmez. Oturum var: ~1,2 sn (`AppMotion.splash`) karşılama zemini (`AuthBackdrop`, durağan yıldızlar), ortada `AppLogo` küçük büyümeyle (%80→%100), altında "Bende Var"; halka/parçacık/panel yok. Sonra giriş sonrası geçişle (`fadeToHome`: açılış solar, Ana Sayfa %96→%100) Ana Sayfa.
- Kontrol 1,2 sn'den uzun sürerse oturum bilinince hemen geçilir. "Animasyonları azalt" açıksa açılış atlanır, doğrudan Ana Sayfa.
- Redirect aynı: oturum yok → Karşılama (`/splash` herkese açık rota); oturum var → Ana Sayfa. Karşılama'ya geçiş ortak kayma+solma sayfa geçişini kullanır.
