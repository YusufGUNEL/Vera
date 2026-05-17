# Sürüm Geçmişi

Hackathon prototipi olduğu için semantic versioning yerine commit bazlı kronoloji tutuyoruz. Detay için `git log` yeter, bu dosya **her commit'te neyin değiştiğini ürün açısından** özetler.

---

## 2026-05-17 — Mock veriyi tamamen sil + AI özelliklerini kullanıcı verisine bağla

**Notu:** İki aşamada büyük dönüşüm. (1) Demo amaçlı tüm hardcoded seed veriler kaldırıldı, uygulama boş başlar. (2) Üzerine, kullanıcının gerçek verisi üzerinde çalışan AI özellikleri eklendi.

### 🗑 Silinenler (mock seed'ler)

- `kBanks` (Garanti/Akbank/İş Bank/Ziraat hardcoded bakiyeler) → `const kBanks = <Bank>[]`
- `kTransactions` (Migros/Aksoy/Netflix vb. 6 sahte işlem) → boş liste
- `kSecurityChecks` (5 sahte fraud event) → boş liste
- `kUpcomingBills` (3 sahte fatura) → kullanıcı yönetir
- `FinancialGoal.seed` (50k hedef, 38k saved) → `FinancialGoal.empty` (sıfırlar)
- `WealthRepository.portfolio()` / `actions()` (hardcoded 167k hisse, 3 "Uma X yaptı" eylemi) → boş
- `SubscriptionsRepository.getSubscriptions()` 4 hardcoded plan → sadece kullanıcı işlemlerinden tespit
- `home_feed_repository.refresh()` "Yemeksepeti / Martı" fabrikasyon → empty feed
- `security_feed_repository.refresh()` rastgele üretilen fraud mock'ları → empty feed
- `CreditController` default 150k/36ay/48.5k → 0/12ay/0/0
- `category_budget_store._seed` (Market 4k, Yeme 1.5k vb.) → kullanıcı her limiti kendi girer
- `FirebaseWealthService` / `FirebaseSubscriptionsService` `_seedX` çağrıları (Firestore'a sahte seed yazmayı bırakır)
- `docs/FEATURES.md` (201 satır, bayatlamış, README ile çakışıyordu)

### ✨ Eklenenler — Kullanıcı verisi akışları

- **`UpcomingBill`** modeli `DateTime dueDate + id` ile; `UpcomingBillsStore` + `FirebaseUpcomingBillsService` + `UpcomingBillsController`.
- **`AddBillSheet`** — yeni/edit fatura: ad, tutar, son ödeme tarihi (date picker), 7 kategori chip'i.
- **`AddManualTransactionSheet`** — manuel işlem girişi: Gider/Gelir segment, ad, tutar, tarih, 11 kategori.
- **`AddHoldingSheet`** — manuel portföy varlığı: 6 bucket (Hisse/Altın/Nakit/Kripto/Fon/Tahvil); `WealthController.addAllocation` otomatik ağırlık hesabı.
- **Empty-state CTA'lar:** Home (Manuel/Fiş/Ekstre), Faturalar, Wealth, Subscriptions, Security — hepsinde boş durumda CTA.
- **`AuthController.signOut()`** artık `_clearLocalCaches()` çağırır: tüm local store'lar silinir.

### ✨ Eklenenler — AI özellikleri (kullanıcı verisi üzerinde)

- **Context-aware Uma chat** — Gemini prompt'una kullanıcının gerçek bankaları, son 15 işlemi, faturaları, hedefleri, abonelikleri, portföyü JSON snapshot olarak veriliyor. "Ne kadar param var?", "Geçen ay en çok ne harcadım?" gerçek cevap verir.
- **`AiCategorizer`** (`lib/core/services/ai_categorizer.dart`) — manuel işlem girişinde kategori önerisi; önce 15+ Türk marka heuristic'i, sonra Gemini fallback. Sheet'te "Uma önerisi: X · Kabul et" chip.
- **`SpendingInsightController`** — Home insight strip artık gerçek harcama özetinden hesaplanır; Gemini varsa daha zengin yorum arka planda swap edilir.
- **`NetWorthHistoryStore`** — günlük bakiye snapshot (60 nokta rolling); NetWorthCard'da sparkline.
- **`GoalAdvisor`** — hedef belirleyince 3/6/12/18/24 ay seçimi; aylık gereken tutar + Gemini ile "şu kategoriden kıs" tavsiyesi.
- **`FraudHeuristic`** — import edilen işlemleri analiz eder: outlier (median × 3+), yuvarlak büyük transfer (10k+), aynı gün burst (3+). Security feed'e push.
- **Wealth holding kaldırma** — donut altındaki varlığa tap → "Bu varlığı kaldır" sheet'i.

### 🔁 Değişenler

- **`BillRemindersScheduler`** sahte `kUpcomingBills` yerine `UpcomingBillsController`'a abone; locale + bills değişince re-schedule.
- **`SecurityController`** transaction stream'ine abone; her import sonrası `FraudHeuristic` çalışır.
- **`SubscriptionsRepository`** sadece user txns üzerinden tespit yapar.
- **`WealthController._recomputeWeights()`** — eklenen her holding'de ağırlıklar yeniden hesaplanır; `ytdPercent` baseline 12% kaldırıldı.

### 🎯 Sonuç

Uygulama dürüst bir **boş tuval** olarak başlar. Kullanıcı veri ekledikçe AI katmanları (Gemini insight, AI categorizer, goal advisor, fraud heuristic, Uma chat) **gerçek veri üzerinde** çalışır. `flutter analyze` temiz, debug APK build başarılı.

---

## 2026-05-16 — Firebase auth + cloud sync

**Notu:** Firebase Core/Auth/Firestore/Storage/Messaging/Analytics/Crashlytics/Remote Config tam entegre. Bütün store'lar local-first + Firestore senkron (key girilirse aktif).

### ✨ Eklenenler

- `lib/core/firebase/` — bootstrap, analytics, fcm, remote config service.
- `lib/features/auth/data/firebase_auth_service.dart` — e-posta sign-in/sign-up; `currentSession` getter; sign-out cloud + local.
- Firestore servisleri: banks, importedTransactions, importArtifacts, subscriptions, wealth, profile, uma audit/feedback.
- `.firebaserc`, `firebase.json`, `firestore.rules`, `storage.rules`.

### 🔁 Değişenler

- Tüm `BanksStore`, `ImportedTransactionsStore`, `SubscriptionsController`, `WealthController` → Firebase servisini watch eder.
- `main.dart` — `FirebaseBootstrap.ensureInitialized()` + Crashlytics handler.

> **Blocker:** Firebase Storage bucket setup, billing eklenmediği için yarım. Bkz. `docs/FIREBASE_SETUP.md`.

---

## Format kuralı

Her yeni commit için bu dosyaya bir başlık ekle:

```markdown
## YYYY-MM-DD — Kısa başlık

### ✨ Eklenenler
- ...

### 🔁 Değişenler
- ...

### 🗑 Silinenler
- ...

### ⚠ Breaking
- ...
```
