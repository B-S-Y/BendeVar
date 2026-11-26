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
