# Sürüm Geçmişi

Hackathon prototipi olduğu için semantic versioning yerine commit bazlı kronoloji tutuyoruz. Detay için `git log` yeter, bu dosya **her commit'te neyin değiştiğini ürün açısından** özetler.

---

## 2026-05-16 — FEATURES.md cleanup: yapılamayanları sil (round 3)

**Notu:** "Vera bunu yapacak" izlenimi veren ama lisans / partnership / scope dışı olduğu için yapılamayacak maddeler doc'tan silindi. Geriye kalan: gerçekten çalışan + gerçekten yapılabilir olanlar.

### 🗑 Silinenler (FEATURES.md'den)

- **⚠ Kısmi liste tamamen kaldırıldı** — içindeki yapısal sınır maddeleri (home feed mock, security feed katalogu, wealth allocations, database, login design choice, deep-link web limit, push FCM, gemini key) ya gerçeği zaten çalıştığı için ✅'a taşındı, ya da "yapılacak" listesinden çıkarıldı.
- **🔜 P2 partnership/lisans maddeleri:** Lisanslı AISP partnership, Vera Card (white-label), Yatırım partneri (SPK).
- **🔜 P3 vision tamamen:** Vera kendi AISP lisansını alır, Direkt banka API'lerine entegrasyon, B2B Vera for SMEs, Vera Coach yıllık plan (LLM scope dışı).
- **🔜 P1 duplikeler:** "Tekrarlayan ödeme akıllı tespiti" (zaten yapıldı), "Local notifications fraud" (zaten yapıldı).
- **Vera Pro abonelik / Vera Family** — business model maddeleri; ürün özellikleri değil, silindi.

### 🔁 Değişenler

- ⚠ kategorisi yerine **iki kategori:** ✅ çalışıyor, 🔜 yapılacak (hackathon scope'unda gerçekçi).
- Kalan 🔜 maddeleri P0 (6) + P1 (9) — hepsi lisans/partnership olmadan implement edilebilir.
- Lisans matrisi → "positioning" başlığı altında küçültüldü; ❌ olan satırlar (AISP/PSP/SPK gerektirenler) tek paragraf olarak özetlendi (jüri için pozisyonu net tutar ama "yapacağız" izlenimi vermez).

### 🎯 Sonuç

Doc artık iki şey söylüyor: **(1) Bugün şu şu çalışıyor**, **(2) Yarın şu şu eklenebilir.** "Bir gün lisanslı olunca yapılır" türü romantik vaadler yok.

---

## 2026-05-16 — FEATURES.md ⚠ listesini gerçeğe çevirme (round 2)

**Notu:** "Kısmi / mock" listesindeki maddelerin yapılabilir olanları gerçek koda dönüştürüldü; yapılamayanlar (banka API, real-time balance, ML fraud) için ürün dilini dürüstleştirdik.

### ✨ Eklenenler

- **"Banka ekle" sheet** (`lib/features/home/presentation/widgets/add_bank_sheet.dart`) — kullanıcı banka ekler, `BanksStore` SharedPreferences'a persist; ad / son 4 hane / bakiye / 8 renk swatch.
- **`HomeController.addBank` / `removeCustomBank`** — feed banks + user banks birleşik; toplam bakiye otomatik.
- **Fraud → Local notification** — `SecurityController` yeni blocked event'lerde `NotificationService.showFraudAlert` fırlatır; bootstrap seed'leri için duplicate atmaz; tap → `/security`.
- **Profile account tile sheet'leri** (`AccountInfoSheet` widget) — Personal info / Email / Security / Storage / Help tile'ları artık tıklanabilir, generic 3-bölümlü info sheet açar.
- **Help & support FAQ** — 3 soru (banka bağlantısı / veri saklama / Gemini key yok) + iletişim bilgisi.
- **Subscription detection** — `RecurringTransactionParser.detectSubscriptions(List<Txn>)` import edilen transaction'larda 14 bilinen vendor (Netflix/Spotify/YouTube/iCloud/Apple/Amazon/Disney/Exxen/BluTV/Gain/tabii/GitHub/OpenAI/Anthropic) match'i + 2+ tekrarlı işlem tespiti yapar; seed listesine eklenir.
- **`SubscriptionsController` reactive** — `homeControllerProvider` değiştiğinde otomatik refresh.
- **L10n key'leri** (6 dil): `addBankTitle/Subtitle/Name/Last4/Balance/Color/Save/NameRequired/bankAdded`, `infoDisplayName/Member/MemberDescription/EmailLabel/EmailUsage/EmailDescription/SessionVault/SessionVaultDescription/FaceId/FaceIdOn/FaceIdOff/FraudAlerts/FraudAlertsOn/FraudAlertsOff/SyncMode/LocalData/LocalDataDescription`, `helpFaqQ1/A1/Q2/A2/Q3/A3/helpContact`.

### 🔁 Değişenler

- `_AccountTile` artık `onTap` callback alır; eski no-op `onTap: () {}` kaldırıldı.
- `SubscriptionsRepository.getSubscriptions({userTxns})` artık parametre alır, detected items'ı seed'e ekler (vendor bazlı dedupe).
- `RecurringTransactionParser` keyword listesi 4'ten 14 vendor'a genişletildi.
- `HomeController` constructor üç argüman yerine `BanksStore` dahil dört argüman alır.

### 🗑 Silinenler

- UMA chat'teki sahte mic ikonu (`Icons.mic_none_rounded`) — STT bağlı olmadığı için yanıltıcıydı; `_Input.onUseMicHint` callback'i ve placeholder snackbar kaldırıldı.

### 📝 Docs

- `FEATURES.md` "⚠ Kısmi / mock veri" listesi 14 maddeden 10'a indi; kalan maddeler **yapısal sınır** (banka API'si lisans gerektiriyor, ML fraud out of scope) olarak dürüstçe belgelendi.
- Yeni "Profile / Account tiles (gerçek detail sheet'leri)", "Banka yönetimi", "Fraud → Local notification" bölümleri "Tam çalışan özellikler" altında.

