# 1.01 Karşılama açılış animasyonu (mockup'a birebir)

Kaynak: claude.ai mockup'ı, `Main.dc.html` (412×917). Mockup'ta 8 sn'lik döngü olarak çalışır; uygulamada **bir kez** oynar ve son karede durur. Aşağıdaki süreler mockup'taki yüzdelerin saniyeye çevrilmiş hâlidir (8 sn × yüzde). Toplam oynama süresi ≈ 3,5 sn.

## Uygulama yöntemi
Tek bir `AnimationController` (süre 3,5 sn, bir kez `forward`) ve her öğe için `Interval(başlangıç/3.5, bitiş/3.5, curve: ...)`. Ek paket yok. Cihazda "animasyonları azalt" açıksa controller doğrudan son değere atlar (animasyonsuz son kare). Yıldız yanıp sönmesi ve arka plan lekesi ayrı, sürekli çalışan controller'lardır (azalt açıksa durur).

## Zemin
- Arka plan: dikey gradyan `#06112B` (üst, %0) → `#0B1D45` (%60 ve aşağısı).
- **130 küçük yıldız** (r ≈ 0.8–1.3 px, beyaz). Her biri kendi süresiyle (3–5 sn) saydamlığı 1 → 0,15 → 1 yapar, başlangıç gecikmeleri farklı (rastgele, sabit tohumla). Sürekli döner.
- **Bulanık lekeler (blob):** yarı saydam, düşük opaklık, yavaşça şekil değiştirir (border-radius morph, 12 sn ileri-geri) ve süzülür (16 px sağa, 20 px yukarı, 22° dönme, 10 sn ileri-geri). Sürekli döner.

## Zaman çizelgesi (saniye)

| Öğe | Başlar | Biter | Ne olur | Eğri |
|---|---|---|---|---|
| Logo (104×104, "b!" lacivert yuvarlak kare `#0D1B4C`, 22% beyaz çerçeve) | 0,00 | 0,64 | ölçek 0,2 → 1,15, saydamlık 0 → 1 | `cubic-bezier(.3,1.6,.5,1)` |
| | 0,64 | 1,04 | ölçek 1,15 → 1,0 (yerine oturur) | aynı |
| Halka 1 (çap 140, 2 px `#5B8CFF`) | 0,64 | 1,92 | ölçek 0,6 → 2,3; saydamlık 0,85 → 0 | easeOut |
| Halka 2 (çap 140, 1,5 px `#A9B2C2`) | 0,88 | 2,40 | ölçek 0,6 → 3,0; saydamlık 0,5 → 0 | easeOut |
| 10 parçacık (aşağıda) | 0,64 | 1,92 | logo merkezinden (x,y) konumuna uçar, ölçek 0,4 → 1, saydamlık 0 → 0,9 | `cubic-bezier(.15,.7,.3,1)` |
| | 1,92 | 2,56 | konumun 1,15 katına süzülür, ölçek 0,6, saydamlık 0 | aynı |
| "Bende Var" (34 px, Bold 800, beyaz, harf aralığı −0,4, logonun 14 px altı) | 0,96 | 1,52 | saydamlık 0 → 1, 10 px aşağıdan yukarı gelir | ease |
| Slogan (15 px, `#D5DBE6`, 8 px altı) | 1,52 | 2,00 | saydamlık 0 → 1 | ease |
| Logo grubu (logo + ad + slogan) ve halka/parçacık kümesi | 2,08 | 2,88 | 150 px yukarı kayar | `cubic-bezier(.6,0,.2,1)` |
| Alt panel (yükseklik 330, `#EEF1F6`, üst köşeler 28) | 2,16 | 3,04 | kendi yüksekliği kadar aşağıdan yukarı çıkar | `cubic-bezier(.6,0,.2,1)` |
| Panel içeriği (başlık, açıklama, 2 düğme) | 2,88 | 3,52 | saydamlık 0 → 1, 8 px aşağıdan yukarı | ease |

Başlangıç yerleşimi: logo grubunun üstü ekranın üstünden 330 px aşağıda; parçacık/halka kümesinin merkezi logonun merkezi.

## Parçacıklar (merkezden uçuş noktası x,y px; çap; renk)
1. (95, 0) · 6 · `#FFFFFF`
2. (84, 81) · 4 · `#5B8CFF`
3. (43, 132) · 8 · `#A9B2C2`
4. (−42, 85) · 5 · `#2F5FC4`
5. (−95, 69) · 6 · `#FFFFFF`
6. (−138, −19) · 4 · `#5B8CFF`
7. (−77, −56) · 8 · `#A9B2C2`
8. (−20, −115) · 5 · `#2F5FC4`
9. (43, −132) · 6 · `#FFFFFF`
10. (84, −45) · 4 · `#5B8CFF`

## Panel içeriği (animasyon bittiğinde)
Başlık "Elinde olan paylaşır, ihtiyacı olan bulur." (21/27, 700, `#0B1D45`), altında "Okul mailinle giriş yap, kampüsün seni bekliyor." (14/21, `#4A5468`), sonra "Giriş yap" ve "Kayıt ol" düğmeleri. Metinler ARB'den.

## "Giriş yap" / "Kayıt ol" geçişi (düğmeye basınca)
- Logo grubu ek olarak **ölçek 0,5'e küçülür** (150 px yukarıda kalır), 0,5 sn, `cubic-bezier(.3,.8,.2,1)`. Slogan 0,2 sn'de kaybolur, halka/parçacık kümesi kaybolur.
- Alt panel **330 → 700 px yüksekliğe büyür** (üst köşe 28, aynı panel; yeni sayfaya geçilmez).
- Panelin eski içeriği (başlık + 2 düğme) 0,3 sn'de solar ve 10 px yukarı kayar.
- Yeni form (giriş ya da kayıt) 0,25 sn gecikmeyle belirir: 0,3 sn solma + 0,4 sn'de 16 px aşağıdan yukarı gelme. İçindeki öğeler sırayla gelir: her biri 12 px aşağıdan yukarı + solma, gecikmeler 0,25 / 0,30 / 0,36 / 0,42 / 0,48 / 0,54 sn.
- Geri dönünce aynısı tersine oynar.
- Aynı yıldızlı üst şerit + panel düzeni 1.02, 1.08 ve diğer giriş/kayıt ekranlarında da kullanılır.

## 1.09 "Bağlantı gönderildi" zarf animasyonu (mockup 4 sn döngü; uygulamada bir kez, son karede durur)
Mockup'ta döngü geri sarılıyor, uygulamada sadece ileri kısmı oynasın ve açık zarf + tik halinde dursun.
- **Zarf kapağı** (120×46, zarfın üst kenarından menteşeli): 0,32 → 0,88 sn'de dikey ölçek 1 → −1 (açılır). Açılırken arkaya geçer (katman sırası 0,6 sn civarında değişir).
- **Mektup** (90×70, beyaz, köşe 8, hafif gölge): 0,8 → 1,52 sn'de 16 px aşağıdan 26 px yukarıya çıkar, `cubic-bezier(.3,.8,.3,1)`. Orada kalır.
- **Onay (tik) işareti** (22 px daire, `#2F5FC4`, mektubun sağ üst köşesinde, kenardan 12, üstten 10): 1,52 sn'ye kadar yok (ölçek 0), 1,52 → 1,84 sn'de ölçek 0 → 1,2, 1,84 → 2,08 sn'de 1,0'a oturur. Orada kalır.
