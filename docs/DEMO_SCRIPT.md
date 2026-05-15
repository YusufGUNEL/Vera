# Vera - 90 Saniye Sahne Senaryosu

> Jüri önünde anlatım için tek-hikaye akışı. Her geçiş `next` ile yazıldı; ekran değişimi 5-15 sn'den uzun sürmemeli.

---

## Açılış (10 sn)

**Söyle:**
> "Türkiye'de finansal yaşam dağınık. Banka uygulaması, kart, yatırım, abonelikler — beş ayrı yer.
> Vera bunu tek bir AI-native asistana indiriyor. Banka değil — **finansal koç**."

Açılış ekranı: Home, **Savings Story** kartını göster.

---

## Adım 1 — Home & Story Card (15 sn)

**Söyle:**
> "Bu kullanıcı bu ay TL 2.480 tasarruf etti. Sebep tek değil — Uma'nın 3 önerisi.
> Yani Vera açıklanabilir bir AI: rakam ve sebep birlikte gelir."

**Tap:** Savings story kartına dokun → UMA chat'i açılır (alıştırma).

---

## Adım 2 — Upcoming Bills (10 sn)

**Söyle:**
> "Geri dön. Yaklaşan ödemeler — Akbank kartı 3 gün kaldı, kırmızı uyarı.
> Vera proaktif: jeton boşalmadan haber veriyor."

**Tap:** Akbank Platinum kartına dokun → snackbar veya Uma akışı.

---

## Adım 3 — Fiş Tarama (Receipt OCR) — En kritik 20 sn

**Söyle:**
> "Banka bağlantısı olmadan da gerçek veri akabilir.
> Vera Gemini ile fiş okuyor — bakın."

**Adım:** Sağ üstteki tarama ikonuna tıkla → "Galeriden seç" → demo görseli seç → AI 2 sn'de parse → kategori + toplam + satırlar görünür.

**Söyle:**
> "Gemini multimodal canlı çalışıyor. Merchant, toplam, kategori — hiçbiri elle girilmedi.
> 'İşlemlerime ekle' diyorum, anında akışa düşüyor."

---

## Adım 4 — Security & Açıklanabilirlik (15 sn)

**Geçiş:** Bottom nav → Security.

**Söyle:**
> "Bir bilinmeyen alıcıya yapılan transfer engellenmiş.
> Vera neden? diye açıklıyor: yeni hesap, beklenmeyen lokasyon.
> 'Bu bendim' veya 'Dolandırıcılık' geri bildirimi — sistem kullanıcıdan öğreniyor."

---

## Adım 5 — Credit Simülasyonu (15 sn)

**Geçiş:** Bottom nav → Credit.

**Söyle:**
> "Kredi kararı kara kutu değil. Tutarı çekiyorum, vadeyi değiştiriyorum — skor canlı değişiyor.
> Risk faktörleri sıralı, alternatif teklif hazır. Karar rule engine, açıklama Gemini."

**Adım:** Loan simulation sheet'i aç, slider'ları çek.

---

## Adım 6 — UMA Sesli Koç (5 sn kapanış)

**Tap:** Ortadaki UMA butonu.

**Yaz / söyle:** `Pay my credit card`

UMA order card hazırlar → "Confirm" → snackbar.

**Kapat:**
> "Vera bir chatbot değil — birbirine bağlı 6 AI sisteminin tek bir finansal kokpiti.
> Banka değil, koç. **Yarın gerçek API'lerle aynı katmana plug-in olur.**"

---

## Pratik notlar

- **Telefonu enlemesine değil dik tut** — Flutter Chrome'da test ettiysen mobile viewport aç (`F12 → Toggle device toolbar → iPhone 14 Pro`)
- **Wi-Fi:** Gemini API key gerekiyorsa demo öncesi `.env`'i kontrol et. Yoksa fallback otomatik devreye girer ama "DEMO" rozeti görünür — bunu söyleme zorunda değilsin
- **Dil:** TR ile başla, son 10 sn İngilizce dil değiştir → "uygulama 6 dilde, Arapça'da RTL" → AR'ye tıkla → sahnede sessizce **wow** olur
- **Akış zamanı:** Toplam 90 sn. Aşmazsan jüri "tamamı görüldü, sıkmadı" hisseder

## Demo öncesi checklist

- [ ] `flutter build apk --release` ile APK al
- [ ] Telefona yükle, **uçak modu açıkken** açıldığından emin ol (fallback test)
- [ ] `.env`'e gerçek `GEMINI_API_KEY` koy (yoksa OCR fallback)
- [ ] Demo cihazını şarjda bırak
- [ ] Sahnede projektöre verirsen: `flutter build web` → bir hostinge bırak → projektörde browser üzerinden aç
- [ ] Anlatıcıyı ezberle. Jürinin gözlerine bak, ekrana değil
