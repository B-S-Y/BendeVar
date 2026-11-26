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
