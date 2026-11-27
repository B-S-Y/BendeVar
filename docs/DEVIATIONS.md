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
