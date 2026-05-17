# Yapılacaklar — Vera Demo Hazırlığı

> **Amaç:** Demo öncesi kalan 6 eksiği kapatmak.
> **Tahmini süre:** ~2 saat.
> **Durum (2026-05-17):** Gemini API key `.env`'e yazıldı, ilk büyük commit ve push tamamlandı (`353eb48`). Buradan devam ediyoruz.
> **Kullanım:** Sırayla oku, sırayla uygula. Her adımda hangi dosya, hangi komut, ne beklendiği yazıyor. Takıldığında ilgili **"Takılırsa"** kutusuna bak.
>
> ## İçindekiler
>
> 0. [Hızlı Sağlık Kontrolü](#0-hızlı-sağlık-kontrolü-5-dk--başlamadan-önce) — başlamadan önce
> 1. [Receipt OCR fallback'ini düzelt](#adım-1--receipt-ocr-fallbackini-düzelt-15-dk--kritik) — 15 dk, kritik
> 2. [Statement Import fallback'ini düzelt](#adım-2--statement-import-fallbackini-düzelt-10-dk--kritik) — 10 dk, kritik
> 3. [TR-hardcoded string'leri 6 dile lokalize et](#adım-3--yeni-tr-hardcoded-stringleri-6-dile-lokalize-et-60-90-dk--kritik) — 60-90 dk, kritik
> 4. [Remote'a push](#adım-4--remotea-push-2-dk) — 2 dk
> 5. [Onboarding flow'unu test et](#adım-5--onboarding-flowunu-test-et-10-dk) — 10 dk
> 6. [Vakit kalırsa: ek iyileştirmeler](#adım-6--vakit-kalırsa-ek-iyileştirmeler)

---

## 0. Hızlı Sağlık Kontrolü (5 dk) — BAŞLAMADAN ÖNCE

Önce projenin hâlâ derlendiğini doğrula. Repo kökündeyken (yani `C:\Dark\BTK Hackathon\vera`):

```powershell
flutter pub get          # paketleri çek
flutter analyze          # 0 issue beklenir
flutter test             # all passed beklenir
```

- Üçü de yeşilse → devam et, Adım 1'e geç.
- Birinde hata varsa → bana yaz, durum farklı olabilir. **Hatayı görmeden bir şey commit etme.**

---

## Bugünkü durum (özet) — bu kısmı sadece bilgi için oku

- Tüm hardcoded mock veri silindi (`kBanks`, `kTransactions`, `kSecurityChecks`, `kUpcomingBills`, `FinancialGoal.seed`, wealth/credit/sub defaults).
- Uygulama artık **boş tuval** olarak başlıyor; kullanıcının kendi verisini girmesini bekliyor.
- Üzerine **gerçek kullanıcı verisini** kullanan AI özellikleri eklendi:
  - Uma chat artık kullanıcı banks/txn/goal verisini context olarak kullanıyor.
  - AI auto-categorization (`lib/core/services/ai_categorizer.dart`).
  - Spending insight (`spending_insight_controller.dart`).
  - Net worth sparkline (`net_worth_history_store.dart`).
  - Goal advisor (Gemini'ya aylık plan sorduran `goal_advisor.dart`).
  - Fraud heuristic (`fraud_heuristic.dart`).
- Gemini API key `.env`'e yazıldı; `.gitignore` sayesinde remote'ta yok. Demo sonrası key rotate edilmeli (key kısa süreliğine sohbete yapıştırıldığı için).
- 50 dosyalık commit (`353eb48`) GitHub'a push edildi.

Detay için: `docs/CHANGELOG.md` → `2026-05-17` girdisi.

---

# YAPILACAKLAR — sırayla

## Adım 1 — Receipt OCR fallback'ini düzelt (15 dk) — KRİTİK

### Problem

`lib/features/receipt_scan/data/receipt_repository.dart` → satır 65-81 arası `_fallback()` metodu, Gemini cevap veremezse **sahte "Migros M.Pro 642.80 TL, Süt/Ekmek/Tavuk..." verisi döndürüyor**. Kullanıcı bunu confirm edip transaction listesine ekliyor. "No mock data" sözümüzü bozuyor.

### Çözüm

`_fallback()` metodunu **boş/null** bir `ParsedReceipt` döndürecek şekilde değiştir. UI tarafında `source: ReceiptSource.fallback` olduğunda kullanıcıya **"Gemini API key yok veya parse başarısız, lütfen manuel gir"** uyarısı çıksın, confirm butonu **disabled** olsun.

### Tam olarak yapılacaklar

1. Aç: `lib/features/receipt_scan/data/receipt_repository.dart`
2. `_fallback()` metodunu (65-81 arası) şununla değiştir:
   ```dart
   ParsedReceipt _fallback({String? rawText}) {
     return ParsedReceipt(
       merchant: null,
       total: null,
       category: null,
       date: null,
       rawText: rawText,
       source: ReceiptSource.fallback,
       lines: const [],
     );
   }
   ```
3. Kaydet. Şimdi UI'da fallback durumunda confirm butonunu kapat:
4. Receipt scan ekranını bul:
   ```powershell
   # repo kökünde:
   Grep "ReceiptSource.fallback" --type dart
   ```
   Genelde `lib/features/receipt_scan/presentation/*.dart` altında bir confirm sheet'i var. Aç onu.
5. Confirm butonunda şu koşulu ekle:
   ```dart
   final isFallback = parsed.source == ReceiptSource.fallback;
   // ...
   FilledButton(
     onPressed: isFallback ? null : () => _confirm(parsed),
     child: Text(isFallback ? 'AI çalışmadı — manuel gir' : 'Onayla'),
   ),
   ```
6. Test et:
   - `.env`'deki key'i geçici olarak bozulu hale getir (`GEMINI_API_KEY=fake`).
   - Uygulamayı çalıştır, fiş tara → confirm butonu disabled olmalı.
   - Key'i geri düzelt.

### Takılırsa:

- Eğer receipt scan ekranı confirm butonunu bulamazsan: `Grep "_confirm\|onConfirm" lib/features/receipt_scan` ile bul.
- UI değişikliğini `app_strings.dart`'a key ekleyerek lokalize etmek daha temiz. Vakit varsa: Adım 3 ile beraber yap.

---

## Adım 2 — Statement Import fallback'ini düzelt (10 dk) — KRİTİK

### Problem

`lib/features/statement_import/data/statement_repository.dart` → satır 67-105 arası `_fallback()`, sahte "Garanti BBVA / Maaş 32500 / Netflix 224.99 / Shell 1280 / BEDAŞ 380" verisi döndürüyor.

### Çözüm

Aynı mantık. `_fallback()` boş bir `ParsedStatement` dönsün:

1. Aç: `lib/features/statement_import/data/statement_repository.dart`
2. `_fallback()` metodunu (67-105 arası) şununla değiştir:
   ```dart
   ParsedStatement _fallback({String? rawText}) {
     return ParsedStatement(
       bank: null,
       accountLast4: null,
       period: null,
       openingBalance: null,
       closingBalance: null,
       rawText: rawText,
       source: StatementSource.fallback,
       transactions: const [],
     );
   }
   ```
3. UI tarafı (`lib/features/statement_import/presentation/*.dart`): receipt'tekiyle aynı mantık — `source == StatementSource.fallback` ise confirm disabled + uyarı.

### Test:

- `.env` key'i boz → ekstre yükle → confirm kapalı olmalı.
- Key'i düzelt → gerçek ekstre yükle → parse çalışmalı.

---

## Adım 3 — Yeni TR-hardcoded string'leri 6 dile lokalize et (60-90 dk) — KRİTİK

### Problem

Bugün eklediğim ~40 yeni UI string sadece Türkçe. App 6 dilli (TR/EN/DE/AR/RU/ZH). EN seçilince yeni UI Türkçe görünüyor.

### Lokalize edilecek string'lerin bulunduğu dosyalar

```
lib/features/home/presentation/widgets/add_bill_sheet.dart
lib/features/home/presentation/widgets/add_manual_transaction_sheet.dart
lib/features/home/presentation/widgets/upcoming_bills_strip.dart   (empty state)
lib/features/home/presentation/widgets/transaction_list.dart        (empty state)
lib/features/home/presentation/widgets/goal_card.dart               (advice UI)
lib/features/wealth/presentation/widgets/add_holding_sheet.dart
lib/features/wealth/presentation/wealth_screen.dart                 (empty state)
lib/features/subscriptions/presentation/subscriptions_screen.dart   (empty state)
lib/features/security/presentation/security_screen.dart             (empty state)
```

### Nasıl yapılır

`lib/core/localization/app_strings.dart` (2169 satır) merkezi string deposu. Pattern:

```dart
// Üst kısımda getter ekle:
String get addBillTitle => _t('addBillTitle');

// _strings map'inde 6 dilin her birine ekle:
AppLocale.tr: {
  'addBillTitle': 'Yeni fatura ekle',
  // ...
},
AppLocale.en: {
  'addBillTitle': 'Add new bill',
  // ...
},
// ... ve de/ar/ru/zh
```

Kullanım tarafında:
```dart
// Eski:
Text('Yeni fatura ekle')
// Yeni:
Text(context.l10n.addBillTitle)
```

### Adım adım iş akışı

1. Önce **string envanteri çıkar**. Her dosyada hardcoded TR'yi bul:
   ```powershell
   # Örnek — sırayla her dosyada:
   Grep "Text\('[A-ZĞÜŞİÖÇ]" lib/features/home/presentation/widgets/add_bill_sheet.dart
   ```
2. Bir liste tut (excel/notepad — Türkçe → key adı eşleştir):
   ```
   "Yeni fatura ekle"          → addBillTitle
   "Manuel işlem ekle"         → addTxnTitle
   "Henüz takip edilen fatura yok" → noBillsTracked
   "Portföye varlık ekle"      → addHoldingTitle
   "Bu varlığı kaldır"         → removeHolding
   ...
   ```
3. `app_strings.dart`'a tüm getter'ları ekle (uygun bölüme — ör. `// ---- Home sections ----` altına).
4. `_strings` map'inde **her 6 dile** de ekle. EN/DE çevirileri için: ChatGPT/DeepL kullanabilirsin, ya da AR/RU/ZH için Gemini'dan toplu çeviri iste:
   > Prompt: "Translate these Turkish UI strings to English, German, Arabic, Russian, Chinese (Simplified). Return JSON: `{"tr": "...", "en": "...", "de": "...", "ar": "...", "ru": "...", "zh": "..."}` for each."
5. Her widget dosyasında hardcoded TR'yi `context.l10n.<key>` ile değiştir.
6. `flutter analyze` → 0 issue olmalı.
7. Uygulamayı aç, dil seçiciden EN/DE seç → yeni UI'lar İngilizce/Almanca görünmeli.

### Takılırsa:

- `context.l10n` extension'ı bulunmuyorsa: `import 'package:vera/core/localization/app_strings_ext.dart';` (veya benzeri) ekle. Mevcut widget'lardan kopyala.
- Çevirilerde emin değilsen: EN'yi düzgün yap, diğerlerine **Gemini ile toplu çevir**, AR'da RTL test etmeyi unutma.
- Vakit darsa: AR/RU/ZH için en kritik 5-10 string'i çevir, geri kalanı placeholder olarak EN'i bırak. Demoda jüri TR/EN'e bakacak büyük ihtimalle.

---

## Adım 4 — Remote'a push (2 dk)

Üstteki 3 adımı bitirdikten sonra commit + push:

```powershell
git status                                    # değişikliklere bak
git add -A
git commit -m "Fix OCR fallback to return empty; localize all new strings to 6 languages"
git push origin main
```

### Takılırsa:

- **"Authentication failed"** → GitHub credential'ların yok. `git credential-manager` veya HTTPS yerine SSH kullan.
- **"Updates were rejected (non-fast-forward)"** → remote'ta yeni commit var. `git pull --rebase origin main` yap, conflict varsa çöz, sonra push.
- **Yanlış branch'tesin** → `git branch --show-current` → `main` olmalı.

---

## Adım 5 — Onboarding flow'unu test et (10 dk)

### Neden

`lib/features/onboarding/` dosyaları var ama ilk açılışta gösteriliyor mu, akış sona kadar gidiyor mu doğrulanmadı.

### Test adımları

1. Uygulamayı aç (`flutter run -d windows`).
2. Profil sekmesi → "Demo verisini sıfırla" → ardından "Sign out".
3. Login ekranı çıkacak → yeni hesapla giriş yap (veya guest mode).
4. **Beklenen:** Onboarding 3 ekranı gözüksün ("hoş geldin", "ne yapar", "izin iste" gibi).
5. Adımları geç → ana sayfaya düş → boş tuval gözüksün (banks, txns, goals hepsi boş).

### Sorun varsa

- Onboarding hiç gözükmüyorsa → `lib/features/onboarding/state/*.dart` içinde "shown" flag'i kullanılıyor olabilir, reset edilmemiş. SharedPreferences'i temizle (`flutter clean` + tekrar build, veya Android'de uygulama verisini temizle).
- Onboarding ortada takılıyorsa → o ekrandaki "next" butonu hangi controller'ı çağırıyor bak.

---

## Adım 6 — Vakit kalırsa: ek iyileştirmeler

### 6a) Subscription detection eşiğini düşür (15 dk)

`lib/features/subscriptions/` altında bir parser var (`recurring_transaction_parser.dart` muhtemelen). Şu an "**en az 2 görünüm**" eşiği muhtemelen yüksek — tek aylık ekstrede çoğu abonelik tek görünür → tespit edilmez.

Çözüm: 1 görünüm + Gemini'a "bu Netflix/Spotify/YouTube Premium gibi bilinen bir abonelik mi?" diye sorduran bir helper. Veya isim eşleştirme listesi (`netflix|spotify|youtube premium|disney|hbo|amazon prime`).

### 6b) CategoryBudgetCard akıllı tavsiye (20 dk)

Seed limitler kaldırıldığı için, ilk kullanıcı her kategori için manuel limit girmek zorunda. UX iyileştirmesi: kategori için **geçmiş 30 gün harcamanın %110'u** önerilsin (input placeholder olarak).

Dosya: `lib/features/home/data/category_budget_store.dart` + UI tarafı.

### 6c) Unit testler (30 dk)

`test/` altında sadece `widget_test.dart` placeholder var. Şu fonksiyonlar için unit test eklenebilir (deterministik, side-effect yok):

- `FraudHeuristic.analyze()` — `lib/features/security/data/fraud_heuristic.dart`
- `AiCategorizer.heuristic()` — `lib/core/services/ai_categorizer.dart`
- `GoalAdvisor` — input/output testi
- `RecurringTransactionParser.detectSubscriptions()`

### 6d) iOS hazırlığı (büyük iş — ayrı gün)

- `pubspec.yaml`: `flutter_launcher_icons: ios: true`, `flutter_native_splash: ios: true`.
- iOS Firebase config: `GoogleService-Info.plist` ekle (Firebase Console → iOS app ekle → indir → `ios/Runner/`).
- Apple Developer sertifikası: sen halletmen lazım.

### 6e) Firebase Storage bucket (büyük iş — billing gerekir)

- Firebase Console → Project → Storage → "Get started" → Cloud Billing eklemek gerekiyor (free tier var ama kart kaydı şart).
- Bucket olmadan: çoklu cihaz sync, receipt image yedekleme, push notification production'da çalışmaz.
- Demo için kritik değil — README'de "P2 — partnership/billing gerekli" diye dürüst işaretle.

### 6f) Gemini API key rotate et (5 dk — DEMO SONRASI)

Mevcut key (`AIzaSy...nTU`) bir noktada sohbete yapıştırıldı, log'larda olabilir. Demo sonrası:
1. https://aistudio.google.com/apikey
2. Mevcut key → ⋮ → **Delete**
3. **Create API key** → yenisini al
4. `.env`'i yeni key'le güncelle (commit etme, gitignore'da).

---

# Sadece SEN yapabilirsin (AI yapamaz)

| İş | Neden ben yapamam |
| --- | --- |
| Firebase Console / Cloud Billing | Kredi kartı/hesap senin |
| iOS sertifikası | Apple Developer hesabı senin |
| Play Store / TestFlight upload | Hesaplar senin |
| GitHub credential prompt'u | İlk push'ta auth gerekirse sen yapacaksın |
| Gemini key rotate (demo sonrası) | Google hesabına giriş gerekir |

---

# Kritik dosya referansları (hızlı bağlanmak için)

```
lib/main.dart                                          — entry, Firebase bootstrap
lib/app.dart                                           — root widget, auth gating

lib/core/services/gemini_service.dart                  — Gemini tek giriş noktası
lib/core/services/ai_categorizer.dart                  — YENİ — heuristic + Gemini kategori
lib/core/config/env.dart                               — .env okuma
lib/core/localization/app_strings.dart                 — 6 dilli string'ler (2169 satır)

lib/features/home/data/home_feed_repository.dart       — sahte feed kaldırıldı
lib/features/home/data/upcoming_bill.dart              — model (DateTime + id)
lib/features/home/data/upcoming_bills_store.dart       — YENİ — CRUD + Firestore
lib/features/home/data/net_worth_history_store.dart    — YENİ — sparkline data
lib/features/home/data/goal_advisor.dart               — YENİ — Gemini ile aylık plan
lib/features/home/state/home_controller.dart           — banks + txns + history merge
lib/features/home/state/spending_insight_controller.dart — YENİ — Gemini insight
lib/features/home/state/upcoming_bills_controller.dart — YENİ
lib/features/home/presentation/widgets/add_bill_sheet.dart            — YENİ (TR hardcoded!)
lib/features/home/presentation/widgets/add_manual_transaction_sheet.dart — YENİ (TR hardcoded!)

lib/features/wealth/state/wealth_controller.dart       — addAllocation/remove + ağırlık
lib/features/wealth/presentation/widgets/add_holding_sheet.dart — YENİ (TR hardcoded!)

lib/features/security/data/fraud_heuristic.dart        — YENİ — outlier/round/burst
lib/features/security/state/security_controller.dart   — txn stream'e abone

lib/features/uma_chat/data/uma_repository.dart         — _buildUserContext() Gemini context
lib/features/auth/state/auth_controller.dart           — signOut tüm cache temizler

lib/features/receipt_scan/data/receipt_repository.dart — _fallback() düzeltilecek (Adım 1)
lib/features/statement_import/data/statement_repository.dart — _fallback() düzeltilecek (Adım 2)
```

---

# Bitiş kontrolü — her şey bittiğinde

```powershell
flutter analyze         # 0 issue olmalı
flutter test            # all passed olmalı
flutter build apk --debug --no-tree-shake-icons   # Built app-debug.apk olmalı
git status              # nothing to commit, working tree clean olmalı
git log -5              # son commitler düzgün gözükmeli
```

Hepsi yeşilse → demo'ya hazırız. ✅

---

# Devam komutu — bir AI ajana yaptırmak istersen

> Claude, `docs/YAPILACAKLAR.md` dosyasını oku. Gemini key + ilk commit/push hallolmuş durumda; Adım 1'den (Receipt OCR fallback) başla, sırayla 5'e kadar git, her adımı bitirince commit at, sonuçları bana özetle. Adım 3'te (lokalizasyon) çevirileri yaparken Gemini'dan toplu çeviri iste, EN'i önce sor.
