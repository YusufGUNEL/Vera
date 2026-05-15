# Vera — Özellik Durumu

> Bu dosya **2026-05-15** itibariyle uygulamadaki tüm özelliklerin durumunu listeler. **Üç kategori:** ✅ tam çalışıyor, ⚠ kısmi/mock veri, 🔜 önerilen sıradaki adım. Her özellik için "lisans gerekir mi?" sorusu cevaplı.
>
> **Ürünün vaadi (tek cümle):** *Vera bankaları bağlamıyor — sen veriyi getiriyorsun (PDF ekstre, fiş fotoğrafı, ekran görüntüsü, manuel giriş), Vera AI ile birleştirip anlamlandırıyor, doğru bankaya yönlendirip sonucu takip ediyor.* Bu modelde **BDDK lisansı veya bank partnership gerekmiyor.**

---

## ✅ Tam çalışan özellikler

### Mimari & Altyapı
- **Feature-first Flutter mimarisi** — `lib/features/<name>/{domain,data,state,presentation}` ayrımı (docs/MIMARI.md)
- **Riverpod state management** — controller / provider / state ayrımı her feature'da
- **AppTokens InheritedWidget** — `context.tokens` ile theme tokenları (palette, vibe, mood)
- **6 dilli i18n + RTL** — TR / EN / DE / AR / RU / ZH; `context.l10n` extension; SharedPreferences ile kalıcı
- **AppLocale RTL** — Arapça seçildiğinde arayüz otomatik RTL'ye döner
- **Profile sheet'te dil seçici** — 6 chip ile anlık geçiş
- **Tema sistemi** — 4 palette (forest/midnight/plum/mono) × 2 mood (light/dark) × 3 vibe (calm/standard/bold)
- **Auth (demo)** — SharedPreferences tabanlı kullanıcı oturumu, sign-out çalışıyor

