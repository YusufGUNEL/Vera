# Mimari

Bu dokuman, Vera'nin hackathon urun vizyonunu destekleyecek Flutter mimarisini
ve ekip calisma kurallarini tanimlar.

## 1. Mimari hedef

Amacimiz sadece ekran cizen bir mobil uygulama degil; AI destekli finans
modullerinin birbirine baglandigi, aciklanabilir ve kontrollu bir urun
omurgasi kurmak.

Bu nedenle mimari su 4 ihtiyaci ayni anda karsilamali:

- Hizli demo gelistirme
- Feature bazli paralel ekip calismasi
- Mock veriden yarin gercek entegrasyona gecise uygunluk
- Her AI davranisinin repository ve policy katmaninda izole edilmesi

## 2. Ana prensip: feature-first + AI module boundaries

Her urun alani kendi feature klasoru icinde yasamali:

- `home`
- `wealth`
- `credit`
- `security`
- `uma_chat`
- `subscriptions` (eklenecek)
- `profile_settings`

Her feature mumkun oldugunca su parcali yapida ilerlemeli:

```text
features/<feature>/
  domain/        -> saf veri modelleri, entity, enum, policy
  data/          -> repository, mock source, DTO, mapper
  state/         -> Riverpod controller / state object
  presentation/  -> screen, sheet, widget
```

## 3. Klasor yapisi

```text
lib/
|-- main.dart
|-- app.dart
|
|-- core/
|   |-- config/         # env, runtime config, feature flags
|   |-- routing/        # routes ve shell
|   |-- services/       # Gemini gibi dis bagimliliklar
|   |-- theme/          # palette, tokens, vibe, theme
|   `-- utils/          # formatter ve kucuk yardimcilar
|
|-- shared/
|   `-- widgets/        # tekrar kullanilan UI primitifleri
|
`-- features/
    |-- home/
    |-- wealth/
    |-- credit/
    |-- security/
    |-- uma_chat/
    |-- profile_settings/
    `-- subscriptions/  # planlanan yeni feature
```

## 4. AI odakli katmanlama

Hackathon hedefi nedeniyle AI mantigi widget icinde kalmamali. Asagidaki akisi
koru:

```text
UI -> Controller -> Repository -> GeminiService / Rule Engine / Mock Data
```

Bu zincirde sorumluluklar:

- Widget:
  - input alir
  - state render eder
  - repository veya service bilmez
- Controller:
  - ekran akislarini yonetir
  - loading, toast, expand, selection gibi UI state'leri tutar
- Repository:
  - prompt kurar
  - kural bazli karar verir
  - mock / AI / rule engine arasinda secim yapar
- Service:
  - dis API cagrisi yapar

## 5. AI sistemleri nasil yerlestirilecek

### 5.1 Home intelligence

- `features/home/domain/`
  - `account.dart`
  - `normalized_transaction.dart`
  - `cashflow_summary.dart`
- `features/home/data/`
  - `accounts_repository.dart`
  - `transaction_classifier.dart`
  - `cashflow_insight_repository.dart`
- `features/home/state/`
  - `home_controller.dart`

### 5.2 Wealth autonomy

- `features/wealth/domain/`
  - `portfolio_allocation.dart`
  - `autonomy_policy.dart`
  - `rebalance_action.dart`
- `features/wealth/data/`
  - `wealth_repository.dart`
  - `rebalance_engine.dart`
  - `wealth_explanation_repository.dart`

### 5.3 Credit engine

- `features/credit/domain/`
  - `loan_application.dart`
  - `credit_decision.dart`
  - `risk_factor.dart`
- `features/credit/data/`
  - `credit_repository.dart`
  - `credit_rule_engine.dart`
  - `credit_explanation_repository.dart`

### 5.4 Security / fraud

- `features/security/domain/`
  - `fraud_event.dart`
  - `fraud_signal.dart`
  - `review_decision.dart`
- `features/security/data/`
  - `fraud_repository.dart`
  - `fraud_scoring_engine.dart`
  - `fraud_explanation_repository.dart`

### 5.5 Uma orchestration

