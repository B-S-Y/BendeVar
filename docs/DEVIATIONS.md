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
| heroTop | #050A18 | Karşılama/giriş zemini gradyanının üstü (1.01; açıkta #06112B) |
| envelopeRingInner / envelopeRingOuter | #3A4A85 / #2A3560 | 1.09/1.06 zarf amblemi halkaları. Açık temadaki #B8C6DE / #D5DEEE de belgede yok (geçici) |

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
- 1.15 satırları: Tema ve dil (bottom sheet), Bildirim ayarları, Topluluklarım (1.16), Engellenenler (1.20), Gizlilik ve destek, Çıkış yap. 1.19: Kullanım şartları (1.19a), Gizlilik politikası (1.19b), Yardım ve destek (sayfa).
- 1.19a/b, kayıttaki 1.10a/b ile aynı metni (`LegalPage`, `inSettings: true`) Ayarlar iskeletiyle gösterir; metinler örnek içeriktir.
- 1.18'de 4 anahtar: Mesajlar, Karşılıklar, İade hatırlatmaları, Topluluk duyuruları (hepsi varsayılan açık; mock'ta bellekte tutulur, gerçek bildirim gönderimi yok).
- 1.20/1.21: engellenenler mock (Mert Y., Kaan D.); "Engeli kaldır" 1.21 onay sheet'ini açar, onaylanınca listeden çıkar ve SnackBar gösterir. "Engelle" eylemi bu görevde yok (sohbet/profil ekranlarında, başka modül).
- Ayarlar'a giriş: `/settings` rotası hazır; Profil ekranındaki dişli ikonu (`profile_page.dart`, `onPressed: () => context.push('/coming-soon')`) başkasının dosyası olduğu için DEĞİŞTİRİLMEDİ. Profil sahibi bunu `context.push('/settings')` yapmalı.

## Görev 6 · Topluluklar (1.16 – 1.17)
- PNG yok; düzen için Ayarlar ailesi (`SettingsScaffold`, `SettingsRow`) ve Mesajlar/Profil'deki satır örnekleri kullanıldı. Metinler tahmini (ARB).
- 1.16 Topluluklarım: üstte arama kutusu, altında üyesi olunan topluluklar, "Davet koduyla katıl" ve "Topluluk oluştur" düğmeleri. Arama yazılınca liste 1.16g sonuçlarına döner (Katıl / Üyesin).
- Okul topluluğu kayıtta otomatik katılınan topluluktur: listenin başında koyu çerçeveyle durur, ayrılma düğmesi yoktur (ayrılınamaz). Figma'da farklıysa bu bilinçli sapmadır.
- Görünürlük: Açık (aramada çıkar, herkes katılır), Okula özel (aramada yalnızca aynı okulun üyelerine çıkar), Gizli (aramada çıkmaz, yalnızca davet koduyla).
- 1.16b/1.16c davet kodu ayrı sayfa değil alt sayfa (bottom sheet): hata kodun altında, başarıda aynı sheet "Topluluğa katıldın" özetine döner. Mock kod: `482913` (Gizli "Proje Ekibi"; eski `PROJE-24` geçersiz, bkz. Revize 8); büyük/küçük harf ve boşluk önemsiz. Zaten üye olunan topluluğun kodu ayrı bir mesaj verir.
- 1.16e kurucu işlemleri: kurucu olunan satırda "⋯" düğmesi → sheet (Davet kodunu kopyala, Topluluğu sil). 1.16f silme onayı ve 1.17 ayrılma onayı mevcut `showConfirmSheet` ile.
- Oluşturulan her topluluğa mock davet kodu üretilir (artık 6 haneli rakam, bkz. Revize 8); üyeler listesi/üye çıkarma bu görevde yok.
- Mock topluluklar: Yıldız Yurt Topluluğu (okula özel), Kamp Kulübü, Yoga ve Esneme (açık), Proje Ekibi (gizli). Üye sayıları örnektir.
- Ayarlar → "Topluluklarım" artık `/communities` rotasına gider.

