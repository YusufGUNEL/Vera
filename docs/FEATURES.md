# Vera — Özellik Durumu

> Bu dosya **2026-05-16** itibariyle uygulamadaki özelliklerin durumunu listeler. **İki kategori:** ✅ tam çalışıyor, 🔜 yapılacak (hackathon scope'unda gerçekçi).
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
- **Tema sistemi** — 4 palette (forest/midnight/plum/mono) × 2 mood (light/dark) × 3 vibe (calm/standard/bold)
- **Auth (demo)** — SharedPreferences + flutter_secure_storage tabanlı oturum, sign-up / sign-in / sign-out çalışıyor

### Home ekranı
- **TopBar** — avatar tap → profile sheet; sağda 2 ikon: yükle (ekstre) + tara (fiş)
- **NetWorthCard** — gradient, 4 quick action butonu (Send/Request/Top-up/Pay)
- **SavingsStoryCard** — "Bu ay TL X tasarruf, Uma'nın 3 önerisiyle" → tap UMA'yı açar
- **UpcomingBillsStrip** — 3 yatay kart; 3 gün altı kırmızı uyarı
- **ConnectedBanks** — yatay banka kartları + "Banka ekle" CTA (gerçek wire)
- **UmaInsightStrip** — AI özet bandı; tap UMA chat'i açar
- **CreditSummaryCard** — kredi skoru + band; tap `/credit`'e gider
- **TransactionList** — gruplandırılmış işlemler (Spent/In summary pill'leri)
- **Pull-to-refresh** — home_controller.refresh()

### Bottom nav (4 tab + UMA FAB)
- **2-2 simetrik:** Home — Wealth — **[UMA]** — Plans — Security
- UMA radial gradient FAB ortada; tap full-screen UMA chat sheet

### Wealth ekranı
- **PortfolioDonut** — özel painter, slice'lar + YTD center
- **3 PolicyChip** — Profile / Move Limit / Approval
- **"Bu ayın AI önerisi" kartı** — "Bankamda uygula" CTA
- **Activity feed** — Uma'nın geçmiş aksiyonları, "Why?" açıklamaları, undo + "View details"

### Plans (Subscriptions) ekranı
- **Subscription intelligence** — aylık toplam, dikkat sayısı, AI insight
- **Filter chips:** Tümü / Dikkat / Kullanılmıyor / Fiyat değişimi
- **Sub tiles** — fiyat delta, "Freeze plan" / "Ask Uma" action chip'leri
- **Import-driven detection** — `RecurringTransactionParser` import edilen transaction'ları tarar; 14 bilinen vendor (Netflix/Spotify/YouTube/iCloud/Apple/Amazon/Disney/Exxen/BluTV/Gain/tabii/GitHub/OpenAI/Anthropic) match'leri ve 2+ tekrarlı işlemler otomatik abonelik listesine düşer

### Credit ekranı
- **CreditGauge** — özel painter score gauge
- **Decision card** — approve/review/decline + risk factor listesi + alternatif teklif
- **Loan simulation sheet** — 4 slider (amount/term/income/debt), karar canlı değişir
- **Rule engine** — `credit_rule_engine.dart` gerçek matematik; slider'larla canlı yeniden hesaplanır
- **AI explanation** — UMA insight kutusu her kararla

### Security ekranı
- **Vera-side banner** — "Vera bankanın güvenlik katmanı değil, anomali görür uyarır"
- **Account security stat block** — durum, blocked / reviewed / devices sayısı
- **Recent activity feed** — fraud event'ler, "Keep blocked" / "This was me" feedback
- **AI fraud raporu** — UmaSoft kart içinde açıklama
- **Fraud → Local notification** — yeni blocked event geldiğinde `NotificationService.showFraudAlert` fırlar, payload `/security`; bootstrap seed'leri için duplicate atılmaz

### UMA Chat (full-screen sheet)
- **Intent router** — buyGold, payCreditCard, moveToSavings, showSubscriptions, analyzeSpending, explainWealth, checkLoanEligibility, explainSecurityAlert
- **Gemini servisi** — `GeminiService` tek giriş noktası; API key varsa canlı, yoksa heuristic / deterministic fallback (DEMO rozetiyle dürüst)
- **Order cards** — "Open [Bank]" CTA + "İşlem bankanda tamamlanır" notu
- **Deep-link semaları** — garantibbva://, akbankmobile://, yapikrediorg://, isbankisweb://, ziraatbankasi://, denizbankmobil:// (gerçek cihazda banka app'i açar)
- **Suggestion strip** — 5 hızlı komut chip'i (lokalize)
- **Settings drawer** — "Vera para hareketini bankanda yapar" politika açıklaması

### Receipt OCR
- **`features/receipt_scan/`** — domain / data / state / presentation tam yapı
- **image_picker** — kamera veya galeri
- **Gemini multimodal parse** — JSON çıkış: merchant / total / category / lines
- **Fallback** — API key yoksa Migros mock fişi (DEMO rozeti ile dürüst)
- **"İşlemlerime ekle" CTA** — gerçek wire: `HomeController.addImportedTransactions` üzerinden home transaction listesine eklenir ve SharedPreferences'a persist eder

### PDF/Excel Ekstre import
- **`features/statement_import/`** — domain / data / state / presentation tam yapı
- **file_picker** — PDF / PNG / JPG / WEBP seçimi (web + mobile)
- **Gemini multimodal parser** — JSON çıkış: bank / period / balances / 20 transactions
- **Fallback** — Garanti BBVA mock ekstre (6 işlem)
- **"Vera'ya aktar" CTA** — gerçek wire: tüm transaction'lar home listesine yazılır, persist eder

### Banka yönetimi
- **"Banka ekle" sheet** — ad, son 4 hane, başlangıç bakiyesi, 8 renk swatch; `BanksStore` ile SharedPreferences'a persist
- **`HomeController.removeCustomBank(id)`** — custom banka silme API'si mevcut (UI henüz yok)
- **Toplam bakiye otomatik** — feed bankaları + custom bankalar üzerinden hesaplanır

### Profile / Account tiles (gerçek detail sheet'leri)
- **Personal info / Email** — okuma-only sheet'ler
- **Security** — Session vault, Face ID durumu, Fraud uyarıları durumu
- **Storage** — Sync modu, yerel veri açıklaması
- **Help & support** — 3 FAQ (banka bağlantısı / veri saklama / Gemini key yok) + iletişim bilgisi
- `AccountInfoSheet` generic widget'ı tüm tile'ları besler

### Profile Settings (genel)
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
- **Sign out**

### Tooling
- **Flutter 3.24+** desteklenir
- **`flutter analyze` → 0 issue**
- **`flutter run -d chrome`** çalışıyor (web build hazır)
- **Android platform hazır** (`flutter build apk --release`)

---

## 🔜 Eklenmesi önerilen (hackathon scope'unda)

### P0 — Demo öncesi yetişebilecek wow özellikleri

1. **Bütçe / kategori grafiği** — Home'da pie chart "bu ay 3.420 TL market, 1.180 TL yemek, ..." → kategori bazlı tasarruf önerisi
2. **Hedef takip kartı** — "Acil durum fonu TL 50K · %76 yolda" + her hafta otomatik progress
3. **Vera Insight bildirimi** — proaktif kart: "Netflix bu ay TL 50 zamlandı, freeze ister misin?"
4. **Onboarding akışı** — ilk açılışta 3 adım: dil → palette → ilk ekstre yükle veya fiş çek
5. **Demo veri replay butonu** — sunum sırasında "Reset to demo" — jüri tekrar görmek isterse 1 tıkla başa
6. **Story share** — "Bu ay TL 2.480 tasarruf ettim" → görsel kart → WhatsApp/Instagram share (image_gallery_saver)

### P1 — Hackathon sonrası ilk 2 hafta

7. **Bütçe planlayıcı** — kategori bazlı limit + "kalan ay X TL" göstergesi
8. **Vera Goals** — birden fazla hedef (tatil / araba / acil fon), her birine ayrı kart
9. **Onaylı kullanıcı geri bildirimi** — "Bu insight faydalıydı / değildi" → AI promptunu zenginleştir
10. **Scheduled local notifications** — fatura yaklaştığında schedule edilmiş bildirim
11. **Settings → Verilerini dışa aktar (JSON / CSV)** — kullanıcı kendi verisini indirebilsin
12. **Açıklanabilirlik ayrıntı sayfası** — her UMA aksiyonu için "Neden bu öneri?" → faktör listesi
13. **Voice command (gerçek STT)** — speech_to_text paketi + Gemini fonksiyon çağrısı
14. **Custom banka silme UI** — `removeCustomBank` API'si var, sheet eklenmeli
15. **Compliance / audit log** — her aksiyon imzalı, kullanıcıya görünür

---

## Lisans matrisi (positioning)

| Yetenek | Lisans gerekir mi? | Vera bunu yapabilir mi? |
|---|---|---|
| PDF ekstre okuma | ❌ | ✅ Bugün |
| Fiş OCR | ❌ | ✅ Bugün |
| Ekran görüntüsü parse | ❌ | ✅ Bugün |
| Manuel hesap/bakiye girişi | ❌ | ✅ Bugün |
| AI harcama analizi | ❌ | ✅ Bugün |
| Kredi simülasyonu (matematik + AI öneri) | ❌ | ✅ Bugün |
| Bankaya deep-link | ❌ | ✅ Bugün |
| Local notification (fraud / fatura) | ❌ | ✅ Bugün |

Vera'nın kapsamında **olmayan** yetkinlikler (lisans + partnership gerektiriyor, hackathon scope dışı):
gerçek zamanlı bakiye okuma (AISP), banka adına para gönderimi (PSP), direkt yatırım emri (SPK), kart bloklama (banka).

**Konumlandırma:** Vera bugün yapabilen her şeyi yapıyor; yapamadıklarını yapmıyormuş gibi davranmıyor.

---

## Demo öncesi son kontrol listesi

- [ ] `.env`'e gerçek `GEMINI_API_KEY` koy (yoksa OCR/import "DEMO" rozetiyle çalışır, yine iyi)
- [ ] `flutter build apk --release` ile imzalı APK al, telefonda kur
- [ ] Uçak modunda da açılıyor mu test et (fallback path)
- [ ] Dil değişimini sahnede göster — AR'ye geç, RTL'yi vurgula
- [ ] Demo cihazını şarjda bırak, ekran kilidini kapat (auto-lock off)
- [ ] Anlatıcıyı (docs/DEMO_SCRIPT.md) ezberle — jüriyi gör, ekrana değil
