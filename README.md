# Bende Var

"İhtiyacın topluluğunda." Okul, yurt, şirket gibi aynı ortamı paylaşanların birbirine eşya ödünç verdiği / sattığı Android uygulaması (YTÜ Mobil Programlama, MVP). Flutter, yalnızca Android, TR + EN, açık + koyu tema.

Kurallar için `CLAUDE.md`, stil için `docs/STIL_STANDARTLARI.md`, durum için `docs/PROGRESS.md`.

## Çalıştırma
```powershell
flutter pub get
flutter run            # Android cihaz / emülatör
flutter test
flutter analyze
flutter build apk --debug   # build/app/outputs/flutter-apk/app-debug.apk
```
Giriş (sahte): e-posta `.edu.tr` ile bitmeli (ör. `elif@std.yildiz.edu.tr`), şifre boş olmamalı. İlk derlemede Gradle, Android SDK'dan NDK ve CMake'i kendisi indirir.

## Klasör yapısı ve sahipleri
```
lib/
  main.dart
  app/                 # app.dart, router.dart, app_shell.dart, di.dart, theme/locale controller
  core/theme/          # app_colors (açık+koyu), typography, spacing, radius, shadows, app_theme
  core/widgets/        # ortak bileşenler (düğmeler, alan, kart, çip, alt menü, sheet'ler)
  core/utils/          # validators, formatters, labels
  l10n/                # app_tr.arb, app_en.arb (+ üretilen AppLocalizations)
  data/models|repositories|mock/
  features/auth/            # Kişi 1: Karşılama, Giriş
  features/home/            # Kişi 2: Ana Sayfa, İlan detayı
  features/create_listing/  # Kişi 3: 3.01 panel, ilan/ihtiyaç formu, yayınlandı
  features/messages/        # Kişi 4: Mesajlar, Sohbet, Bildirimler
  features/profile/         # Kişi 5: Profil, Ödünçlerim
```
Her feature `view/` + `viewmodel/` içerir; View repository'yi doğrudan görmez (provider + ChangeNotifier).

## Yeni metin / renk eklerken
- **Metin**: `lib/l10n/app_tr.arb` **ve** `app_en.arb`'ye aynı anahtarla ekle, `flutter gen-l10n` (ya da `flutter run`), kodda `AppLocalizations.of(context).anahtar`. Dart'ta kullanıcıya görünen string yazma. Terminoloji: "ilan" / "ihtiyaç" (CLAUDE.md).
- **Renk**: yalnızca `lib/core/theme/app_colors.dart`; rolü hem `light` hem `dark` sete ekle, widget'ta `context.colors.rol`. `Color(0x…)` / `Colors.…` (transparent hariç) başka yerde olmaz. Belgede koyu karşılığı yoksa `// TODO(koyu-tema): belgede yok, geçici` yaz ve `docs/DEVIATIONS.md`'ye ekle.
- Ölçü / köşe / boşluk: `app_spacing.dart`, `app_radius.dart`; belgede olmayanlar `docs/DESIGN_TOKENS_EK.md`'ye.
- İkon: yalnızca Lucide (`lucide_icons_flutter`).

## Mock'tan Firebase'e (Spark planı: Auth, Firestore, FCM)
1. `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` ekle; `flutterfire configure`.
2. `lib/data/firebase/` altında `FirebaseAuthRepository`, `FirebaseListingRepository`, `FirebaseChatRepository`, `FirebaseNotificationRepository`, `FirebaseUserRepository` yaz (`lib/data/repositories/repositories.dart` arayüzlerini uygula; `watch*` metodları Firestore snapshot stream'i döner).
3. `lib/app/di.dart` içinde `AppDependencies` varsayılanlarındaki `Mock*Repository` satırlarını `Firebase*Repository` ile değiştir; View / ViewModel değişmez.
4. Giriş: e-posta alan adından (`.edu.tr`) topluluğu eşle. Görsel yükleme için Storage kullanma (Blaze gerekir); fotoğraf MVP dışı.
5. Bildirimler: FCM token'ını kullanıcı belgesine yaz; iade hatırlatması için Cloud Functions yerine istemci tarafı zamanlama düşün (Spark'ta Functions yok).

## Figma / belgeden sapmalar
`docs/DEVIATIONS.md` (terminoloji, 2.01 segmenti, form alanları, `material_ui` paketi, geçici koyu tema renkleri).

## Kapsam dışı (MVP)
Kayıt ol, şifre sıfırlama, fotoğraf seçimi, filtre paneli, sesli arama, topluluk değiştirme, QR okutma / gösterme, Ayarlar, ilan düzenleme: ilgili butonlar "Yakında" sayfası ya da SnackBar gösterir.
