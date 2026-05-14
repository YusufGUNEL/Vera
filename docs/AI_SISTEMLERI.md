# AI Sistemleri

Bu dokuman, Vera icindeki yapay zeka sistemlerini urun, veri ve teknik akis
acisindan tanimlar.

## 1. Genel bakis

Vera'nin AI yapisi tek bir chatbot'tan olusmaz. Birbirine bagli 6 sistem
olarak dusunulmelidir:

1. Open Banking Intelligence
2. Wealth Autonomy Engine
3. Credit Decision Engine
4. Fraud Radar
5. Subscription Intelligence
6. Uma Orchestrator

## 2. Sistemler arasi iliski

```text
Accounts + Transactions
        |
        v
Open Banking Intelligence -----> Subscription Intelligence
        |                                   |
        v                                   v
Wealth Engine                        Uma Orchestrator
        |                                   ^
        v                                   |
Credit Engine ------------------------------|
        |
        v
Fraud Radar
```

Not:

- `Uma` tum modullerin uzerinde duran etkileisim katmanidir
- Fraud ve credit modulleri kritik oldugu icin daha sert guardrail ister

## 3. Sistem 1 - Open Banking Intelligence

### Problem

Kullanici farkli hesap ve hareketleri tek yerde anlamli goremez.

### Girdi

- hesap listesi
- banka bilgileri
- normalized transaction listesi
- kategori ve tarih bilgisi

### Cikti

- toplam bakiye
- cashflow trend
- grouped transactions
- harcama anomalileri
- AI spending insight

### AI gorevi

- kategori bazli ozet
- aylar arasi degisim
- "you spent less/more" yorumu
- tasarruf firsati tespiti

### Gerekli teknik parcaciklar

- `Account`
- `NormalizedTransaction`
- `TransactionCategory`
- `CashflowSummary`
- `AccountsRepository`
- `CashflowInsightRepository`

## 4. Sistem 2 - Wealth Autonomy Engine

### Problem

Kullanicilar birikim ve portfoy yonetiminde ne yapacaklarini bilmez.

### Girdi

- varlik dagilimi
- kullanici risk profili
- hedef dagilim
- son aktiviteler
- market snapshot mock verisi

### Cikti

- allocation donut
- suggested rebalance
- otonom mod aciklamasi
- "why Uma did this" aktivite kaydi

### AI gorevi

- portfoy ozetleme
- rebalancing nedenini anlatma
- risk / getiri tonunu sadeleştirme

### Guardrail

- gercek alim-satim simulasyonu bile olsa confirmation modeli olmali
- otonom mod limit ve scope ile kisitlanmali

## 5. Sistem 3 - Credit Decision Engine

### Problem

Kullanici kredi sonucunu gorse de nedenini anlamaz.

### Girdi

- gelir
- gider
- mevcut borc
- odeme davranisi
- istenen tutar
- vade

### Cikti

- approve / review / reject karari
- risk factor listesi
- alternatif teklif
- AI explanation

### Karar mantigi

Ilk asamada hybrid model yeterli:

- rule engine -> ana karar
- Gemini -> aciklama ve kullanici dili

### Gerekli domain modelleri

- `LoanApplication`
- `CreditDecision`
- `RiskFactor`
- `OfferOption`

## 6. Sistem 4 - Fraud Radar

### Problem

Kullanicilar riskli islemlerde hem yavas hem de bilgisiz kaliyor.

### Girdi

- event type
- device trust
- location delta
- amount anomaly
- merchant / recipient risk

### Cikti

- risk skoru
- block / allow / review karari
- AI fraud report
- user feedback state

### Kullanici aksiyonlari

- Keep blocked
- This was me
- Report fraud

### Ogrenme hissi

Gercek ML yapmak zorunlu degil; ama urun su hissi vermeli:

- sistem davranisi kullanici feedback'inden ders aliyor
- benzer olaylar daha akilli siniflandiriliyor

## 7. Sistem 5 - Subscription Intelligence

### Problem

Kullanici kucuk ama tekrarli para kacislarini fark etmez.

### Girdi

- tekrar eden islemler
- aylik fiyat degisimi
- son kullanim sinyali (mock olabilir)

### Cikti

- aktif abonelik listesi
- fiyat artisi uyarisi
- unused subscription flag
- cancel / freeze recommendation

### AI gorevi

- "hangi abonelik gereksiz" ozetleme
- tasarruf potansiyeli soyleme
- priorite sirasi onermek

## 8. Sistem 6 - Uma Orchestrator

### Problem

Kullanici her isi farkli ekranda aramak yerine dogal dille yardim almak ister.

### Girdi

- kullanici komutu
- son ekran baglami
- hesap / kart / security / subscription state'leri

### Cikti

- yanit mesaji
- aksiyon karti
- confirmation akisi
- ilgili modula gecis onerisi

### Mimari

Ilk faz:

- heuristic intent routing
- Gemini fallback
- generic action card

Ikinci faz:

- command object modeli
- structured parse
- function/tool calling

### Ornek intent katalogu

- `buy_gold`
- `pay_credit_card`
- `move_to_savings`
- `show_subscriptions`
- `cancel_subscription`
- `explain_fraud_alert`
- `apply_for_loan`

## 9. AI policy katmani

Tum sistemler icin ortak policy ihtiyaci:

- `requiresConfirmation`
- `confidence`
- `userFacingReason`
- `fallbackReason`
- `isMockBacked`

Bu alanlar urun guven hissini ciddi artirir.

## 10. Oncelikli veri sozlesmeleri

Hackathon boyunca erken cikarilmasi gereken modeller:

- `Account`
- `NormalizedTransaction`
- `FraudEvent`
- `LoanApplication`
- `CreditDecision`
- `SubscriptionItem`
- `UmaAction`
- `ApprovalPolicy`

## 11. Teknik gelisim seviyeleri

Her AI sistemini 3 asamada dusun:

### Seviye 1 - Demo

- mock data
- sabit veya yari-dinamik kural mantigi
- Gemini ile aciklama katmani

### Seviye 2 - Productized prototype

- repository/state ayrimi
- parseable outputs
- feedback loop
- daha net policy modeli

### Seviye 3 - Real integration ready

- gercek API / event kaynaklari
- telemetry
- audit log
- cache / retry / rate limit stratejisi

## 12. Hackathon icin en kritik AI ciftleri

En etkili kombinasyonlar:

- Home + Subscription Intelligence
- Security + Uma explanation
- Credit + Uma assisted application
- Wealth + confirmation workflow

## 13. Jüriye anlatim dili

AI'i soyle anlat:

- "Bu ekranda AI sadece metin yazmiyor; kullanicinin riskini degerlendiriyor."
- "Bu modülde karar rule engine ile veriliyor, AI ise bunu acikliyor."
- "Uma butun bu modulleri birlestiren orchestrator gorevi goruyor."

Bu anlatim, projeyi "LLM eklenmis uygulama" olmaktan cikarip "AI sistemleriyle
tasarlanmis finans urunu" seviyesine tasir.
