# Yapılacaklar — Vera Demo Hazırlığı

> **Durum (2026-05-18):** Demo öncesi kritik adımların hepsi tamamlandı.
> Sahte/mock veri sızıntısı yok (örnek hesap hariç — orası bilinçli);
> hardcoded locale sızıntıları temizlendi; ölü kod (`comingSoon`,
> `someKey`, `dart`, yanıltıcı yorumlar) kaldırıldı; signup ekranı 6
> dile çevrildi; Android release config Play Store yüklemeye hazır.
>
> Aşağıda kalan **opsiyonel** iyileştirmeler var — demo için kritik değil,
> vakit kalırsa P1 → P2 → P3 sırasıyla yap.

## Play Store yüklemesi için tek yapılması gereken

1. Upload keystore üret:
   ```powershell
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA `
     -keysize 2048 -validity 10000 -alias vera-upload
   ```
2. `android/key.properties` dosyasını oluştur (gitignore'da):
   ```
   storeFile=C:/path/to/upload-keystore.jks
   storePassword=...
   keyAlias=vera-upload
   keyPassword=...
   ```
3. `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`
4. Play Console → Internal testing track'e yükle.

`key.properties` yoksa release build debug key ile imzalanır (lokal test için
çalışır ama Play Store reddeder). Bu dosya hiçbir zaman commit edilmez.

## Demo hesabı

Login ekranında ayrı bir "demo" butonu **yok** — normal sign-in/sign-up
deneyimi. Demo'yu denemek için:

| Alan | Değer |
| --- | --- |
| E-posta | `a` |
| Şifre | `b` |

Bu credential'lar `login_screen.dart`'ta intercept ediliyor; Firebase'e
gitmiyor, doğrudan seed'li yerel hesabı aktive ediyor: 2 banka, 16 işlem
(Netflix×2 / Spotify×2 abonelik tespitini, 15.000 TL yuvarlak EFT fraud
heuristic'i tetikler), 3 fatura, kısmen biriken acil durum hedefi.
Onboarding atlanır, ana sayfa dolu açılır. Login ekranında bu
credential'lar bilgi kutusunda da gösteriliyor.

Diğer her e-posta/şifre kombinasyonu Firebase Auth'a gider — orada
kayıtlı gerçek hesap gerekir.

---

## Kalan opsiyonel işler

### P1 — Demo öncesi son rötuş (vakit varsa)

- [ ] Onboarding akışını gerçek telefonda baştan sona elle smoke test et
      (yeni hesap → 3 step → boş home).
- [ ] `.env`'deki Gemini key'i geçici olarak boz, fiş tarama + ekstre
      import'unu çalıştır → confirm butonu disabled + sarı uyarı görmeli.
- [ ] Empty-state kartlarının mobil/desktop spacing davranışını görsel
      olarak doğrula.

### P2 — Ürün hissi (post-demo)

- [ ] `GoalEditSheet` için daha güçlü ilk öneri akışı.
- [ ] `UmaInsightStrip` ve `ProactiveInsightCard` için küçük animasyon /
      stagger geçişleri.
- [ ] Connected accounts / subscriptions / wealth empty-state kartları
      arasında görsel dil birliğini artır.
- [ ] Goal kartında "örnek hedefler" / "hızlı preset" akışı (ev, araç,
      tatil gibi — ama preset olarak, default veri olarak değil).
- [ ] Subscription detection eşiğini düşürmek için bilinen vendor isim
      eşleştirme listesi (`netflix|spotify|youtube premium|disney|hbo|
      amazon prime`) — tek görünümde de tespit etsin.
- [ ] CategoryBudgetCard için akıllı limit önerisi: kategori için
      geçmiş 30 günlük harcamanın %110'u placeholder olarak.

### P3 — Teknik iyileştirme

- [ ] `app_strings.dart`'ı feature segmentlerine ayır
      (`app_strings_home.dart`, `app_strings_onboarding.dart`, …) —
      şu an 729 satır, kabul edilebilir ama büyüyor.
- [ ] Home CTA kararlarını ayrı helper/presenter katmanına taşı
      (`home_screen.dart` artık layout + karar yapıyor).
- [ ] Repo genelinde UTF-8 encoding hijyen taraması.
- [ ] Kullanılmayan string key taraması.
- [ ] Unit test ekle:
      - `FraudHeuristic.analyze()`
      - `AiCategorizer.heuristic()`
      - `GoalAdvisor` (deterministik output testi)
      - `RecurringTransactionParser.detectSubscriptions()`

### P3 — iOS / billing (büyük iş, ayrı sprint)

- [ ] iOS hazırlığı: `flutter_launcher_icons: ios: true`,
      `flutter_native_splash: ios: true`, `GoogleService-Info.plist`,
      Apple Developer sertifikası.
- [ ] Firebase Storage bucket (Cloud Billing gerekir) — receipt image
      yedeği, çoklu cihaz sync için.

---

## Sadece SEN yapabilirsin (AI yapamaz)

| İş | Neden |
| --- | --- |
| Firebase Console / Cloud Billing | Kredi kartı/hesap senin |
| iOS sertifikası | Apple Developer hesabı senin |
| Play Store / TestFlight upload | Hesaplar senin |
| Gemini API key rotate (demo sonrası) | Google hesabına giriş |

### Gemini key rotate (5 dk — DEMO SONRASI)

1. https://aistudio.google.com/apikey
2. Mevcut key → ⋮ → **Delete**
3. **Create API key** → yenisini al
4. `.env`'i yeni key'le güncelle (gitignore'da, commit olmaz).

---

## Bitiş kontrolü — demo öncesi son tarama

```powershell
flutter analyze         # 0 issue
flutter test            # all passed
flutter build apk --debug --no-tree-shake-icons
git status              # nothing to commit
```

Hepsi yeşilse → demo'ya hazır. ✅

---

## Kritik dosya referansları

```
lib/main.dart                                          — entry, Firebase bootstrap
lib/app.dart                                           — root widget, auth gating

