# Yapılacaklar — Vera Demo Hazırlığı

> **Durum (2026-05-19):** Telefonda elle test edildikten sonra çıkan
> bulgular düzeltildi: sahte para işlemi butonları kaldırıldı (NetWorth
> quick actions, Uma intent OrderCard'ları), sahte kredi puanı/gauge
> ekranı yerine gerçek aylık-ödeme kalkülatörü kondu, Uma feedback bar
> kaldırıldı, audit log + güvenlik heuristic mesajları + bulut sync
> bilgisi l10n'a alındı, signup invisible-text/back-button/wording
> düzeltildi, ana sayfadan UmaInsightStrip kaldırıldı. 6 dilin tamamı
> 546 anahtarla parity'de.
>
> **Yarın yapılacak tek kritik iş: aşağıdaki "Hemen önce" bölümü
> (Google Sign-In SHA-1).** Geri kalanlar opsiyonel iyileştirme.

## Hemen önce yap (yarın başlarken — kritik)

### Google Sign-In çalışmıyor: Firebase Console'a SHA-1 ekle

`PlatformException(sign_in_failed, ...)` — `google-services.json`'da
`oauth_client: []` boş, yani Firebase Console'da Android uygulamasına
SHA-1 fingerprint kayıtlı değil. Kodla çözülmez.

1. https://console.firebase.google.com/project/vera-ai-finance/settings/general
2. **Your apps** → Android (`com.vera.vera`) → **Add fingerprint**
3. Bu debug SHA-1'i yapıştır → **Save**:
   ```
   9C:22:FD:B8:47:10:A1:87:39:6E:67:AD:58:77:E3:36:B6:85:14:7D
   ```
   (Play App Signing açıksa SHA-256 da gerekecek:
   `25:4C:41:C6:E5:8D:DC:E2:C7:8D:C7:94:F5:7A:29:E8:7A:CA:B4:B9:36:83:74:23:6F:4B:40:A0:59:35:20:78`)
4. Aynı sayfadan **`google-services.json`**'u yeniden indir →
   `android/app/google-services.json` üzerine yaz.
5. `flutter build apk --release --no-tree-shake-icons` → telefona kur.
6. Test: Login veya signup ekranında "Google ile devam et" → Google
   hesap seçici açılmalı, ardından home'a düşmelisin. Eğer hâlâ
   `sign_in_failed` görüyorsan UI artık "Firebase Console'a SHA-1
   eklenmemiş olabilir" diye uyarıyor (l10n.googleSignInConfigMissing).

### Telefonda smoke test (yeni APK kurulduktan sonra)

- [ ] Signup ekranı: input box'lardaki yazılar görünüyor mu? (defansif
      `Theme.of(...).textTheme.bodyLarge` ile düzelttik, ama gerçek
      cihaz doğrulaması yapılmadı.)
- [ ] Signup ekranı: sol üst geri butonu login'e dönüyor mu?
      (`context.push` + `canPop` fallback).
- [ ] Signup ekranı: birincil buton metni "Kayıt ol" (eskisi "Firebase
      hesabı oluştur"du).
- [ ] Kredi sayfası: geri butonu var, sahte 850 puanlık gauge yok,
      sadece slider-tabanlı kalkülatör + disclaimer.
- [ ] Uma sohbet: mesajların altında "Yardımcı oldu / Geliştirilmeli /
      Not ekle" satırı YOK.
- [ ] Uma sohbet → ⚙ → audit log: başlık + alt metin + boş-durum metni
      seçili dilde (TR'de Türkçe, EN'de İngilizce vs.).
- [ ] Net Worth kartı: "Gönder / İste / Yükle / Öde" quick action
      butonları YOK.
- [ ] Ana sayfa: "UMA İÇGÖRÜ" stripi YOK.
- [ ] Subscriptions: ödeme/freeze chip'leri YOK (sadece bilgi).

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
- [ ] `ProactiveInsightCard` için küçük animasyon / stagger geçişleri.
      (`UmaInsightStrip` kaldırıldı.)
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
- [ ] Uma feedback storage altyapısı (UI kaldırıldı) — `firebase_uma_feedback_store.dart`,
      `uma_feedback_store.dart`, `uma_feedback.dart`, repository'deki
      `saveFeedback/loadFeedback` ölü kalıyor. Eski veriler için
      okuma korunuyor, yazılım yok. Tamamen silmek için ayrı bir
      sprint gerekir (Firestore koleksiyonu da temizlenmeli).
- [ ] Kredi simülatöründeki faiz çarpanı (`1.16 + months/100`) gerçek
      TR banka oranlarıyla doğrulanmadı — disclaimer veriyoruz ama
      ileride bir referans rakam (TCMB ortalama) bağlanabilir.
- [ ] Unit test ekle:
      - `FraudHeuristic.analyze()` (l10n parametresi de testlenmeli)
      - `AiCategorizer.heuristic()`
      - `GoalAdvisor` (deterministik output testi)
      - `RecurringTransactionParser.detectSubscriptions()`
      - `CreditRuleEngine.evaluate()` (monthlyPayment / paymentLoad / dti)

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
| Firebase Console — SHA-1 fingerprint ekle | Google Sign-In çalışması için (yukarıdaki "Hemen önce" bölümü) |
| Firebase Console / Cloud Billing | Kredi kartı/hesap senin |
| iOS sertifikası | Apple Developer hesabı senin |
| Play Store / TestFlight upload | Hesaplar senin |
| Gemini API key rotate (demo sonrası) | Google hesabına giriş |
| Telefonda yeni APK ile elle smoke test | Cihaz senin |

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