---

## 2026-05-16 — Receipt + Statement → Transactions gerçek wire

**Notu:** OCR ve PDF ekstre import sonuçları artık snackbar yerine **gerçekten** home transaction listesine yazılıyor ve app restart'larında korunuyor.

### ✨ Eklenenler

- **`lib/features/home/data/imported_transactions_store.dart`** — SharedPreferences ile persist; `ParsedReceipt.toTxn()` ve `ParsedStatement.toTxns()` extension'ları; kategori → (ikon, renk) helper'ı.
- **`HomeController.addImportedTransactions(List<Txn>)`** — yeni işlemleri prepend eder, feed verisi yenilense bile import edilen işlemler en üstte kalır.
- **L10n key'leri** (6 dil): `scanNoTotal`, `statementNoTransactions`.

### 🔁 Değişenler

- Receipt scan sheet "İşlemlerime ekle" CTA'sı: snackbar gösterip kapanmak yerine gerçek `Txn` üretip controller'a yazar; sonra snackbar.
- Statement import sheet "Vera'ya aktar" CTA'sı: 20 işleme kadar tüm transaction'lar home listesine eklenir.
- `HomeController` — `ImportedTransactionsStore`'u bootstrap'ta yükler, feed refresh'lerinde import edilen listeyi korur.

---

## 2026-05-16 — Merge: receipt scan, statement import, lokalizasyon, web target

**Upstream commit:** `9dccb5c`
**Notu:** Yerel iki paralel iş kolunun manuel merge'i. Çakışmalar elle çözüldü; lokalizasyon olarak `core/localization/` (upstream, 1116 satır, 6 dil) seçildi.

### ✨ Eklenenler

