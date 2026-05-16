# Vera — Özellik Durumu

> Bu dosya **2026-05-16** itibariyle uygulamadaki özelliklerin durumunu listeler. **İki kategori:** ✅ tam çalışıyor, 🔜 yapılacak (hackathon scope'unda gerçekçi).
>
> **Ürünün vaadi (tek cümle):** *Vera bankaları bağlamıyor — sen veriyi getiriyorsun (PDF ekstre, fiş fotoğrafı, ekran görüntüsü, manuel giriş), Vera AI ile birleştirip anlamlandırıyor, doğru bankaya yönlendirip sonucu takip ediyor.* Bu modelde **BDDK lisansı veya bank partnership gerekmiyor.**

> **Sahte veri yok:** Ekrandaki tüm metrikler ya gerçek transaction listesinden hesaplanır (savings, kategori dağılımı, today delta, YTD), ya kullanıcı state'inden (banks, goal, custom banks), ya da rule engine'den (credit, fraud) gelir. "Coming soon" placeholder'ları kaldırıldı.

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
- **TopBar** — avatar tap → profile sheet; sağda 3 ikon: yükle (ekstre) + tara (fiş) + bildirim merkezi
- **NetWorthCard** — gradient, 4 quick action butonu; her biri UMA chat'i prompt'la açar (Send / Request / Top-up / Pay)
- **SavingsStoryCard** — bu ay net tasarruf (income − spending) ve dinamik delta % transaction listesinden hesaplanır; transaction yoksa kart gizlenir
- **GoalCard** — Acil durum fonu hedef kartı; tap → düzenle sheet; SharedPreferences'a persist
- **ProactiveInsightCard** — "Vera fark etti" kartı; subscription artışı, kullanılmayan abonelik veya yaklaşan fatura tespit edildiğinde otomatik görünür; tap → Uma chat veya ilgili rota
- **UpcomingBillsStrip** — 3 yatay kart; 3 gün altı kırmızı uyarı; tap → UMA chat fatura prompt'uyla açılır
- **ConnectedBanks** — yatay banka kartları + "Banka ekle" CTA; tap veya long-press → banka aksiyonları sheet (feed bankaları silinemez, custom bankalar onay diyaloğuyla silinir)
- **UmaInsightStrip** — AI özet bandı; tap UMA chat'i açar
- **CategoryBudgetCard** — son işlemleri kategoriye göre gruplar; donut + top 5 kategori + % progress; "en çok harcanan" özet
- **CreditSummaryCard** — kredi skoru + band; tap `/credit`'e gider
- **TransactionList** — gruplandırılmış işlemler (Spent/In summary pill'leri); tap → işlem detay sheet (Uma'ya sor CTA'sıyla)
- **NotificationCenterSheet** — bell tap → gerçek bildirim listesi: blocked fraud event'ler + price-increased subscriptions + unused subscriptions + yaklaşan faturalar (boş durum için "her şey yolunda" ekranı)
- **Pull-to-refresh** — home_controller.refresh()

### Bottom nav (4 tab + UMA FAB)
- **2-2 simetrik:** Home — Wealth — **[UMA]** — Plans — Security
- UMA radial gradient FAB ortada; tap full-screen UMA chat sheet

### Wealth ekranı
- **PortfolioDonut** — özel painter, slice'lar + YTD center; YTD% ve today delta state'ten türetilir (sabit `+18.2%` ve `+4.820 TL` kaldırıldı)
- **3 PolicyChip** — Profile / Move Limit / Approval
- **"Bu ayın AI önerisi" kartı** — "Bankamda uygula" CTA artık UMA chat'i state.insight prompt'uyla açar
- **Activity feed** — Uma'nın geçmiş aksiyonları, "Why?" açıklamaları, undo + "View details" → action.why detay sheet'i

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
- **Verileri dışa aktar** — tüm yerel state'in (banks, transactions, goal, subscriptions) JSON snapshot'ı; selectable + Clipboard'a kopyala
- **Demo verisini sıfırla** — onay diyaloğu sonrası imports + custom banks + goal başlangıç durumuna döner
- **Sign out**

### Onboarding (ilk açılış)
- **3 adımlık akış** — `/onboarding` rotası; SharedPreferences'a `onboarding.completed` yazılır; sign-in sonrası tamamlanmamışsa otomatik yönlendirme
- **Adım 1:** Dil seçimi (6 chip)
- **Adım 2:** Palette + Mood (light/dark) tercihi
- **Adım 3:** İlk veri (ekstre yükle / fiş tara) — atlamak da serbest
- **Skip / Back / Continue** kontrol bandı + progress göstergesi

### Bütçe planlayıcı (kategori limitleri)
- **CategoryBudgetCard** her satıra tap → `_CategoryLimitSheet`; aylık limit TL girilir, SharedPreferences'a yazılır
- **Kalan / aşan göstergesi** — limit varsa "kalan X TL", aşıldıysa kırmızı "limit aşıldı · X TL"
- **Progress bar rengi** limit aşımında kırmızıya döner; limit yoksa kategori rengi
- **Seed limits** — Market 4000, Yeme & İçme 1500, Abonelik 500, Akaryakıt 1200, Transfer 5000, Fatura 2500; kullanıcı her zaman değiştirebilir veya "Limiti kaldır"

### Scheduled bill reminders (yerel)
- **`NotificationService.scheduleAt`** — `flutter_local_notifications` + `timezone` ile `zonedSchedule`
- **Channel** — Android için ayrı `vera_bills` kanalı (default importance, fraud kanalından ayrı ton)
- **`BillRemindersScheduler`** — uygulama açılışında `kUpcomingBills` üzerinden geçer, vade öncesi 24 saat için tek-shot bildirim kurar
- **Locale değişimi** — `localeControllerProvider` dinlenir; dil değişince eski schedule iptal edilir ve yeni dilde mesajla yeniden kurulur (id range `4000+`)
- **Geçmiş tarih korumalı** — `tz.local` saatine göre geçmişte kalan schedule'lar sessizce atlanır

### Tooling
- **Flutter 3.24+** desteklenir
- **`flutter analyze` → 0 issue**
- **`flutter run -d chrome`** çalışıyor (web build hazır)
- **Android platform hazır** (`flutter build apk --release`)

---

## 🔜 Eklenmesi önerilen (hackathon scope'unda)

### Bu turda tamamlananlar (yukarıdaki ✅ bölümlerine taşındı)

- ✅ Bütçe / kategori grafiği (CategoryBudgetCard)
- ✅ Bütçe planlayıcı: kategori limiti + kalan TL (CategoryBudgetStore + edit sheet)
- ✅ Hedef takip kartı (GoalCard + GoalsStore)
- ✅ Vera Insight bildirimi (ProactiveInsightCard + NotificationCenterSheet)
- ✅ Scheduled bill reminders (BillRemindersScheduler + zonedSchedule)
- ✅ Onboarding akışı (3 adım, SharedPreferences flag)
- ✅ Demo veri replay butonu (Profile → "Demo verisini sıfırla")
- ✅ Verilerini dışa aktar (Profile → JSON snapshot + Clipboard)
- ✅ Açıklanabilirlik ayrıntı sayfası (Wealth "View details" → action.why detay sheet)
- ✅ Custom banka silme UI (BankActionsSheet, tap veya long-press)
- ✅ Quick action butonları artık UMA chat'i prompt'la açar (Coming Soon snackbar'ı kaldırıldı)
- ✅ Transaction tap → detay sheet ("Uma'ya sor" CTA'sıyla)
- ✅ Bildirim merkezi (NotificationCenterSheet — gerçek fraud + subscription + bill sinyalleri)
- ✅ Wealth today delta / YTD% state'ten türetilir (hardcoded değerler kaldırıldı)

### Yapılacaklar (sonraki tur)

1. **Story share** — `share_plus` paketi; "bu ay TL X tasarruf" görsel kartını WhatsApp/Instagram'a paylaş
2. **Vera Goals (çoklu)** — şu an tek hedef (acil fon); birden fazla hedef için goals listesi + add/edit/delete
3. **Uma cevap geri bildirimi** — Uma mesajlarına thumbs up/down + opsiyonel not; AI prompt'unu zenginleştirir
4. **Voice command (gerçek STT)** — `speech_to_text` paketi + Gemini fonksiyon çağrısı; Android/iOS permission akışı
5. **Compliance / audit log** — her UMA aksiyonu için imzalı kayıt (timestamp + intent + user decision); demo "trust" anlatımını güçlendirir

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
