# Firebase Setup

Vera'nın Firebase tarafındaki bağlantı durumu, env anahtarları, eksikler ve
doğrulama adımları tek yerde.

---

## 1. Proje bilgileri

| Alan | Değer |
| --- | --- |
| Project id | `vera-ai-finance` |
| Firestore region | `eur3` (default db) |
| Storage bucket | `vera-ai-finance.firebasestorage.app` |
| Android package | `com.vera.vera` |

Uygulama **local-first** çalışır — Firebase kapalıysa demo akışları bozulmaz.
Açıldığında ilgili store'lar local + cloud veriyi merge eder.

---

## 2. Koda bağlı olan servisler

| Alan | Dosya |
| --- | --- |
| Bootstrap, App Check, Crashlytics hook | `lib/core/firebase/firebase_bootstrap.dart` |
| Auth (email sign-up / sign-in / sign-out) | `lib/features/auth/data/firebase_auth_service.dart` |
| Banks | `lib/features/home/data/firebase_banks_service.dart` |
| Imported transactions | `lib/features/home/data/firebase_imported_transactions_service.dart` |
| Import artifact metadata | `lib/features/home/data/firebase_import_artifacts_service.dart` |
| Upcoming bills | `lib/features/home/data/firebase_upcoming_bills_service.dart` |
| Subscriptions | `lib/features/subscriptions/data/firebase_subscriptions_service.dart` |
| Wealth (portfolio + policy) | `lib/features/wealth/data/firebase_wealth_service.dart` |
| Profile / preferences | `lib/features/profile_settings/data/firebase_profile_service.dart` |
| Uma audit + feedback | `lib/features/uma_chat/data/firebase_uma_*` |
| Analytics / FCM / Remote Config | `lib/core/firebase/{analytics,fcm,remote_config}_service.dart` |

App Check: debug'ta `AndroidProvider.debug`, prod'da `playIntegrity`.
Crashlytics: `!kDebugMode && bootstrap.ready` koşulunda devreye girer.

---

## 3. Firestore yapısı

```text
users/{uid}
users/{uid}/banks
users/{uid}/importedTransactions
users/{uid}/importArtifacts
users/{uid}/upcomingBills
users/{uid}/subscriptions
users/{uid}/wealthData/current
users/{uid}/wealthActions
users/{uid}/private/settings
users/{uid}/umaAudit
users/{uid}/umaFeedback
```

Kesin kaynak: ilgili `firebase_*_service.dart` dosyaları.

---

## 4. Env anahtarları

`.env` (gitignore'da) — örnek için `.env.example`:

```
FIREBASE_API_KEY=...
FIREBASE_APP_ID_ANDROID=...
FIREBASE_APP_ID_WEB=...
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_PROJECT_ID=vera-ai-finance
FIREBASE_STORAGE_BUCKET=vera-ai-finance.firebasestorage.app
FIREBASE_AUTH_DOMAIN=...
FIREBASE_MEASUREMENT_ID=...
GEMINI_API_KEY=...
```

Bootstrap için **minimum**: `FIREBASE_API_KEY`, `FIREBASE_MESSAGING_SENDER_ID`,
`FIREBASE_PROJECT_ID`. Eksikse bootstrap `enabled: false` döner, local-first
devam eder.

Android'de `lib/firebase_options.dart` zaten var → env fallback olmadan da
çalışır. Web'de env'den okunur.

---

## 5. Açık blocker — Storage

- Kod tarafında upload akışı hazır (receipt/statement orijinal dosya)
- `storage.rules` repo'da
- Console'da Storage bucket setup **billing gerektiriyor**, henüz tamam değil

Etkilenen:
- receipt görselinin cloud yedeği
- statement PDF'inin cloud yedeği
- artifact metadata ↔ binary eşleşmesi

Metadata Firestore'a yazılmaya devam eder; sadece binary upload eksik.

---

## 6. Console'da yapılacaklar

### Storage bucket
1. `https://console.firebase.google.com/project/vera-ai-finance/storage`
2. **Get Started** → lokasyon `europe-west1`
3. Cloud Billing zorunlu → billing hesabı bağla

### Auth
- Authentication → Sign-in method → **Email/Password** açık olmalı

### Firestore
- `(default)` database `eur3` altında ayakta olmalı
- `firestore.rules` deploy edilmiş olmalı (`firebase deploy --only firestore:rules`)

---

## 7. Doğrulama checklist

```text
[ ] Email ile sign-up → sign-out → sign-in döngüsü çalışıyor
[ ] Custom bank ekle → reload → bank duruyor (local + cloud)
[ ] Profile tercih değiştir → reload → korunuyor
[ ] Receipt scan → Firestore'da `importedTransactions` + `importArtifacts` dolu
[ ] (Storage açıksa) `users/{uid}/imports/...` altında binary var
[ ] Analytics dashboard'da login/signup/uma_intent event akıyor
[ ] Remote Config'ten Gemini model adı okunuyor
```

Repo'daki konfig dosyaları: `firebase.json`, `firestore.rules`,
`storage.rules`, `.firebaserc`, `lib/firebase_options.dart`.