- **Receipt OCR feature** (`lib/features/receipt_scan/`) — domain / data / state / presentation tam yapı; `image_picker` ile kamera + galeri; Gemini multimodal parse; fallback mock fişi.
- **PDF/Excel ekstre import** (`lib/features/statement_import/`) — `file_picker` ile dosya seçimi; Gemini multimodal parser; Garanti BBVA mock ekstre fallback.
- **6 dilli i18n + RTL** (`lib/core/localization/`) — TR/EN/DE/AR/RU/ZH; `context.l10n` extension; `stringsProvider`; SharedPreferences ile kalıcı; AR seçildiğinde otomatik RTL.
- **Web hedefi** (`web/`) — favicon, icons, manifest, index.html.
- **Yeni home widget'ları** — `SavingsStoryCard`, `UpcomingBillsStrip`, `CreditSummaryCard`.
- **Yeni dokümanlar** — `docs/FEATURES.md`, `docs/DEMO_SCRIPT.md`, `docs/ICON_SPLASH_PROMPT.md`.
- **Local notification + branding** (yerelden) — `flutter_local_notifications`, `flutter_launcher_icons`, `flutter_native_splash`; `assets/branding/`; Android night/v31/xml kaynakları.
- **Auth genişlemesi** (yerelden) — `signup_screen.dart`, `AuthField` widget.
- **NotificationService** (yerelden) — fraud alert için local notification + tap routing.

### 🔁 Değişenler

- `pubspec.yaml` — `image_picker`, `file_picker`, `url_launcher`, `flutter_local_notifications`, `timezone`, `flutter_launcher_icons`, `flutter_native_splash` eklendi; `flutter_localizations` upstream'den geldi.
- `CreditDecision.bandLabel` ve `SubscriptionStatus.label` getter'ları eklendi (upstream UI bunları çağırıyordu, yerel modeller bunları taşımıyordu).
- `app_router.dart` — `/signup` route'u + `NotificationService.onTap` listener.

### 🗑 Manuel merge sonucu silinen (yerel-tek, upstream'e wire edilmemiş)

Aşağıdaki widget'lar yerel branch'te vardı ama merge sonrası ekranlara bağlı kalmadı (upstream'in `top_bar`/`transaction_list` versiyonu farklı bir akış kullanıyor). Yeniden eklenmek istenirse `git reflog` üzerinden bulunabilir:

- `lib/features/home/presentation/widgets/notifications_sheet.dart` — bildirim listesi sheet'i (snackbar yerine)
- `lib/features/home/presentation/widgets/transaction_detail_sheet.dart` — işleme tap edince detay sheet
- `lib/features/home/presentation/widgets/bank_detail_sheet.dart` — banka kartına tap edince detay
- `lib/features/home/presentation/widgets/credit_health_card.dart` — credit summary'nin alternatif sunumu
- `lib/features/wealth/presentation/widgets/policy_edit_sheet.dart` — wealth policy düzenleme sheet'i
- `lib/shared/utils/open_uma.dart` — Uma chat'i prompt'la açan helper
- `lib/core/l10n/` — alternatif lokalizasyon altyapısı (upstream'in `core/localization/` ile çakışıyordu)

> Bunlar tek tek yeniden gerekiyorsa: upstream API'sine adapte ederek geri eklemek gerekir (`s.foo` → `context.l10n.foo`).

---

## 2026-XX-XX — `754188c` Harden auth storage and expand profile hub

**Author:** Casper

Auth saklama güçlendirildi, profile hub genişledi.

---

## 2026-XX-XX — `593b5ea` Build auth, live data, and AI finance flows

**Author:** Casper

Auth, canlı veri ve AI finans akışları kuruldu.

---

## 2026-XX-XX — `38fa834` Initial commit

**Author:** Yusuf GÜNEL

Gemini destekli Uma asistanıyla Vera mobil bankacılık iskeleti.

---

## Format kuralı

Her yeni commit için bu dosyaya bir başlık ekle:

```markdown
## YYYY-MM-DD — `<hash>` Kısa başlık

### ✨ Eklenenler
- ...

### 🔁 Değişenler
- ...

### 🗑 Silinenler
- ...

### ⚠ Breaking
- ...
```

Geliştirme hızlı olduğu için her küçük commit'i listelemek yerine **kullanıcıya görünen / mimari etki yaratan** değişiklikleri öne çıkar.
