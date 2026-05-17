# Firebase Setup

> Son güncelleme: 2026-05-17
> Amaç: Vera içindeki Firebase bağlantısının mevcut durumunu, eksikleri ve doğrulama adımlarını tek yerde toplamak

---

## 1. Proje bilgileri

- Firebase project id: `vera-ai-finance`
- Firestore database: `(default)` / region `eur3`
- Android package: `com.vera.vera`
- `firebase_options.dart` içinde görünen varsayılan storage bucket adı:
  - `vera-ai-finance.firebasestorage.app`

Not:

- Kod tarafında Firebase bootstrap hazır
- Uygulama local-first çalışacak şekilde tasarlandığı için Firebase kapalı olsa bile demo temel akışları bozulmuyor
- Firebase aktif olduğunda ilgili store’lar local veri ile cloud veriyi birleştiriyor

---

## 2. Kod tarafında zaten bağlı olan servisler

### 2.1 Bootstrap ve çekirdek

İlgili dosyalar:

- [firebase_bootstrap.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/core/firebase/firebase_bootstrap.dart)
- [main.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/main.dart)
- [env.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/core/config/env.dart)

Hazır olanlar:

- `Firebase.initializeApp`
- `Firebase App Check`
  - debug: `AndroidProvider.debug`
  - production: `AndroidProvider.playIntegrity`
- eager init:
  - Remote Config
  - FCM service
  - Analytics service
- Crashlytics hook
  - bootstrap hazırsa ve debug dışındaysa aktif

### 2.2 Auth

İlgili dosya:

- [firebase_auth_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/auth/data/firebase_auth_service.dart)

Hazır olanlar:

- email sign-up
- email sign-in
- sign-out
- session getter

Auth state bunu kullanıyor:

- [auth_controller.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/auth/state/auth_controller.dart)

### 2.3 Firestore tabanlı veri servisleri

Kodda cloud sync’e bağlanmış ana alanlar:

- banks
  - [firebase_banks_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/home/data/firebase_banks_service.dart)
- imported transactions
  - [firebase_imported_transactions_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/home/data/firebase_imported_transactions_service.dart)
- import artifacts metadata
  - [firebase_import_artifacts_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/home/data/firebase_import_artifacts_service.dart)
- upcoming bills
  - [firebase_upcoming_bills_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/home/data/firebase_upcoming_bills_service.dart)
- subscriptions
  - [firebase_subscriptions_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/subscriptions/data/firebase_subscriptions_service.dart)
- wealth
  - [firebase_wealth_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/wealth/data/firebase_wealth_service.dart)
- profile/preferences
  - [firebase_profile_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/profile_settings/data/firebase_profile_service.dart)
- Uma audit / feedback
  - [firebase_uma_audit_store.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/uma_chat/data/firebase_uma_audit_store.dart)
  - [firebase_uma_feedback_store.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/features/uma_chat/data/firebase_uma_feedback_store.dart)

### 2.4 Analytics / Messaging / Remote Config

İlgili dosyalar:

- [analytics_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/core/firebase/analytics_service.dart)
- [fcm_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/core/firebase/fcm_service.dart)
- [remote_config_service.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/core/firebase/remote_config_service.dart)

Hazır olanlar:

- login / signup / Uma intent analytics event akışı
- FCM token kayıt akışı için temel servis
- Remote Config üzerinden Gemini model adı okuma

---

## 3. Beklenen Firestore alanları

Kodun aktif olarak yazdığı/okuduğu alanlar kabaca şu yapıya oturuyor:

```text
users/{uid}
users/{uid}/banks
users/{uid}/importedTransactions
users/{uid}/importArtifacts
users/{uid}/upcomingBills
users/{uid}/subscriptions
users/{uid}/wealth
users/{uid}/private/settings
users/{uid}/umaAudit
users/{uid}/umaFeedback
```

Not:

- bazı koleksiyon adları servis implementasyonuna göre biraz farklı namespace kullanabilir
- kesin kaynak, ilgili `firebase_*_service.dart` dosyalarıdır

---

## 4. Env tarafında beklenen anahtarlar

`Env` sınıfına göre Firebase için beklenen anahtarlar:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID_ANDROID`
- `FIREBASE_APP_ID_WEB`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_MEASUREMENT_ID`

Bootstrap için kritik minimum set:

- `FIREBASE_API_KEY`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`

Not:

- Android tarafında `firebase_options.dart` varsa env fallback her zaman şart değil
- Web tarafında env üzerinden de config okunabiliyor
- Firebase core config eksikse bootstrap `enabled: false` döner ve uygulama local-first devam eder

---

## 5. Şu anki gerçek blocker

Ana blocker hâlâ `Firebase Storage` tarafı.

Durum:

- kod tarafında artifact upload akışı hazır
- Storage rules dosyası hazır:
  - [storage.rules](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/storage.rules:1)
- ancak projede bucket setup tamamlanmamışsa gerçek dosya upload kullanılamaz

Etkilenen akışlar:

- receipt scan sonrası orijinal görselin cloud’a alınması
- statement import sonrası orijinal PDF/görselin cloud’a alınması
- import artifact metadata ile gerçek dosya nesnesinin eşleşmesi

Bu blocker yoksa çalışan taraf:

- metadata Firestore tarafına yazılabilir
- local-first akış bozulmaz
- ama gerçek binary upload / cleanup eksik kalır

---

## 6. Firebase Console tarafında yapılacaklar

### 6.1 Storage bucket kurulumu

1. Firebase Console aç:
   - `https://console.firebase.google.com/project/vera-ai-finance/storage`
2. `Get Started` tıkla
3. Avrupa lokasyonu seç:
   - örn. `europe-west1`
4. Billing zorunluysa billing account bağla
5. Bucket oluştuktan sonra Storage ekranı erişilebilir hale gelmeli

### 6.2 Auth kontrolü

1. Firebase Console > Authentication > Sign-in method
2. `Email/Password` aktif mi kontrol et
3. Gerekirse enable et

### 6.3 Firestore kontrolü

1. Firestore database açık mı kontrol et
2. `(default)` database `eur3` altında ayakta mı doğrula
3. Rules deploy edilmiş mi bak

### 6.4 App Check

Debug geliştirmede:

- uygulama `AndroidProvider.debug` ile çalışır

Production için:

- Play Integrity yapılandırmasının gerçekten Firebase Console tarafında da doğrulanması gerekir

---

## 7. Repo içindeki ilgili konfigürasyon dosyaları

- [firebase.json](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/firebase.json:1)
- [firestore.rules](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/firestore.rules:1)
- [storage.rules](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/storage.rules:1)
- [.firebaserc](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/.firebaserc:1)
- [firebase_options.dart](/C:/Users/Casper/Documents/Codex/2026-05-14/https-github-com-yusufgunel-vera-bu/lib/firebase_options.dart:1)

---

## 8. Kurulum sonrası doğrulama checklist’i

Kurulumdan sonra minimum doğrulama:

### Auth

1. email ile sign up
2. sign out
3. aynı kullanıcıyla tekrar sign in

Beklenen:

- session geliyor
- auth controller loading’den çıkar

### Firestore sync

1. custom bank ekle
2. uygulamayı yeniden aç
3. profile setting değiştir
4. yeniden aç

Beklenen:

- bank local ve cloud birleşik görünür
- profile tercihleri korunur

### Import flows

1. receipt scan yap
2. statement import yap
3. signed-in user altında Firestore koleksiyonlarını kontrol et

Beklenen:

- `importedTransactions` dolabilir
- `importArtifacts` metadata oluşabilir

### Storage

Storage setup tamamlandıktan sonra:

1. tekrar receipt/statement import dene
2. Storage altında kullanıcı klasörlerini kontrol et

Beklenen:

- `users/{uid}/imports/...` benzeri dosya yapıları oluşur

### Analytics / Remote Config

1. login / signup / Uma aksiyonu tetikle
2. Firebase Analytics dashboard’da event akışını gözle
3. Remote Config değerleri beklenen varsayılanlarla uyuşuyor mu bak

---

## 9. Gerçekçi durum özeti

Kısaca:

- Firebase bootstrap hazır
- Auth hazır
- Firestore tabanlı çoğu sync servisi hazır
- Analytics / FCM / Remote Config altyapısı hazır
- Storage binary upload tarafı kurulum tamamlanmadan tam sayılmaz

Bugünkü en önemli pratik sonuç:

- proje Firebase olmadan da çalışıyor
- Firebase açıldığında veri katmanı cloud ile zenginleşiyor
- son büyük eksik, Storage kurulumu ve bunu console tarafında doğrulamak