## Düzeltme turu · A (giriş ve şifre)
- A1–A3 Görev 4 düzeltmesinde zaten yapılmıştı (kilit kutusunda "Şifremi sıfırla" yok, kilit 30 sn tek sabit, 1.07'de bağımsız göz ikonları; kayıt formunda tek şifre alanı var). Kod değişmedi.
- A4: hata kutusu (kilit, doğrulanmamış hesap) açılınca giriş formu en üste kayar; başlık kesik kalmaz.
- A5: e-postada ilk Türkçe karakter/büyük harf dönüşümünde alanın altında 4 sn süren ipucu (`emailAsciiHint`); ortak `InstitutionEmailField` içinde, giriş ve kayıtta aynı; alan başına yalnızca bir kez. Süreler `AppMotion` token'larında (`lib/core/theme/app_motion.dart`).

## Düzeltme turu · B (Ayarlar ve Profil)
- B1: Profil'deki dişli ikonu zaten `/settings`'e bağlıydı (commit 648deda; `profile_page.dart` tek satır).
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
- Tik: `SuccessCheck` (96 dp mavi `accent` daire, beyaz tik), ölçek 0 → 1,2 → 1; zamanlama `AppMotion.successPopSeconds` (0,32) + `successSettleSeconds` (0,24), aşım `successOvershoot` (1,2).
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

## Kontrol turu düzeltmeleri · davranış
- `CommunityRepository.myCommunities(userId:, school:)`: mock üyelikleri ve kurucuları kullanıcı kimliğine göre tutar; aynı oturumda başka hesapla girişte önceki kullanıcının toplulukları görünmez. `CommunityViewModel.load(AppUser)`.
- Çıkışta / kullanıcı değişince `SettingsViewModel.reset()` ve `CommunityViewModel.reset()` (app.dart, AuthViewModel dinleyicisi). Başkasının `ProfileViewModel`'i (`lib/features/profile/viewmodel/profile_view_models.dart`, yapıcıda bir kez `_load`) değiştirilmedi; çıkıştan sonra başka hesapla girince eski sayılar kalabilir, sahibine bildirilmeli.
- Oturum açıkken giriş öncesi sayfalar (`/welcome`, `/login`, `/signup`, `/signup/sent`, `/signup/expired`, `/forgot`, `/forgot/sent`, `/forgot/new`) Ana Sayfa'ya yönlenir. `/signup/name`, `/signup/done`, `/splash` ve yasal metinler hariç.
- `restore()` hata verirse oturumsuz devam eder (açılış kapısı takılmaz). Çıkışta "Beni hatırla" kutusu sıfırlanır.

## Kontrol turu düzeltmeleri · yükleniyor, hata, güvenli alan
- Topluluklarım ve Engellenen hesaplar yüklenirken gösterge (`SettingsLoading`); 1.18'de ayarlar yüklenene kadar anahtarlar gösterilmez.
- Yükleme hatasında kısa metin ("Yüklenemedi. Bağlantını kontrol edip tekrar dene.") + "Tekrar dene" (`SettingsError`). İşlem hatasında (katıl, ayrıl, sil, oluştur, engeli kaldır, bildirim kaydı) SnackBar "İşlem tamamlanamadı." + "Tekrar dene"; bildirim anahtarı kaydedilemezse eski değere döner. Davet kodunda beklenmeyen hata `CommunityFailure.unknown` ile aynı kısa metni gösterir.
- Ayarlar ve Topluluklar liste boşluklarına alt sistem çubuğu payı (`MediaQuery.paddingOf(context).bottom`) eklendi (`settingsListPadding`).
- Hata ve "Tekrar dene" tasarımı Figma'da yok; en yakın örnek boş liste metni + ikincil düğme.

## Okul kimliği sınırı ve okula özel topluluk
- Okul kimliği = e-postanın SONUNDAKİ `.edu.tr`'den önceki son kelime (`Validators.schoolId`): `boun.edu.tr` → `boun`, `std.bogazici.edu.tr` → `bogazici`, `ogr.msgsu.edu.tr` → `msgsu`. Yerel kısımdaki rakam kimliği etkilemez. `.edu.tr` sonekten başka yerde geçerse (`boun.edu.tr.com`, `boun.edu.trx`), okul adı yoksa (`@edu.tr`), boşluk ya da çift `@` varsa kimlik yoktur (null). Aynı okulun alt alan adları (`std.`, `ogr.`) aynı kimliğe düşer.
- Sınır notu: yalnızca `.edu.tr` sonekli adresler kabul edilir; `.edu` ya da `.ac.uk` gibi kurum alanları bu MVP'de desteklenmez.
- Okula özel topluluğa yalnızca aynı okulun üyeleri katılır: arama başka okula göstermez ve doğrudan katılma isteği de (`MockCommunityRepository.join`) reddedilir.

## Revize turu · 4 (topluluk sızıntısı)
- Kök neden: `MockAuthRepository.completeSignUp` kullanıcı kimliğini `'u-' + e-postanın @ öncesi` yapıyordu; `yeni@marmara.edu.tr` ve `yeni@boun.edu.tr` ikisi de `u-yeni` oldu ve `MockCommunityRepository` üyelikleri kimliğe göre tuttuğu için Marmara üyeliği Boun hesabına sızdı. Kimlik artık tam e-postadan (`u-<e-posta>`). Çıkışta VM sıfırlaması önceki turda zaten vardı.

## Revize turu · 7 (Türkçe duyarlı arama)
- `lib/core/utils/text_search.dart` (`TextSearch.normalize/matches`): `İ→i`, `I→ı`, sonra `ı ç ğ ö ş ü → i c g o s u`; aranan ve hedef metin aynı fonksiyondan geçer. Topluluk araması bunu kullanır ("T", "t", "AÇIK", "acik", "İstanbul"). Mock'a "İstanbul Gezginleri" ve "Açık Hava Sporları" açık toplulukları eklendi.

## Revize turu · 6 (okul topluluğu satırı)
- Otomatik katılınan okul topluluğu satırında "Okulun" ve "Okula özel" etiketleri yok; satır, ikincil düğme kenarıyla aynı daha koyu çerçeveyle (`secondaryBorder`, `AppSizes.borderStrong`, köşe `cardLarge`) ayrılır. Belgede ayrı bir "border-strong" rolü olmadığı için bu mevcut token kullanıldı (iki temada da belgede var). Diğer topluluklarda tür etiketi (Açık / Okula özel / Gizli) kalır.

## Revize turu · 8 (davet kodu)
- Kod 6 haneli, yalnızca rakam, ön ek yok (`kInviteCodeLength`). Seed: Proje Ekibi `482913`; yeni Gizli topluluğa üretilen kod da 6 haneli rakam, mevcutlarla çakışmaz. Kurucu sheet'inde ve kopyalamada ön ek yok.
- Kod alanı: sayısal klavye + `digitsOnly` + `maxLength 6` (ortak `AppTextField`'a `inputFormatters`/`maxLength` eklendi). "Devam" 6 hane dolana kadar BİLİNÇLİ olarak pasif (kullanıcı isteği); (Revize 2. tur · 2: alan altındaki yardım cümlesi kaldırıldı; buton açıklamasız pasif.)
- Akış: kod → Devam → topluluk önizlemesi (ad, baş harf avatarı, üye sayısı · tür; henüz üye değil) → "Katıl" (üye olur, 1.16b) ya da "Vazgeç". Yanlış kodda mevcut hata durumu (1.16c); zaten üyeyse "Bu topluluğun zaten üyesisin." (`CommunityRepository.previewByCode`).

## Revize turu · 3 (okul kartı ve kişisel e-posta)
- Okul kartı yazarken çıkmaz: yazma durduktan `AppMotion.schoolLookupDelay` (500 ms) sonra aranır. (Revize 2. tur · 6: 3 harf kuralı kaldırıldı, aşağıya bak.) Bilinen okulda (mock `mockKnownSchools`: yildiz → Yıldız Teknik, marmara, boun/bogazici → Boğaziçi, itu, msgsu, odtu/metu) okulun adı + "Okul topluluğuna katılacaksın". Bilinmeyen okulda "Topluluğun ilk kayıtla açılacak" notu yalnızca e-posta alanı odağı kaybedince ya da Kayıt ol'a basılınca gelir (`SignupBody` odak dinleyicisi).
- Kişisel e-posta engeli: okul kimliği gmail, hotmail, outlook, yahoo, icloud, yandex, proton, protonmail, live, msn ise (`Validators.personalProviders`) `Validators.email` mevcut "kurum dışı e-posta" hatasını (`EmailError.notEdu`, 1.03a/1.08a) döndürür; kayıt ve giriş reddedilir. Kayıtta alandan çıkınca da hata görünür; kişisel e-postada okul kartı çıkmaz. Yalnızca tam ad eşleşir (`gmailx.edu.tr` geçerli).
- `AppTextField` ve `InstitutionEmailField`'a `focusNode` eklendi (odak kaybını dinlemek için).

## Revize turu · 1 (kısa açılışta halkalar)
- Kısa açılışta karşılamadaki logo halkaları da gösterilir: aynı `BurstPainter` (halka 1 ve 2, aynı renk/çizgi/ölçek sabitleri), parçacıksız (`particles: false`). Karşılama zaman çizelgesinin halka bölümü (0,64 → 2,40 sn) 1,2 sn'ye sıkıştırılarak oynatılır. "Animasyonları azalt" açıkken kısa açılış zaten atlandığı için halka da yoktur.

## Revize turu · 2 (zarf, tasarım "C")
- Bağlantı gönderildi zarfının arkasına daire + dışında ince halka eklendi (daire 176 dp, halka 188 dp / 1,5 çizgi). Açık tema: daire = alt menü aktif hap (`navPill` değeri), gövde = alt menü aktif ikon (`navPillIcon` değeri), kapak/ön yüz çizgisi = daire rengi, halka açık gri-mavi (#C9D3E3). Koyu tema: daire = belgedeki koyu açık mavi vurgu (#5B8CFF), gövde = sayfa zemini (#0A1226), çizgi = daire rengi, halka ince koyu mavi (#2A4A86; belgede yok, geçici, `TODO(koyu-tema)`). Yeni token'lar: `envelopeDisc`, `envelopeBody`, `envelopeRing`; `envelopeFront` kaldırıldı. Animasyon akışı (kapak açılışı, mektup, rozet; süre ve aralıklar) aynı. Widget kutusu 150×120 yerine 188×188 oldu.

## Revize turu · 5 (şifre ekranlarını sadeleştirme)
- 1.05: başlık + tek kısa cümle ("E-postanı yaz, sana bir bağlantı gönderelim."). 1.06: başlık, e-posta ve tek kısa yönerge ("Bağlantıya tıkla, sonra buraya dön."); "şu adrese gönderdik" satırı ve "24 saat geçerli" notu kalktı. 1.07: alt başlık kalktı (başlık yeterli); şifre kuralı ve iki alan aynı. İşlev değişmedi. ARB: `resetSentSubtitle`, `newPasswordSubtitle` silindi; `forgotSubtitle`, `resetSentInstruction` kısaltıldı (TR/EN).

## Revize turu · 10 (Yardım ve destek sayfası) ve 9 (Engellenenler)
- Yardım ve destek artık gerçek sayfa (`/settings/help`, `HelpPage`): başlık, kısa açıklama, 3 soru-cevap (ExpansionTile; topluluğa katılma, Beni hatırla, şifremi unuttum) ve altta iletişim e-postası (mock: destek@bendevar.app / EN support@bendevar.app). Figma'da bu ekran yok; en yakın örnek Ayarlar kart satırları + ExpansionTile. Metinler ARB (TR/EN). "Animasyonları azalt" açıkken açılıp kapanma animasyonsuz. Ayarlar'da artık "Yakında"ya giden satır yok.
- 9 (Engellenenler sayfasında başlık altında çizgi artıkları): sayfa benim modülümde (`lib/features/auth/view/settings_pages.dart` → `BlockedAccountsPage`, iskelet `SettingsScaffold` / `settings_widgets.dart`). Açık ve koyu temada, 412×917 ve çentikli (üst 50 dp, alt 48 dp) + 1,3× yazıda, hem tek başına hem uygulama içinden (Profil → Ayarlar → Gizlilik → Engellenen) ekran görüntüsü alındı; başlığın altında artık çizgi görülmedi. Sayfada TabBar, `PreferredSize bottom`, Divider ya da taşan çubuk yok; taşma testleri temiz. Kök neden bulunamadı, kod değiştirilmedi (bkz. rapor).

## Revize turu · 11 (giriş ekranında klavye)
- Odak yönetimi: uygulamada `autofocus` ya da `requestFocus` hiç yok; giriş/kayıt formu açılınca hiçbir alan odak almaz, klavye yalnızca kullanıcı alana dokununca açılır (testle doğrulandı). Odak yalnızca form kapanırken/değişirken `unfocus` ile bırakılır.
- Bulunan kusur: açık panelin yüksekliği klavye açıkken de "ana panelden küçük olmaz" tabanına ve küçük logo payına (130 dp) bağlıydı. Küçük ekranda (ör. 320×568) klavye açılınca panel ekranın üstüne itiliyor, başlık/geri düğmesi dışarıda kalıyordu. Klavye açıkken taban kalktı ve panel logo alanını da kullanabiliyor (yalnızca durum çubuğu payı kalır); taşan içerik formun kendi kaydırmasıyla görünür. Klavye kapalıyken düzen aynı.
- 412×917'de (A23) kademeli klavye açılışı testte tek yönlü ve odak kaybı olmadan çalışıyor; telefonda görülen "ilk seferde sekme" testte birebir üretilemedi (bkz. rapor).

## Revize 2. tur · 1 (Ayarlar başlığı kesilmesi)
- Kök neden (Eda'nın telefonunda, büyük yazı/ekran boyutu): `SettingsScaffold` üst bar başlığı satır sınırı olmadan büyük yazı ölçeğiyle iki satıra bölünüyor, sabit yükseklikli üst barın altında ikinci satırın üst kısımları "iki kısa çizgi" gibi görünüyordu. Önceki turda testler 1,3× ile çalıştığı için üretilemedi.
- Düzeltme: başlık tek satır (`maxLines: 1`, `ellipsis`), başlığın yazı ölçeği en fazla 1,2× (`MediaQuery.withClampedTextScaling`, `SettingsScaffold.maxTitleTextScale`); ortak iskelette olduğu için Ayarlar'ın tüm alt sayfalarına uygulanır. "Engellenen hesaplar" → "Engellenenler" (EN "Blocked").

## Revize 2. tur · 2 (davet kodu sheet'i sade)
- Başlık "Davet koduyla katıl" kalır; altındaki açıklama cümlesi ve "Devam"ın altındaki yardım cümlesi kalktı. Alan ipucu "Davet kodu" (EN "Invite code"). "Devam" 6 hane dolmadan açıklamasız pasif. Hata durumları (yanlış kod, zaten üye) aynı. ARB: `inviteCodeBody`, `inviteCodeHelp` silindi.

## Revize 2. tur · 3 (Engellenenler ilk seviyede)
- Figma'dan sapma: "Engellenenler" Ayarlar'ın ilk seviyesinde (Topluluklarım'ın altında) doğrudan satır; Gizlilik ve destek içindeki satır kaldırıldı (çift yol yok). Neden: Profil → Ayarlar → Gizlilik → Engellenen olarak 3 seviye içteydi, telefonda bulunamıyordu. Rota aynı (`/settings/blocked`), yalnızca giriş noktası değişti.

## Revize 2. tur · 6 (okul kartı kuralı)
- "En az 3 harf" kuralı kalktı (Koç = `ku.edu.tr` gibi 2 harfli kimlikleri engelliyordu). Bilinen okulda (mock listesi, alias'lar dahil; eklenenler: `ku` → Koç Üniversitesi, `iuc` → İstanbul Üniversitesi-Cerrahpaşa) harf sayısına bakılmadan 500 ms sonra okul adı çıkar. Bilinmeyen okulda yazarken kart yok; "Topluluğun ilk kayıtla açılacak" notu yalnızca alan odağı kaybedince ya da Kayıt ol'a basılınca.
- Kayıt/giriş için okul kimliği en az 2 harf (`Validators.minSchoolIdLength = 2`); tek harf (`a@b.edu.tr`) mevcut "kurum dışı e-posta" hatası. Kişisel e-posta engeli aynı.

## Revize 2. tur · 5 (Beni hatırla açılışı)
- Kök neden: 1,2 sn'lik açılış, karşılamanın halka bölümünü 1,2 sn'ye sıkıştırıyordu ve sayaç sayfa kurulurken (`didChangeDependencies`) başlıyordu; ilk kare çizilene kadar geçen süre de sayıldığı için release'te neredeyse anlık bitiyordu.
- Yeni: açılış, karşılamadaki logo girişinin aynısı ve gerçek hızda (aynı `AuthMotion` sabitleri: logo 0–1,04 sn büyüyüp oturur, "Bende Var" 0,96–1,52 sn belirir, halkalar 0,64–2,40 sn). Süre `AppMotion.splash` = 2,4 sn (halka 2'nin bitişi) ve ilk kare çizildikten sonra başlar. Oturum geri yükleme önce bitse de animasyon tamamlanmadan Ana Sayfa'ya geçilmez; bitince solma + büyüme geçişi. "Animasyonları azalt" açıkken `AppMotion.splashReduced` = 600 ms statik son kare (halka yok), sonra doğrudan Ana Sayfa. Önceki `splashLogoFrom/End`, `splashTextStart/End` token'ları kaldırıldı. (Bu bölüm önceki "1,2 sn" notlarının yerine geçer.)

## Revize 2. tur · 4 (zarf amblemi, tasarım "B")
- Dolgulu daire kalktı. Zarfın arkasında iki ince eş merkezli halka (152/184 dp, 1,5 çizgi, dolgu yok); zarf zarf yüzey dolgulu, 2,5 dp çizgili gövde + üst kenardan ortaya inen V kapak; mektup da yüzey dolgulu ve çizgili, satırlar iç halka renginde; onay rozeti mevcut (dolu vurgu daire + tik).
- Renkler (`AppColors`): `envelopeLine` (açık: alt menü aktif ikon #0B1D45; koyu: açık mavi vurgu #8FB0F0), `envelopeSurface` (açık: card #FFFFFF; koyu: card/panel #141D35), `envelopeRingInner` / `envelopeRingOuter` (açık #C8D3E4 / #DCE3EE, koyu #4A6290 / #22345A; belgede yok, geçici, koyular `TODO(koyu-tema)`). Önceki `envelopeDisc`, `envelopeBody`, `envelopeRing` silindi.
- Akış aynı (kapak 0,32–0,88 sn, mektup 0,8–1,52 sn, rozet 1,52–2,08 sn); ek olarak halkalar zarf belirirken içeriden dışarı sırayla belirir (iç 0–0,30 sn, dış 0,15–0,45 sn; opaklık + %90→%100 ölçek). "Animasyonları azalt" açıkken son kare (halkalar statik). Kutu 184×184 dp. (Revize turu · 2'deki "C" tasarımının yerine geçer.)

## Revize 2. tur · 7 (Ayarlar genel görsel kontrol)
- Ayarlar, Bildirim ayarları, Gizlilik ve destek, Engellenenler, Yardım, Topluluklarım, Topluluk oluştur, Kullanım şartları ve Tema/dil sheet'i; 360×800 ve 412×917, 1,3× ve 1,5× yazı, açık ve koyu temada (üst 32 dp, alt 48 dp sistem çubuğu) tarandı. Taşma, başlık kesilmesi ve alt güvenli alan sorunu bulunmadı (otomatik denetim: `test/settings_audit_test.dart`).
- Bulunan tek görsel sorun: Engellenenler satırında büyük yazıda okul adı "Engeli kaldır" düğmesinin yanında 3 satıra bölünüyordu; ad tek satır, okul en fazla 2 satır (üç nokta) yapıldı.
- Ayarlar'da ayrı bir "Şifre" ya da "Dil/Tema" sayfası yok: şifre değiştirme Ayarlar'da bulunmuyor (şifre sıfırlama giriş akışında, 1.05–1.07); Dil/Tema bir sheet (ortak `ThemeLanguageSheet`), o da tarandı.

## Zarf amblemi sadeleştirildi (geçerli tasarım; önceki "C" ve "B" notlarının yerine geçer)
- Mektup ve onay rozeti kaldırıldı; amblem yalnızca kapalı, çizgili zarf + arkasında iki ince eş merkezli halka (dolgu yok). Onay tiki hiçbir yerde yok.
- Oranlar (referans birim, ~160 dp'ye orantılı: çarpan 160/92): gövde 52×36 (≈3:2), köşe 6; kapak V'si üst köşelerden gövde yüksekliğinin %50'sine iner (yuvarlak uç/birleşim; uçlar köşe yayının üzerinde, köşeden taşmaz); alt köşelerden çizgi yok; iç halka 72, dış halka 92. Çizgi kalınlıkları ölçeklenmez, sabit: zarf gövdesi ve kapak 3 dp, halkalar 1,5 dp (`EnvelopeAnimation.lineStroke/ringStroke`; ölçekli hâli ≈4,3 / 2,6 dp kalın duruyordu). Amblem 160 dp; ekrandaki dikey yer aynı kalsın diye yerleşim kutusu önceki 184 dp (`EnvelopeAnimation.slot`).
- Renkler: `envelopeLine` (açık #0B1D45 = alt menü aktif ikon; koyu #8FB0F0 = açık mavi vurgu), `envelopeSurface` (açık #FFFFFF, koyu #141D35 = card), `envelopeRingInner` / `envelopeRingOuter` (açık #B8C6DE / #D5DEEE, koyu #3A4A85 / #2A3560; belgede yok, geçici, koyular `TODO(koyu-tema)`).
- Animasyon (`AppMotion.envelope*`, toplam 1,4 sn): iç halka 0–0,30 sn, dış halka 0,15–0,45 sn (opaklık + 0,9→1 ölçek); gövde 0,25–0,80 sn çizilir gibi belirir (dolgu birlikte), kapak V'si 0,80–1,05 sn çizilir; 1,05–1,40 sn hafif ölçek vurgusu 1→1,04→1, sonra durur. "Animasyonları azalt" açıkken son hâl statik.
- Kayıt tamamlandı tikinin (`SuccessCheck`) zamanlaması zarftan ayrıldı: `AppMotion.successPopSeconds/SettleSeconds/Overshoot` (değerler aynı).

## Giriş/kayıt metinleri kısaltıldı (Figma TR metinlerinden bilinçli sapma)
- Kural: her ekranda başlık + en fazla tek kısa cümle; hata kutularında ne oldu + gerekirse tek eylem. Yazı boyutu/stil token'ları değişmedi. EN aynı sadelikte. Kaldırılan anahtarlar ARB'den silindi.

| Ekran | Anahtar | Önce | Sonra | Neden |
|---|---|---|---|---|
| Karşılama | `welcomeSubtitle` | "Okul mailinle giriş yap, kampüsün seni bekliyor." | "Okul e-postanla giriş yap." | Tek kısa cümle; ikinci yarı süs |
| Giriş | `loginSubtitle` | "Kurum e-postan ve şifrenle devam et." | —(kaldırıldı) | Alan etiketlerini tekrar ediyordu; başlık yeterli |
| Giriş · hata | `errorEmailNotEdu` | "Kurum e-postanla (.edu.tr ile biten adres) giriş yapmalısın." | "Okul e-postanı (.edu.tr) kullan." | Ne oldu + eylem, tek kısa cümle |
| Giriş · hata | `errorAccountNotFound` | "Bu e-postayla kayıtlı bir hesap bulamadık. E-postanı kontrol et ya da kayıt ol." | "Bu e-postayla hesap bulunamadı." | Kayıt ol bağlantısı zaten altta |
| Giriş · hata | `errorPasswordWrong` | "Şifre yanlış. Tekrar dene." | "Şifre yanlış." | "Tekrar dene" kendiliğinden belli |
| Giriş · kilit | `errorTooManyAttempts` | "Çok fazla hatalı deneme yaptın. Biraz bekleyip tekrar dene." | "Çok fazla deneme; biraz sonra tekrar dene." | Tek cümle |
| Giriş · doğrulanmamış | `errorNotVerified` | "Hesabın henüz doğrulanmamış. E-postana gönderdiğimiz bağlantıya tıkla." | "Hesabın doğrulanmamış. E-postandaki bağlantıya tıkla." | Kısaltıldı; eylem düğmesi ayrıca var |
| Giriş/Kayıt · e-posta ipucu | `emailAsciiHint` | "E-posta adreslerinde Türkçe karakter ve büyük harf kullanılmaz, otomatik düzelttik." | "Türkçe karakter ve büyük harfi düzelttik." | Açıklama yerine yalnızca ne olduğu |
| Kayıt 1 | `signupSubtitle` | "Topluluğun e-posta uzantısından bulunur. Sana bir doğrulama bağlantısı göndereceğiz." | —(kaldırıldı) | Alan etiketi ve okul kartı yeterli; doğrulama bağlantısı bir sonraki ekranda söyleniyor |
| Kayıt 1 · şifre kuralı | `signupPasswordRule` | "En az 8 karakter, en az bir harf ve bir rakam." | "En az 8 karakter, bir harf ve bir rakam." | Tekrarlanan "en az" kalktı |
| Kayıt 1 · hata | `errorPasswordWeak` | "Şifren en az 8 karakter olmalı, en az bir harf ve bir rakam içermeli." | "En az 8 karakter, bir harf ve bir rakam." | Kural metniyle aynı, kısa |
| Kayıt 1 · hata | `errorEmailInUse` | "Bu e-posta zaten kayıtlı. Giriş yapmayı dene." | "Bu e-posta zaten kayıtlı." | "Giriş yap" bağlantısı zaten altta |
| Kayıt 1 · hata | `errorTermsRequired` | "Devam etmek için şartları kabul etmelisin." | "Şartları kabul et." | Tek kısa eylem |
| Kayıt 1 · şartlar | `termsLead` | "" | "" | Tek satır |
| Kayıt 1 · şartlar | `termsLink` | "Kullanım şartlarını" | "Şartları" | Tek satır |
| Kayıt 1 · şartlar | `privacyLink` | "gizlilik politikasını" | "gizliliği" | Tek satır |
| Kayıt 1 · şartlar | `termsTail` | " okudum, kabul ediyorum." | " kabul ediyorum." | Tek satır |
| Kayıt 1 · okul kartı | `signupNewCommunity` | "Topluluğun ilk kayıtla açılacak" | "Topluluğun ilk kayıtla açılacak" | EN kısaltıldı (TR aynı) |
| Kayıt 2 · Bağlantıyı gönderdik | `sentSubtitle` | "Doğrulama bağlantısını şu adrese gönderdik:" | —(kaldırıldı) | Başlık "gönderdik" diyor; altında e-posta adresi zaten görünüyor |
| Kayıt 2 · Bağlantıyı gönderdik | `sentInstruction` | "Okul e-postandaki bağlantıya tıkla, sonra buraya dön ve "Bağlantıya tıkladım" düğmesine bas. Bağlantı 24 saat geçerlidir." | "Bağlantıya tıkla, sonra buraya dön." | Düğme adını tekrar ediyordu; 24 saat notu Süresi doldu ekranında |
| Kayıt 2 · uyarı | `notVerifiedYet` | "E-postan henüz doğrulanmadı. Bağlantıya tıkladığından emin ol." | "E-postan henüz doğrulanmadı." | Tek kısa cümle |
| Kayıt 3 · Adın ne? | `nameSubtitle` | "Diğer kullanıcılar seni bu adla görecek. Gerekirse düzenleyebilirsin." | "Diğer kullanıcılar seni bu adla görecek." | "Düzenleyebilirsin" alan zaten düzenlenebilir |
| Kayıt tamamlandı | `doneSlogan` | "İhtiyacın topluluğunda. Elinde olanı paylaş, ihtiyacın olanı bul." | "Elinde olanı paylaş, ihtiyacın olanı bul." | Tek cümle; slogan karşılamada zaten var |
| Bağlantı süresi doldu | `expiredBody` | "Doğrulama bağlantısı 24 saat geçerliydi. Sana yeni bir bağlantı gönderebiliriz." | —(kaldırıldı) | "Yeni bağlantı gönder" düğmesini tekrar ediyordu; başlık yeterli |
| Şifremi unuttum · uyarı | `resetExpired` | "Bağlantının süresi doldu. Yeni bir bağlantı iste." | "Bağlantının süresi doldu, yenisini iste." | Tek cümle |
| Şifremi unuttum · bilgi | `passwordUpdated` | "Şifren güncellendi. Yeni şifrenle giriş yapabilirsin." | "Şifren güncellendi." | Giriş ekranına zaten dönülüyor |

## Zarf halkaları nefes alır
- Giriş animasyonu bittikten sonra iki halka ayrı, sürekli bir controller ile hafifçe "nefes alır": ölçek 1 ↔ 1,04, opaklık en fazla %30 azalır, 2,8 sn döngü, yumuşak (kosinüs) eğri, iki halka arasında yarım döngü faz farkı (`AppMotion.envelopeBreath*`). Zarf sabit kalır. Giriş animasyonu tek controller + Interval düzeninde aynı. Sayfa kapanınca durur ve bırakılır. "Animasyonları azalt" açıkken halkalar statik (sürekli animasyon yok).

## Kurum dışı e-posta metni: "edu.tr"
- Hata metni "Okul e-postanı (.edu.tr) kullan." → "Okul e-postanı kullan (edu.tr)." (EN "Use your school email (.edu.tr)." → "Use your school email (edu.tr)."). Başında nokta olmadan, sona parantez içinde: okunuşu daha sade (Figma metninden sapma). Kullanıcıya görünen başka ".edu.tr" metni yok; e-posta alanındaki sabit ".edu.tr" son eki alan biçimi olduğu için aynı kaldı.

## Form hataları yalnızca gönderimde (Kayıt ve Yeni şifre)
- Yazarken ve alan odağı kaybedince hata rengi, hata metni ve titreme yok; şifre kuralı ("En az 8 karakter, bir harf ve bir rakam.") nötr yardımcı metin olarak durur. Hata ve titreme yalnızca "Kayıt ol" / "Şifreyi kaydet"e basınca, kuralı sağlamayan alanda; kullanıcı yazarken kural sağlanır sağlanmaz hata kalkar ve bir sonraki gönderime kadar yazarken geri gelmez. Her başarısız gönderim yeniden titretir (`signupErrorSeq`, `newErrorSeq`).
- E-posta, şifre ve (Yeni şifre ekranında) şifre tekrar alanlarına uygulanır. Okul kartı mantığı aynı. Önceki "kişisel e-postada alandan çıkınca hata" davranışı bu kurala uyması için kaldırıldı; kişisel e-posta artık gönderimde "kurum dışı" hatasını verir. Figma'da hata zamanlaması tanımlı değil.

## Karşılama: slogan altındaki satır kaldırıldı
- "Okul e-postanla giriş yap." satırı (ARB `welcomeSubtitle`, TR/EN) kaldırıldı; slogan ve düğmeler yeterli (Figma'dan sapma). Slogan ile "Giriş yap" arası tek boşluk: `AuthMotion.sloganButtonGap` = `AppSpacing.xxxl` (32 dp); eski düzen 6 dp + satır + 20 dp idi. Panel yüksekliği ölçümü buna göre güncellendi (alt sınır 330 dp aynı). 360×800 ve 412×917'de 1,3× ve 1,5× yazıda taşma yok.

## Ayarlar verisi kullanıcıya göre
- `SettingsRepository` metotları kullanıcı kimliği alır; mock bildirim tercihlerini ve engel listesini kimliğe göre tutar (her yeni kullanıcı örnek listeyle başlar: Mert Y., Kaan D.). Bir hesapta engel kaldırmak ya da bildirim anahtarını değiştirmek diğer hesabı etkilemez. `SettingsViewModel.setUser` oturum değişince app.dart'tan çağrılır.

## Topluluk araması yükleme bitene kadar pasif
- Topluluklarım'da arama kutusu liste yüklenene kadar pasif (`AppTextField.enabled`); hesap değişiminden hemen sonra önceki kullanıcının bağlamıyla arama yapılmaz.

## Okul listesi JSON'dan (`assets/data/tr_universities.json`)
- Kayıttaki okul bulma artık 206 okuldan oluşan JSON'dan beslenir (`SchoolDirectory`, tek sefer yüklenir; eski `mockKnownSchools` kalktı). Kimlik ve alias'lar tek arama haritasında; arama `TextSearch.normalize` ile büyük/küçük harf ve Türkçe karakterden bağımsız. Okul adı seçili dile göre (`Community.localizedName`: TR `name_tr`, EN `name_en`).
- Birleştirilen/alias yapılan kimlikler: `ybu`→`aybu`, `ohu`→`nigde`, `gata`→`sbu`, `gyte`→`gtu`, `karaelmas`→`beun`, `dho`/`hho`→`msu` (Millî Savunma Üniversitesi). `msgsu` ayrı okul. `ayvansaray`, `boun` vb. alias'lar duruyor.
- Okul topluluğu kimliği artık JSON kimliği: Yıldız Teknik `ytu` → `yildiz` (mock hesaplar, yurt topluluğu ve testler buna göre).
- Rehberde olmayan okul eskisi gibi: "Topluluğun ilk kayıtla açılacak", `joinOrCreate` ile ilk kayıtta açılır.
- Sabancı (`sabanciuniv.edu`, `.edu.tr` değil) sabit `.edu.tr` kuralı yüzünden kayıt olamaz; kodda özel durum yok. JSON'da `note` olarak duruyor.
- Okul adları ARB'de değil veridir; EN arayüzde okul kartı `name_en` gösterir. Ana Sayfa ve ilan detayı (başkasının modülü) hâlâ Türkçe `community.name` gösterir.
- Ön ek (`st.`, `ogr.`, `std.`) listesi yok: okul kimliği `.edu.tr`'den önceki son etikettir, bu yüzden `st.biruni.edu.tr` → `biruni`.