### Home ekranı
- **TopBar** — avatar tap → profile sheet; sağda **2 ikon: yükle (ekstre) + tara (fiş)** + bildirim zili (snackbar)
- **NetWorthCard** — gradient, 4 quick action butonu (Send/Request/Top-up/Pay) — tıklanır snackbar
- **SavingsStoryCard** — yeşil-mor gradient, "Bu ay TL X tasarruf, Uma'nın 3 önerisiyle" — tap UMA'yı açar
- **UpcomingBillsStrip** — 3 yatay kart (Akbank Platinum/Türk Telekom/BEDAŞ); 3 gün altı kırmızı uyarı; tap snackbar
- **ConnectedBanks** — yatay banka kartları + "Banka ekle" CTA; her kart tıklanır
- **UmaInsightStrip** — AI özet bandı; tap UMA chat'i açar
- **CreditSummaryCard** — kredi skoru + band; tap `/credit`'e gider
- **TransactionList** — gruplandırılmış işlemler (Spent/In summary pill'leri), her satır tıklanır
- **Pull-to-refresh** — home_controller.refresh()

### Bottom nav (4 tab + UMA FAB)
- **2-2 simetrik:** Home — Wealth — **[UMA]** — Plans — Security
- UMA radial gradient FAB ortada; tap full-screen UMA chat sheet
- Opak beyaz nav bar (saydam değil)

### Wealth ekranı
- **PortfolioDonut** — özel painter, slice'lar + YTD center
- **3 PolicyChip** — Profile / Move Limit / Approval
- **"Bu ayın AI önerisi" kartı** — sahte autonomous toggle yerine; **"Bankamda uygula"** CTA
- **Activity feed** — Uma'nın geçmiş aksiyonları, "Why?" açıklamaları, undo + "View details" tıklanır
- "Real engagement" — kullanıcı action öneriyor, Vera ödeme yapmıyor

### Plans (Subscriptions) ekranı
- **Subscription intelligence** — aylık toplam, dikkat sayısı, AI insight
- **Filter chips:** Tümü / Dikkat / Kullanılmıyor / Fiyat değişimi
- **Sub tiles** — fiyat delta, "Freeze plan" / "Ask Uma" action chip'leri

### Credit ekranı
- **CreditGauge** — özel painter score gauge
- **Decision card** — approve/review/decline + risk factor listesi + alternatif teklif
- **Loan simulation sheet** — 4 slider (amount/term/income/debt), karar canlı değişir
- **AI explanation** — UMA insight kutusu her kararla

### Security ekranı
- **Vera-side banner** üstte — "Vera bankanın güvenlik katmanı değil, anomali görür uyarır"
- **Account security stat block** — durum, blocked / reviewed / devices sayısı
- **Recent activity feed** — fraud event'ler, "Keep blocked" / "This was me" feedback
- **AI fraud raporu** — UmaSoft kart içinde açıklama

### UMA Chat (full-screen sheet)
- **Intent router** — buyGold, payCreditCard, moveToSavings, showSubscriptions, analyzeSpending, explainWealth, checkLoanEligibility, explainSecurityAlert
- **Gemini fallback** — heuristic match yoksa Gemini'ye git, key yoksa generic mesaj
- **Order cards** — "Open [Bank]" CTA + "İşlem bankanda tamamlanır" notu
- **Deep-link semaları** — garantibbva://, akbankmobile://, yapikrediorg://, isbankisweb://, ziraatbankasi://, denizbankmobil://
- **Suggestion strip** — 5 hızlı komut chip'i (lokalize)
- **Settings drawer** — "Vera para hareketini bankanda yapar" politika açıklaması

### Receipt OCR
- **`features/receipt_scan/`** — domain / data / state / presentation tam yapı
- **image_picker** — kamera veya galeri
- **Gemini multimodal parse** — JSON çıkış: merchant / total / category / lines
- **Fallback** — API key yoksa Migros mock fişi (DEMO rozeti ile dürüst)
- **"İşlemlerime ekle" CTA** — snackbar (DB'ye yazma kısmı arkadaşının görevi)

### PDF/Excel Ekstre import
- **`features/statement_import/`** — domain / data / state / presentation tam yapı
- **file_picker** — PDF / PNG / JPG / WEBP seçimi (web + mobile)
- **Gemini multimodal PDF parser** — JSON çıkış: bank / period / balances / 20 transactions
- **Fallback** — Garanti BBVA mock ekstre (6 işlem)
- **"Vera'ya aktar" CTA** — snackbar

### Profile Settings
- **Profile card** + Session vault card
- **Dil seçici (6 chip)**
- **Brand palette swatch'leri** (4 palette)
- **Mood toggle** (Light/Dark)
- **Vibe selector** (Calm/Standard/Bold)
- **AI tone** (Concise/Coach/Proactive)
- **Daily briefing toggle**
- **Data sync mode** (Live/Balanced/Saver)
- **Auto-approve limit** (Off/2.5K/10K)
- **Notifications toggle** + **Face ID toggle** + **Fraud alerts toggle**
- **Connected institutions card**
- **Account tiles** (Personal / Email / Security / Storage / Help)
- **Sign out**

### Tooling
- **Flutter 3.41.9 stable** kurulu, PATH set
- **`flutter analyze` → 0 issue**
- **`flutter run -d chrome` çalışıyor** (web build hazır)
- **Android platform hazır** (`flutter build apk --release` ile demo APK alınır)

---

## ⚠ Kısmi / mock veri / eksik tarafı olan

| Özellik | Eksik kısım | Etki |
|---|---|---|
| Banka listesi | `data/bank.dart` içinde 3 sabit mock banka | Demo için sorun yok; gerçek kullanıcı kendi bankalarını ekleyebilmeli |
| İşlem geçmişi | `home_feed_repository.dart` mock veriyle | OCR/import gerçek çalışıyor; UI bunları henüz state'e bağlamıyor |
| Subscription listesi | `subscriptions_repository.dart` mock | Filter mantığı gerçek; veri sabit |
| Security feed | Fraud check'ler mock | Anomali detection gerçek değil; kullanıcı kendi verisinden tetiklemiyor |
| Wealth allocations | `wealth_repository.dart` mock portföy | Donut + chart gerçek, veri sabit |
| Credit decision | `credit_rule_engine.dart` gerçek matematik ama input mock | Slider'ları çevirince karar gerçek değişir |
| Gemini servisi | API key olmadan tüm AI özellikleri fallback'e düşer | Demo için "DEMO" rozetiyle dürüst; gerçek key konulunca canlı |
| Deep-link | `url_launcher` semaları sadece kuruluysa açılır | Web'de snackbar; gerçek telefonda açar |
| Uma sesli komut | Mic ikonu placeholder | "Voice command" tooltip var, henüz STT bağlı değil |
| Push notification | `notifications_enabled` toggle var ama FCM yok | Demo için snackbar yeterli |
| Database bağlantısı | Tüm controller'lar in-memory state | **Arkadaşının görevi — beklemede** |
| Login | Sadece demo (SharedPreferences) | Gerçek OAuth/email yok |
| Profile tiles (Personal info/Email...) | Tap on tile no-op | Bilgi gösteriliyor ama edit ekranı yok |
| Help & support | Sadece label | Henüz support flow yok |

---

## 🔜 Eklenmesi önerilen (öncelik sırasıyla)

### P0 — Hackathon'dan önce yetişebilecek wow özellikleri

1. **Bütçe / kategori grafiği** — Home'da pie chart "bu ay 3.420 TL market, 1.180 TL yemek, ..." → kategori bazlı tasarruf önerisi
2. **Hedef takip kartı** — "Acil durum fonu TL 50K · %76 yolda" + her hafta otomatik progress
3. **Vera Insight bildirimi** — proaktif kart: "Netflix bu ay TL 50 zamlandı, freeze ister misin?"
4. **Onboarding akışı** — ilk açılışta 3 adım: dil → palette → ilk ekstre yükle veya fiş çek
5. **Demo veri replay butonu** — sunum sırasında "Reset to demo" — jüri tekrar görmek isterse 1 tıkla başa
6. **Story share** — "Bu ay TL 2.480 tasarruf ettim" → görsel kart → WhatsApp/Instagram share (image_gallery_saver)

### P1 — Hackathon sonrası ilk 2 hafta

7. **Bütçe planlayıcı** — kategori bazlı limit + "kalan ay X TL" göstergesi
8. **Tekrarlayan ödeme akıllı tespiti** — import edilen ekstrelerden otomatik abonelik bulma (regex + Gemini)
9. **Vera Goals** — birden fazla hedef (tatil / araba / acil fon), her birine ayrı kart
10. **Birden fazla profil / aile modu** — eş + çocuk için ortak görünüm
11. **Onaylı kullanıcı geri bildirimi** — "Bu insight faydalıydı / değildi" → AI promptunu zenginleştir
12. **Local notifications** — fatura yaklaştığında schedule edilmiş bildirim (FCM olmadan)
13. **Settings → Verilerini dışa aktar (JSON / CSV)** — kullanıcı kendi verisini indirebilsin (GDPR + güven)
14. **Açıklanabilirlik ayrıntı sayfası** — her UMA aksiyonu için "Neden bu öneri?" → faktör listesi

### P2 — Yıl sonu büyüme yolu

15. **Lisanslı AISP partnership** — Param veya başka bir Açık Bankacılık aggregator'ı ile gerçek bakiye okuma (kullanıcı izinli)
16. **Vera Card** — partner bir bankayla white-label kart (FT, Halkbank, Kuveyt Türk pilot)
17. **Vera Pro abonelik** — gelişmiş AI insights + sınırsız OCR + öncelikli destek
18. **Voice command (gerçek STT)** — speech_to_text paketi + Gemini fonksiyon çağrısı
19. **Yatırım partneri** — BiGA / Ahlatcı API üzerinden gerçek altın alımı (SPK lisanslı, BDDK değil)
20. **Vera Family** — eş/çocuk paylaşımı, ebeveyn kontrolü, çocuğun harçlığı için cüzdan
21. **Compliance / audit log** — her aksiyon imzalı, kullanıcıya görünür

### P3 — Vizyon (uzun vadeli)

22. **Vera kendi açık bankacılık lisansını alır** — BDDK Hesap Bilgisi Hizmeti Sağlayıcısı (AISP eşdeğeri)
23. **Direkt banka API'lerine entegrasyon** — Garanti BBVA API Lab, Akbank Lab vb. ile resmi pilot
24. **B2B Vera for SMEs** — KOBİ versiyonu, muhasebe entegrasyonu
25. **Vera Coach yıllık planı** — kullanıcı için bir yıllık birikim & yatırım planı, Gemini Pro ile

---

## Lisans matrisi (özet)

| Yetenek | Lisans gerekir mi? | Vera bunu yapabilir mi? |
|---|---|---|
| PDF ekstre okuma | ❌ | ✅ Bugün |
| Fiş OCR | ❌ | ✅ Bugün |
| Ekran görüntüsü parse | ❌ | ✅ Bugün |
| Manuel hesap/bakiye girişi | ❌ | ✅ Bugün |
| AI harcama analizi | ❌ | ✅ Bugün |
| Kredi simülasyonu (matematik + AI öneri) | ❌ | ✅ Bugün |
| Bankaya deep-link | ❌ | ✅ Bugün |
| Push notification (kullanıcı izinli) | ❌ | ⚠ FCM kurulumu |
| **Gerçek zamanlı bakiye gör** | ✅ AISP lisansı | ❌ Partnership şart |
| **Banka adına para gönder** | ✅ Ödeme Hizmeti Sağlayıcısı (PSP) | ❌ Lisans şart |
| **Direkt altın al / yatırım** | ✅ SPK / kuyumculuk lisansı | ❌ Partnership şart |
| **Kart blokla / fraud durdur** | ✅ Banka kendisi | ❌ Sadece bankaya iletilir |

Bu matriks, jüriye karşı net konuşmanı sağlar: **Vera bugün yapabilen her şeyi yapıyor; yapamadıklarını da neden yapamadığını gerekçeli söylüyor.**

---

## Demo öncesi son kontrol listesi (özet)

- [ ] `.env`'e gerçek `GEMINI_API_KEY` koy (yoksa OCR/import "DEMO" rozetiyle çalışır, yine iyi)
- [ ] `flutter build apk --release` ile imzalı APK al, telefonda kur
- [ ] Uçak modunda da açılıyor mu test et (fallback path)
- [ ] Dil değişimini sahnede göster — AR'ye geç, RTL'yi vurgula
- [ ] Reset-to-demo akışı varsa kullan
- [ ] Demo cihazını şarjda bırak, ekran kilidini kapat (auto-lock off)
- [ ] Anlatıcıyı (docs/DEMO_SCRIPT.md) ezberle — jüriyi gör, ekrana değil
