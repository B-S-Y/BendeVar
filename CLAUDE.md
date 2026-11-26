# Bende Var — Proje kuralları

Flutter ile yazılan Android uygulaması (MVP). Yeni oturumda önce bu dosyayı ve `docs/PROGRESS.md`'yi oku.

## Uygulama
- Bende Var ("I have it"): Okul, yurt, şirket gibi aynı ortamı paylaşan kişilerin birbirinin ihtiyacını karşıladığı topluluk içi ödünç alma / satın alma uygulaması. Slogan: "İhtiyacın topluluğunda."
- Kullanıcılar kurum e-postasıyla kayıt olur, kurumlarının topluluğuna otomatik katılır.
- İki paylaşım türü:
  - **İlan** ("Bende var"): eldeki eşyayı ödünç vermek ya da satmak için açılan paylaşım.
  - **İhtiyaç** ("İhtiyacım var"): bulunmak istenen eşya için açılan paylaşım. Elinde olan kişi "Bende Var" butonuyla karşılık verir.
- **Terminoloji**: kodda, arayüzde, mock verilerde, dokümanlarda hep "ilan" ve "ihtiyaç". "Teklif ilanı", "talep", "talep ilanı" kullanılmaz (STIL_STANDARTLARI.md'de geçse bile). Arayüz metinleri Figma'daki gibi ("İlan: tek sayfa form", "İhtiyaç: tek sayfa form", "Ana Sayfa · İhtiyaçlar"). "Bende var" ve "İhtiyacım var" olduğu gibi kalır (3.01 paneli seçenekleri, buton ve etiketler). İngilizce: ilan = "listing", ihtiyaç = "need", "Bende var" = "I have it", "İhtiyacım var" = "I need it". Bir ihtiyaca verilen karşılık için Figma'daki kelime.
- Taraflar mesajlaşarak fiyat/süre üzerinde anlaşır; sohbette "Anlaşma özeti" kartı (teslim yeri, süre, ücret/ödeme).
- Ödeme sistemi yok (yüz yüze veya IBAN). Ödünç eşyalar için iade hatırlatması. Teslim ve iade QR ile onaylanır, sonra karşılıklı puanlama.
- YTÜ Mobil Programlama dersi, 5 kişilik ekip. Yalnızca Android. Arayüz dilleri TR (varsayılan) ve EN.

## Tasarım kaynakları
1. `docs/STIL_STANDARTLARI.md` — stil için tek kaynak (renk, yazı, ikon, gölge, düğme, alan, alt menü). Çelişkide belge kazanır.
2. `design/` — ekran düzeni kaynağı (Figma PNG'leri 412×917, 2x). Zip'ler `design/` içinde; PNG'ler gerekirse `design/_zN/` altına açılır (`unzip`), işin sonunda silinir. Kişi 1: 1.01, 1.02, 1.15b · Kişi 2: 2.01, 2.14, Emine Bileşenler v6 · Kişi 3: 3.01, 3.02, 3.11, 3.07 · Kişi 4: 4.01, 4.05, 4.07 · Kişi 5: 5.01, 5.07. Alt menü: `Alt menü durumları (ortak)` (png+svg). "ortak · Elif/Sudem/Kişi 2 için" dosyasını KULLANMA. Logo: `design/İkon.svg` → `assets/logo.svg`.
3. Yedek: Figma dosyası fileKey `FBDlETZZpiFWFZb31av49Z` (Mockups). Sırayla: Figma MCP (kota çok düşük; `get_metadata` sonra tek node `get_design_context`; hata verirse bırak) → Claude in Chrome (sadece bak). Figma'da hiçbir şeyi değiştirme. İkisi de yoksa en yakın örnekle devam, `docs/DEVIATIONS.md`'ye not.
4. Modüller: 1.xx Hesap, 2.xx Ana Sayfa/Favoriler, 3.xx İlan/İhtiyaç oluşturma, 4.xx İletişim/Bildirim, 5.xx Profil/işlem yönetimi.

Kaynaklarda olmayan şeyi uydurma; en yakın örneği kullan, `docs/DEVIATIONS.md`'ye yaz.

## Tasarım standardı
- Belgedeki her rol (renk, yazı stili, düğme türü, ölçü) bir Dart token'ı. Belgede olmayan ama gereken değerleri (ekran kenar boşluğu, kart köşesi, boşluk ölçeği) PNG'den ölç, 4'lük ızgaraya yuvarla, `docs/DESIGN_TOKENS_EK.md`'ye "değer | hangi ekrandan | neden" yaz. Belgeyle çelişmesin.
- İkon: Lucide (`lucide_icons_flutter`); başka set karıştırılmaz.
- Alt menü: STIL_STANDARTLARI "Alt menü" bölümü + `Alt menü durumları (ortak)` ile birebir. Sadece ikon; Ana sayfa (`house`), Mesajlar (`message-circle`), ortada logo butonu, Bildirimler (`bell`, kırmızı rozet sadece burada), Profil (`user`). Yükseklik 76, ikon 26, dokunma 48; aktif = açık mavi hap + lacivert ikon; pasif = ikincil yazı rengi. Koyu tema renkleri belgede. Ekran PNG'lerindeki alt menülere bakma. Özel widget yaz.
- Logo `AppLogo` widget'ı ile (renkler token'dan); elle yeniden çizme.

## Tema ve dil (baştan)
- `lib/core/theme/app_colors.dart`: açık + koyu set, `ThemeExtension` (`AppColors`). Widget'lar renge Theme üzerinden erişir.
- ThemeMode sistem/açık/koyu, varsayılan sistem; `ThemeController` (ChangeNotifier) + `shared_preferences`. Profil'den bottom sheet ile seçilir.
- Belgede koyu karşılığı olmayan rol: geçici değer + satıra `// TODO(koyu-tema): belgede yok, geçici` + `docs/DEVIATIONS.md`'ye ekle.
- Metinler: `flutter_localizations` + `intl` + ARB (`lib/l10n/app_tr.arb`, `app_en.arb`), `l10n.yaml`, `generate: true`. `app_strings.dart` YOK. Varsayılan TR; cihaz EN ise EN. `LocaleController` (sistem/TR/EN) aynı sheet'ten. TR metinler Figma ile birebir.
- Mock veri içeriği (ilan başlığı, kullanıcı adı, mesaj) çevrilmez; arayüz metinleri hep ARB.
- Tarih/saat/para (₺) `intl` ile seçili dile göre.

## Mimari
- Flutter stable, Dart 3, yalnızca Android (`minSdk 23`). Sadece ücretsiz/açık kaynak paketler; Firebase paketi şimdilik yok (ama `Firebase*Repository` DI'da tek satırla takılabilir kurulur); Firebase Storage yok.
- MVVM + Repository; `lib/{app,core/{theme,widgets,utils},l10n,data/{models,repositories,mock},features/{auth,home,create_listing,messages,profile}}`. Feature'lar `view/` + `viewmodel/`.
- State: `provider` + `ChangeNotifier`. View repository'yi doğrudan görmez.
- Navigasyon: `go_router`, alt menü `StatefulShellRoute.indexedStack`; ortadaki logo sekme değil, 3.01 bottom sheet'i açar. Giriş yoksa redirect → Karşılama.
- Mock repository'ler bellekte (kısa `Future.delayed`).
- Yazı tipi Inter, `google_fonts` YOK; statik TTF (400/500/600/700) `assets/fonts/`, `pubspec.yaml` `fonts:`, tema `fontFamily: 'Inter'`. ğ ş ı İ doğru görünmeli.
- Paketler: provider, go_router, lucide_icons_flutter, flutter_svg, flutter_localizations, intl, shared_preferences, flutter_lints. Gereksiz paket ekleme.

## Kod kuralları
- Kodda sabit renk/metin yok. `Color(0x` ve `Colors.` yalnızca `app_colors.dart`'ta (`Colors.transparent` hariç). Kullanıcıya görünen metin Dart'ta string olmaz, ARB'den gelir. Ölçüler token'dan, sihirli sayı yok.
- `const` constructor, küçük widget'lar.
- MVP'de olmayan hedefe giden buton `ComingSoonPage` ya da SnackBar. Hiçbir şey yapmayan buton olmaz.
- Mock: Casio fx-991EX hesap makinesi, Calculus ders kitabı, yoga matı, uzatma kablosu, kamp sandalyesi; kullanıcılar "Mert Y.", "Elif Y."; topluluk "Yıldız Teknik Üniversitesi".

## Tasarruf
- Gereksiz dosya okuma yok; PNG'yi yalnızca o ekran üzerinde çalışırken aç. Pahalı iş yerine ucuz yol.
