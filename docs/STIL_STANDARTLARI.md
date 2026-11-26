# Bende Var · Stil standartları (E · Gece Yarısı)

Bu belge kodlamada **tek kaynaktır**. Figma PNG'leriyle çelişirse bu belge kazanır.
Platform: Android (Material), ekran 412×917 (Android Compact). Yazı tipi Inter, ikon seti Lucide.
Hazırlayan: Eda (Kişi 1, ortak palet/font/düğme standartları).

Kodlama kuralları:
- Kodda sabit renk, ölçü ve metin olmaz. Renkler ve ölçüler `lib/core/theme/` içindeki token'lardan gelir.
- Tema hem **açık** hem **koyu** olur (`ThemeMode`: sistem / açık / koyu).
- Metinler TR/EN çeviri dosyalarından (ARB) gelir.
- Kontrastlar WCAG'e göre hesaplandı: metin için en az 4.5:1, alan çerçevesi için en az 3:1.

## Palet: açık tema
| Rol | Kod | Kullanım |
|---|---|---|
| Ana lacivert | #0B1D45 | Birincil düğme, üst bar, seçili sekme |
| Basılı lacivert | #06112B | Basılı hal, büyük koyu alanlar |
| Vurgu mavisi | #2F5FC4 | Metin bağlantısı, odak halkası, bilgi ikonu |
| Yüzey | #EEF1F6 | Sayfa arka planı |
| Kart | #FFFFFF | Kart, alan, alt sayfa |
| Yazı | #0B1220 | Başlık ve gövde |
| İkincil yazı | #4A5468 | Açıklama, alt yazı (6.7:1) |
| Gümüş | #A9B2C2 | Ayraç, pasif ikon, süs (alan kenarında kullanılmaz: 2.1:1) |
| Alan çerçevesi | #7D879A | Giriş alanı kenarı (3.6:1) |
| Pasif | #E1E5EC zemin / #8A93A3 yazı | Pasif düğme |

Durum renkleri (yazı / zemin):
| Durum | Yazı | Zemin |
|---|---|---|
| Bilgi | #1B4A8A | #E3EEFB |
| Başarı | #17643A | #DDF3E6 |
| Uyarı | #7A4300 | #FCEBD3 |
| Hata | #A21C1C | #FBE1E1 |

Kural: lacivert zemin üstünde yazı ve ikon her zaman beyaz (vurgu mavisi lacivertte 2.8:1, okunmaz).

## Palet: koyu tema
| Rol | Kod | Not |
|---|---|---|
| Zemin | #0A1226 | Sayfa arka planı |
| Kart | #141D35 | Kart, alan, alt sayfa |
| Yazı | #E8ECF4 | Başlık ve gövde |
| İkincil yazı | #9AA6BC | Açıklama, alt yazı |
| Birincil düğme | #8FB0F0 zemin, #0A1226 yazı | 8.5:1 |
| Vurgu mavisi | #5B8CFF | Birincil düğmeden ayırt edilsin diye daha doygun; zeminde 5.9:1 |

Koyu tema durum renkleri (yazı / zemin):
| Durum | Yazı | Zemin | Kontrast |
|---|---|---|---|
| Bilgi | #9DC1FF | #13284F | 8.0:1 |
| Başarı | #7FD8A1 | #10301F | 8.4:1 |
| Uyarı | #F2C27A | #3A2A10 | 8.4:1 |
| Hata | #FF9C9C | #3D1518 | 8.0:1 |

Koyu tema diğer renkler:
| Rol | Kod | Not |
|---|---|---|
| Alan çerçevesi | #6E7A93 | Kart üstünde 3.9:1 |
| Ayraç | #2A3552 | Üst bar ve alt menü ayracı, liste ayracı |
| Kart kenarlığı | #243052 | Kartlarda gölge yok, kenarlık var |
| Pasif düğme | #1C2540 zemin / #6B7691 yazı | |
| Üst bar | #141D35 | Kart rengi; koyu temada lacivert yerine bu kullanılır |
| Alt menü zemini | #141D35 | Üstte #2A3552 ayraç çizgisi |
| Alt menü aktif hap | #1E3A6B | İkon #E8ECF4 |
| Alt menü pasif ikon | #9AA6BC | |
| Alt menü logo butonu | #8FB0F0 zemin, #0A1226 "b" | Birincil düğme rengi |
| Rozet | #B3261E | Açık temayla aynı, sadece Bildirimler'de |
| Metin bağlantısı | #5B8CFF | Vurgu mavisi |

Koyu temada lacivert zemin kuralı değişir: koyu zeminde yazı ve ikon #E8ECF4'tür, birincil düğmede ise #0A1226 yazı kullanılır.