- `features/uma_chat/domain/`
  - `uma_intent.dart`
  - `uma_action.dart`
  - `approval_policy.dart`
- `features/uma_chat/data/`
  - `uma_repository.dart`
  - `intent_router.dart`
  - `tool_registry.dart`

## 6. Dosya bolme kurali

Bir widget ne zaman ayri dosya olur?

Ayri dosya yap:

- Baska yerde de kullaniliyorsa
- 150+ satirlik gercek logic tasiyorsa
- Kendi painter, animation veya local state'i varsa
- Kendi test dosyasini hak ediyorsa

Ayni dosyada kalabilir:

- Sadece o ekrana ozel kucuk parca ise
- Birkac satirlik private render widget ise

## 7. Riverpod kullanimi

Tercih sirası:

- `Provider<T>` -> repository, service, read-only dependency
- `StateNotifierProvider<C, S>` -> ekran state'i ve akis yonetimi
- `StateProvider<T>` -> cok kucuk ve lokal ihtiyaclar

Controller sorumluluklari:

- async islem baslatmak
- loading ve error state'lerini tutmak
- user action'lari kaydetmek
- optimistic update veya fallback akisi yonetmek

## 8. Theme ve design tokens

Hardcoded renk ve spacing kullanma. `context.tokens` kullan.

Ozellikle:

- `card`, `bg`, `ink`, `muted`, `line`
- `brand`, `uma`, `green`, `red`, `gold`
- `vibe.radius`, `vibe.cardPadding`

Hackathon demoda ekranlar arasi kalite hissi en cok burada kazanilir.

## 9. Mock veri standardi

Mock kullanmak serbest, ama su kurallarla:

- Her mock veri bir repository arkasinda olsun
- Mock data urun senaryosuna inandirici hizmet etsin
- Sadece sayi gostermek yerine karar nedeni de uretilsin
- "neden bu sonucu gordum?" sorusuna UI cevabi olsun

Yanlis ornek:

- Ekranda rastgele skor
- AI kartinda sabit lorem ipsum

Dogru ornek:

- Kredi skoru + nedeni + alternatif teklif
- Fraud event + risk sinyali + kullaniciya aksiyon secimi

## 10. Paralel ekip calisma kurali

Guvenli paralel bolunme:

- Kisi 1 -> `home` + `subscriptions`
- Kisi 2 -> `wealth`
- Kisi 3 -> `credit`
- Kisi 4 -> `security`
- Kisi 5 -> `uma_chat`
- Ortak alanlar -> `core`, `shared`, `pubspec.yaml`

`core/`, `shared/` ve route degisiklikleri once haberlesilerek yapilmali.

## 11. Yeni feature ekleme checklist

1. `features/<name>/` klasorunu ac
2. Domain modellerini yaz
3. Mock repository olustur
4. Riverpod controller ekle
5. Screen veya sheet bagla
6. Route / bottom nav entegrasyonu yap
7. Empty, loading, error state ekle
8. Gerekirse Uma ile bag kur
9. README ve TODO dokumanina feature'i isle

## 12. Hackathon icin zorunlu teknik cizgiler

- Her AI karari bir aciklama satiri tasimali
- Kullanici adina para etkili aksiyonlar confirmation ile gitmeli
- Tek bir `GeminiService` uzerinden AI cagrisi yapilmali
- AI fail olursa deterministic fallback olmasi tercih edilmeli
- Demo kritik alanlarda state replay edilebilir olmali

## 13. Orta vadeli klasor eklemeleri

Eklenmesi onerilen yeni yapilar:

```text
lib/features/subscriptions/
lib/features/credit/domain/
lib/features/credit/data/
lib/features/credit/state/
lib/features/wealth/domain/
lib/features/wealth/data/
lib/features/security/domain/
lib/features/security/state/
lib/features/home/state/
```

## 14. Commit oncesi minimum kontrol

```bash
dart format lib/ docs/
flutter analyze
flutter test
```

Bu mimari, bugunku hackathon demosunu hizlandirirken yarin daha ciddi bir urun
temeline gecisi de mumkun kilar.
