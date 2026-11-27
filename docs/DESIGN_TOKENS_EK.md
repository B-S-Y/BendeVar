# Ek tasarım token'ları

STIL_STANDARTLARI.md'de olmayan, ekranlardan ölçülen değerler (PNG 2x → dp, 4'lük ızgaraya yuvarlandı). Belgeyle çelişmez.

| Değer | Hangi ekrandan | Neden |
|---|---|---|
| Ekran yan kenar boşluğu 16 | 2.01 Ana Sayfa (32 px) | Kart, arama ve segment hizası |
| Boşluk ölçeği 4/8/12/16/20/24/32/48 | 2.01, 3.02, 5.01 | Tüm dikey ritimler 4'ün katı |
| Kart köşesi 12 | 2.01 kart (Bileşenler v6) | Liste kartı |
| Büyük kart köşesi 16 | 3.02 form kartı, 5.01 istatistik/menü kartları | Form ve profil kartları |
| Alt sayfa / panel üst köşesi 24 | 1.01, 1.02, 3.01, 1.15b | Karşılama paneli ve bottom sheet |
| Küçük görsel (kart) 88×88, köşe 12 | 2.01 (176 px) | Kart küçük resmi |
| Detay görsel yüksekliği 188 | 2.14 (380 px) | Detay üst görsel alanı |
| Fotoğraf karosu 80×80 | 3.02 | Fotoğraf ekle karoları |
| Segment yüksekliği 44, iç boşluk 4 | 2.01, 4.01 | Segment kontrolü |
| Kategori çipi min. yükseklik 48 | 3.02 (80 px), doküman 48 dp dokunma alanı | Dokunma alanı kuralı |
| Alt menü hap 60×44, logo butonu 44×44 | Alt menü durumları (ortak) | Hap 120×88 px, logo 88 px |
| Rozet min. 18 | Alt menü durumları | Kırmızı rozet çapı |
| Başarı dairesi 96 | 3.07 | İlan yayınlandı |
| Profil avatarı 96 | 5.01 (144 px) | Profil üst alan |
| Durum etiketi (hap) yatay 12, dikey 6 | 5.07, 3.07 | "Ödünçte", "Yayında" |
| Kart kenarlığı (açık) = pasif zemin #E1E5EC | 2.01 | Belgedeki bir renk yeniden kullanıldı |
| Üst bar içi alan zemini (açık) beyaz %10, kenar beyaz %20 | 2.01 topluluk kutusu | Lacivert üstünde saydam katman |
| Okunmamış satır zemini (açık) #F3F7FE | 4.01, 4.07 | Çok açık mavi satır vurgusu |
| Karşılama başlığı/alt yazı rengi lacivert üstünde #D5DCEB | 1.01 slogan | Beyazın yumuşak hali |
| Scrim (açık) #0B1220 %60 | 3.01, 1.15b | Alt sayfa arka perdesi |

## Belgede koyu karşılığı olmayan roller (geçici)
`app_colors.dart` içinde `// TODO(koyu-tema): belgede yok, geçici` ile işaretli: birincil basılı hal, gümüş (pasif ikon), ikincil düğme yazı/kenar/basılı zemin, karşılama zemini, üst bar içi alan zemini/kenarı, scrim, okunmamış satır zemini. Ayrıntı: DEVIATIONS.md.

## 1.01 animasyonu (ANIMASYON_1.01.md)
| Değer | Hangi kaynaktan | Neden |
|---|---|---|
| heroTop #06112B, heroBlue #5B8CFF, heroSilver #A9B2C2, heroDeep #2F5FC4 | ANIMASYON_1.01.md | Gradyan üstü, halka, parçacık |
| Panel yüksekliği 330 → 700, köşe 28, içerik kenarı 20/30/34 | ANIMASYON_1.01.md | Karşılama → giriş büyümesi |
| Logo 104, "Bende Var" 34/-0,4, ad boşluğu 14, slogan boşluğu 8 | ANIMASYON_1.01.md | Karşılama logo grubu |
| Süre/eğri/gecikme sabitleri | ANIMASYON_1.01.md | `auth_motion.dart` |
| envelopeFront #163066 (koyu: geçici #6F94DB) | 1.09 mockup | Zarf ön yüzü; diğer zarf renkleri mevcut rollerden (primary, accent, card, infoBg, onBadge) |