## Yazı tipi: Inter (Flutter: google_fonts)
| Stil | Boyut / satır | Kalınlık | Kullanım |
|---|---|---|---|
| Marka | 28 / 34 | Bold | "Bende Var" |
| Başlık 1 | 22 / 28 | Bold | Ekran başlığı |
| Başlık 2 | 18 / 24 | Bold | Pencere başlığı |
| Üst bar | 16 / 22 | Semi Bold | Üst bar başlığı |
| Gövde | 15 / 22 | Regular | Alan içi metin, liste başlığı |
| Gövde küçük | 14 / 21 | Regular | Açıklama paragrafı |
| Etiket | 13 / 18 | Semi Bold | Alan etiketi, hata metni |
| Alt yazı | 12 / 16 | Regular | Yardımcı metin |
| Bölüm etiketi | 11 / 14 | Bold, büyük harf, aralık 0.6 | "GİZLİLİK", "DESTEK" |

## İkonlar: Lucide
Paket: `lucide_icons_flutter`. 2 px çizgi, yuvarlak uç. Başka setten ikon karıştırılmaz.
Boyut: üst bar ve ikon düğmesi 22, liste satırı 18, alan içi 14–16. Renk yazı rengini izler; lacivert zeminde beyaz.

Temel ikonlar: arrow-left Geri · x Kapat · settings Ayarlar · bell Bildirimler · users Topluluklarım · message-circle Mesajlar · house Ana sayfa · user Profil · plus Aç · search Ara · lock Kilitli alan · ban Engellenenler · shield Gizlilik · circle-help SSS · mail E-posta · circle-alert Hata · clock Süre · check Onay · chevron-right Satır oku · eye / eye-off Şifre göster/gizle · log-out Çıkış · globe Dil · sun-moon Tema.

## Gölge
Tasarım düz; kartlarda gölge yok. Yalnızca üstte duran katmanlarda:
- shadow-sm: 0 2px 8px, lacivert (#0B1D45) %12. Bildirim mesajı. Flutter elevation 2.
- shadow-lg: 0 12px 32px, lacivert %20. Onay penceresi, alt sayfa. Flutter elevation 8.

Koyu temada ikisi de siyah %50; katmanı asıl ayıran arka perde ve kart rengi.

## Düğmeler
Ortak: yükseklik 52, köşe 12, yatay iç boşluk 20, yazı 15 Semi Bold, ekran düğmesi tam genişlik.

| Tür | Normal | Basılı | Kullanım |
|---|---|---|---|
| Birincil | #0B1D45 zemin, beyaz yazı | #06112B | Ekrandaki tek ana eylem |
| İkincil | Beyaz zemin, 1.5 px #0B1D45 kenar ve yazı | #EEF1F6 zemin | Kayıt ol, Kapat |
| Metin bağlantısı | #2F5FC4, 14 Semi Bold, alt çizgi | %70 opaklık | Şifremi unuttum |
| Tehlikeli | Beyaz zemin, 1.5 px #A21C1C kenar ve yazı | #FBE1E1 zemin | Ayrıl, Engeli kaldır |
| Pasif | #E1E5EC zemin, #8A93A3 yazı | - | Koşul yok / sayaç çalışıyor |

Dokunma alanı: en küçük 48×48 dp (Material). Küçük düğme (satır içi): görünen yükseklik 44, köşe 10, 13 Semi Bold; dokunma alanı 48 dp. İkon düğmesi: 48×48 dp dokunma alanı, ikon 22. Metin bağlantılarının dokunma alanı da en az 48 dp yüksekliğinde. Flutter'da varsayılan (`MaterialTapTargetSize.padded`) zaten 48 dp verir. Odak halkası: 2 px #2F5FC4, 2 px dışarıda.

Alan (giriş): yükseklik 50, köşe 10, kenar #7D879A.

Kurallar: ekranda tek birincil düğme; onay pencerelerinde birincil düğme "Vazgeç", tehlikeli eylem ikinci sırada. Hata = renk + ikon + açıklayıcı cümle (sadece renkle gösterilmez). Diyalog ve seçiciler alttan açılan pencere (bottom sheet) olarak açılır.

## Alt menü (ortak bileşen)
- Sadece ikon, etiket yok. Soldan sağa: Ana sayfa, Mesajlar, ortada logo (ilan ver), Bildirimler, Profil.
- Yükseklik 76, ikon 26, dokunma alanı 48 dp.
- Aktif sekme: açık mavi hap #E3EEFB, lacivert ikon. Pasif ikon: #4A5468.
- Kırmızı rozet (#B3261E) **sadece Bildirimler'de**.
- Ortadaki logoya basılınca ilan oluşturma paneli (3.01) açılır. Bu sırada hiçbir sekme mavi olmaz, logo büyütülmez.
- Ayarlar ekranında Profil seçili görünür.

## Eksikler ve sahipleri
- Talep ve teklif kartı: Kişi 2 (ana sayfa).
- Alt menünün sekme halleri: Elif.
- Çevrimdışı bandı: çevrimdışı çalışma kimdeyse.
- Logo ve uygulama ikonu: "b!" logosu ekipçe onaylandı (çubuksuz sürüm).