lib/core/services/gemini_service.dart                  — Gemini tek giriş noktası
lib/core/services/ai_categorizer.dart                  — heuristic + Gemini kategori
lib/core/config/env.dart                               — .env okuma
lib/core/localization/app_strings.dart                 — 6 dilli string getter'ları
lib/core/localization/features/{tr,en,de,ar,ru,zh}.dart — feature başına dil dosyaları

lib/features/home/data/home_feed_repository.dart       — sahte feed kaldırıldı
lib/features/home/data/upcoming_bill.dart              — model (DateTime + id)
lib/features/home/data/upcoming_bills_store.dart       — CRUD + Firestore
lib/features/home/data/net_worth_history_store.dart    — sparkline data
lib/features/home/data/goal_advisor.dart               — Gemini ile aylık plan (l10n)
lib/features/home/state/home_controller.dart           — banks + txns + history merge
lib/features/home/state/spending_insight_controller.dart — Gemini insight
lib/features/home/state/upcoming_bills_controller.dart
lib/features/home/presentation/widgets/home_first_steps_card.dart — ilk kullanım CTA
lib/features/home/presentation/widgets/add_bill_sheet.dart
lib/features/home/presentation/widgets/add_manual_transaction_sheet.dart

lib/features/wealth/state/wealth_controller.dart       — l10n-aware insight
lib/features/wealth/data/wealth_repository.dart        — insightFor(l10n)
lib/features/wealth/presentation/widgets/add_holding_sheet.dart

lib/features/security/data/fraud_heuristic.dart        — outlier/round/burst
lib/features/security/state/security_controller.dart   — txn stream'e abone

lib/features/uma_chat/data/uma_repository.dart         — _buildUserContext()
lib/features/auth/state/auth_controller.dart           — signOut tüm cache temizler

lib/features/receipt_scan/data/receipt_repository.dart — fallback boş döner
lib/features/statement_import/data/statement_repository.dart — fallback boş döner
```
