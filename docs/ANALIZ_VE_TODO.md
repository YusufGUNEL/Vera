# Vera Analiz ve Genisletilmis TODO Plani

Bu dokuman, Vera'yi hackathon seviyesinde etkileyici bir AI finans uygulamasina
donusturmek icin gereken urun, teknik ve sunum backlog'unu toplar.

## 1. Kuzey yildizi

Hedef:

- "Bir bankacilik arayuzu" degil
- "Yapay zeka ile calisan finansal isletim sistemi" prototipi yapmak

Jürinin sunum sonunda anlamasi gereken ana mesaj:

- Vera finansal veriyi topluyor
- yapay zeka ile yorumluyor
- riski acikliyor
- firsat buluyor
- aksiyon oneriyor
- kullanici kontrolu ile uyguluyor

## 2. Mevcut durum ozeti

Projede simdiden bulunan ana moduller:

- `home`
- `wealth`
- `credit`
- `security`
- `uma_chat`
- `profile_settings`

Mevcut guclu taraflar:

- Flutter tabanli hizli demo zemini
- feature-first klasor yapisi
- Gemini servisinin tek noktada toplanmasi
- premium his verebilecek theme ve token altyapisi
- Uma icin temel chat ve action card yapisi

Mevcut sinirlar:

- bircok akista mock veri agirligi fazla
- AI davranislarinin buyuk kismi sabit veya yari-statik
- urun gereksinimleri ve acceptance criteria zayif
- yeni feature olarak subscription tarafi yok
- explainability ve audit kavramlari parca parca

## 3. Stratejik karar

Bu repo icin en dogru yol:

- Flutter ile devam et

Gerekce:

- mevcut iskelet hizli
- mobil hissi zaten guclu
- hackathon zamaninda platform degistirmek yerine urun zekasina yatirim daha verimli

Bu nedenle backlog'un tamami Flutter tabani ustunden planlanmistir.

## 4. Son gelistirmeler

Son turda yapilanlar:

- Home tarafinda grouped transaction deneyimi guclendirildi
- Security ekraninda item bazli expand ve review aksiyonlari eklendi
- Uma action card yapisi tek senaryodan cikartilip genellestirildi
- README ve dokumanlar urun vizyonuna yaklastirilmaya baslandi

Bu durum bize yeni backlog'ta "AI davranisini derinlestirme" asamasina gecme
firsati veriyor.

## 5. Hackathon kazanma formulu

Urunun guclu gorunmesi icin su 5 sey birlikte calismali:

1. Cok net problem tanimi
2. Birbirine bagli AI modulleri
3. Guclu demo hikayesi
4. Aciklanabilir ve guvenli aksiyonlar
5. Tasarim ve urun dilinde premium tutarlilik

## 6. Ana urun epikleri

### Epic A - Financial cockpit

Kapsam:

- toplam net worth
- bagli hesaplar
- grouped transactions
- spending insight
- account health summary

Hackathon degeri:

- demo ilk izlenimi
- finansal merkeziyet hissi

### Epic B - Explainable security

Kapsam:

- fraud event timeline
- AI report
- kullanici feedback loop
- trust device sinyalleri

Hackathon degeri:

- guven temasi
- "AI koruyor" hissi

### Epic C - Explainable credit

Kapsam:

- loan simulation
- approve/review/reject
- risk faktorleri
- alternatif teklif

Hackathon degeri:

- AI karar motoru etkisi
- veriden karara giden yolun gosterilmesi

### Epic D - Autonomous wealth

Kapsam:

- portfolio donut
- action feed
- risk policy
- auto/manual mode

Hackathon degeri:

- gelecegin bankaciligi hissi
- AI + automation hikayesi

### Epic E - Subscription intelligence

Kapsam:

- tekrarli odeme tespiti
- fiyat artisi
- kullanilmayan abonelik uyarisi
- cancel/freeze recommendation

Hackathon degeri:

- cebe dokunan net fayda
- kolay anlasilir wow etkisi

### Epic F - Uma orchestration

Kapsam:

- dogal dil komutlar
- action router
- confirmation kartlari
- moduller arasi gecis

Hackathon degeri:

- tum sistemleri birlestiren ana AI hissi

## 7. Modül bazli detay backlog

## 7.1 Home / Open Banking Intelligence

### Simdiki durum

- net worth karti var
- banka kartlari var
- transaction listesi var
- basic insight strip var

### Eksikler

- normalized account modeli yok
- transaction classifier yok
- account health puani yok
- gelir / gider trend kartlari yok
- acik bankacilik hissi sadece UI seviyesinde

### Yuksek oncelikli isler

- `home/domain/account.dart` ekle
- `home/domain/normalized_transaction.dart` ekle
- `home/domain/cashflow_summary.dart` ekle
- `home/data/accounts_repository.dart` yaz
- `home/data/cashflow_insight_repository.dart` yaz
- `home/state/home_controller.dart` olustur
- account bazli "healthy / attention / critical" ozet karti ekle
- son 7 gun / 30 gun harcama karsilastirma karti ekle
- "upcoming bills" mini section ekle
- "subscriptions detected" kisayolu ekle

### Orta oncelikli isler

- merchant logo / category enrichment
- transaction search
- filter by bank / category
- salary day detection
- recurring payment detection icin ilk sinyal katmani

### AI odakli isler

- spending insight'i dinamiklestir
- "this week vs last week" anlatimi uret
- "tasarruf firsati" mikro onerisi uret

### Acceptance criteria

- ana ekrana bakinca kullanicinin finansal durumu 5 saniyede anlasilmali
- en az bir dinamik AI insight gorunmeli
- en az bir sonraki aksiyon kullaniciya gosterilmeli

## 7.2 Wealth / Autonomous Finance

### Simdiki durum

- portfolio donut var
- auto management toggle var
- aktivite akisi var

### Eksikler

- aktivite state'den beslenmiyor
- autonomy policy modellenmemis
- action feed explainability zayif
- mock allocation sabit

### Yuksek oncelikli isler

- `wealth/domain/autonomy_policy.dart`
- `wealth/domain/portfolio_allocation.dart`
- `wealth/domain/rebalance_action.dart`
- `wealth/data/wealth_repository.dart`
- `wealth/data/rebalance_engine.dart`
- `wealth/state/wealth_controller.dart`
- auto/manual/confirm mode ayrimi ekle
- "Uma did this because..." feed karti ekle
- "undo suggestion" veya "review change" modeli ekle

### Orta oncelikli isler

- hedef bazli birikim modu
- altin / fon / nakit hedef dagilimi
- market snapshot mock verisi
- risk appetite onboarding

### AI odakli isler

- portfoy ozet aciklamasi
- rebalancing nedeni
- "ne olur eger?" mikro senaryolari

### Acceptance criteria

- kullanici otomasyonun ne yaptigini anlayabilmeli
- auto mode her zaman guardrail ile aciklanmali
- feed sadece dekoratif degil karar izi gibi calismali

## 7.3 Credit / Explainable Decision Engine

### Simdiki durum

- score gauge var
- CTA var
- insight kutusu var

### Eksikler

- basvuru formu yok
- risk faktorleri yok
- karar motoru yok
- alternatif teklif yok

### Yuksek oncelikli isler

- `credit/domain/loan_application.dart`
- `credit/domain/credit_decision.dart`
- `credit/domain/risk_factor.dart`
- `credit/domain/offer_option.dart`
- `credit/data/credit_rule_engine.dart`
- `credit/data/credit_repository.dart`
- `credit/state/credit_controller.dart`
- loan simulation bottom sheet ekle
- amount, term, income, monthly debt inputlari ekle
- karar sonucu olarak approve / review / reject senaryolari yaz
- explainability section ekle

### Orta oncelikli isler

- debt-to-income gosterimi
- confidence meter
- "improve your odds" checklist
- pre-approved card / micro-loan alternatifleri

### AI odakli isler

- risk faktorlerini insan diline cevir
- red durumunda yapici tavsiye ver
- alternatif teklif sirala

### Acceptance criteria

- jürinin onunde input degistiginde sonuc degismeli
- karar sadece skor degil sebep de gostermeli
- red durumunda bile urun yardim edici gorunmeli

## 7.4 Security / Fraud Radar

### Simdiki durum

- durum karti var
- fraud event listesi var
- item bazli review aksiyonu basladi

### Eksikler

- state yapisi formal degil
- risk sinyalleri modellenmemis
- feedback loop persistent degil
- report still mock

### Yuksek oncelikli isler

- `security/domain/fraud_event.dart`
- `security/domain/fraud_signal.dart`
- `security/domain/review_decision.dart`
- `security/data/fraud_repository.dart`
- `security/data/fraud_scoring_engine.dart`
- `security/data/fraud_explanation_repository.dart`
- `security/state/security_controller.dart`
- blocked / approved / escalated durumlarini modelle
- "report fraud" secondary aksiyonu ekle
- trusted devices mini paneli ekle

### Orta oncelikli isler

- event severity siralama
- map / geo anomaly hissi
- timeline detail sheet
- card lock / unlock entegrasyon hissi

### AI odakli isler

- olay bazli AI raporu
- "neden supheli?" breakdown
- benzer davranis icin ogrenme hissi

### Acceptance criteria

- her riskli islemde aciklama satiri olmali
- kullanici false positive geri bildirimi verebilmeli
- ekran guven veren ama panik yaratmayan ton tasimali

## 7.5 Subscriptions / Silent Money Leaks

### Simdiki durum

- feature yok

### Yuksek oncelikli isler

- `features/subscriptions/` klasorunu ac
- `domain/subscription_item.dart`
- `domain/subscription_status.dart`
- `domain/subscription_alert.dart`
- `data/subscriptions_repository.dart`
- `data/recurring_transaction_parser.dart`
- `data/subscription_insight_repository.dart`
- `state/subscriptions_controller.dart`
- subscriptions screen tasarla
- active / price increased / unused gruplari ekle
- potential savings summary karti ekle
- cancel / freeze recommendation kartlari ekle

### Orta oncelikli isler

- category filters
- annualized waste metric
- "used this month?" mock signal
- upcoming renewal reminder

### AI odakli isler

- "senin icin en anlamsiz 3 abonelik" ozeti
- fiyat artisi aciklamasi
- tasarruf plani uretimi

### Acceptance criteria

- ilk bakista somut tasarruf rakami gorunmeli
- en az bir kullanilmayan veya pahalanan abonelik flag'i olmali
- Uma bu ekrana yonlendirme yapabilmeli

## 7.6 Uma / Financial Copilot

### Simdiki durum

- chat sheet var
- generic action card yapisi var
- basic suggestions var

### Eksikler

- intent catalog dar
- voice gercek degil
- action router zayif
- audit / approval policy eksik
- screen context kullanimi yok

### Yuksek oncelikli isler

- `uma_chat/domain/uma_intent.dart`
- `uma_chat/domain/uma_action.dart`
- `uma_chat/domain/approval_policy.dart`
- `uma_chat/data/intent_router.dart`
- `uma_chat/data/tool_registry.dart`
- `uma_chat/data/uma_audit_repository.dart`
- `uma_chat/state/uma_controller.dart` icine command flow genislet
- intent listesi olustur:
  - kredi karti ode
  - altin al
  - birikime aktar
  - abonelikleri goster
  - supheli islemi acikla
  - kredi uygunlugumu kontrol et
- action card metadata'sini zenginlestir
- confirmation policy UI'ini gelistir
- "voice command coming soon" yerine gercek mic planini bagla

### Orta oncelikli isler

- streaming response
- screen-aware suggestions
- action history timeline
- quick follow-up chips

### AI odakli isler

- structured intent parse
- confidence score
- safe fallback
- multi-step command decomposition

### Acceptance criteria

- Uma en az 4 farkli modulle anlamli bag kurmali
- para etkili tum komutlar confirmation ile gitmeli
- fallback durumunda bile yardimci kalmali

## 7.7 Profile / Settings / Personalization

### Simdiki durum

- palette, mood, vibe ayarlari var

### Eksikler

- product settings hub degil
- dil, bildirim, gizlilik, guven tercihleri yok
- AI preference yok

### Yuksek oncelikli isler

- settings'i 4 gruba ayir:
  - appearance
  - privacy
  - security
  - AI preferences
- "Uma can act automatically" tercihlerini tasarla
- notification preferences ekle
- profile summary karti ekle

### Orta oncelikli isler

- language toggle
- biometric preference
- theme coverage checklist

### AI odakli isler

- kullanici AI tonu secsin:
  - concise
  - coaching
  - proactive

## 8. Teknik altyapi backlog'u

## 8.1 Kod kalitesi

- `withOpacity` -> `withValues`
- deprecated `useMaterial3` duzeltmeleri
- `prefer_const_constructors` cleanup
- bozuk karakterleri temizleme
- format ve lint standartlarini netlestirme

## 8.2 State standardizasyonu

- her buyuk feature icin controller/state modeli
- loading / empty / error state standardi
- success toast / snackbar standardi
- action result state standardi

## 8.3 Repository standardizasyonu

- her AI feature icin repository
- mock source ve explanation source ayrimi
- data mapper paternini standartlastir
- future gercek API entegrasyonuna hazir isimlendirme yap

## 8.4 Test backlog'u

- widget smoke testlerini artir
- home controller testleri
- credit rule engine testleri
- fraud scoring testleri
- uma intent router testleri
- subscriptions parser testleri

## 8.5 Demo dayanıkliligi

- AI fail olursa fallback metin
- internet yoksa mock mode
- button spam korumasi
- loading state netligi
- bos veri durumlari

## 9. Urun dil ve UX backlog'u

- tum kopyalari urun tonuna yaklastir
- Turkce / Ingilizce stratejisini netlestir
- AI mesajlarinda tek bir persona dili kullan
- "professional but warm" tonunu standardize et
- CTA'larda teknik dil yerine kullanici dili kullan

## 10. Jüri etkisi yuksek mini ozellikler

Kisa surede buyuk etki yaratabilecek isler:

- subscription savings counter
- fraud confidence chip
- credit rejection reasons listesi
- Uma "why this action?" mini explanation
- upcoming bills strip
- emergency fund progress karti
- trusted device panel
- "this month you saved X TL" story card

## 11. Demo akisi backlog'u

Sunumun temiz gitmesi icin ozel hazirliklar:

- seeded mock scenario seti hazirla
- demo kullanicisinin adi, hesaplari ve hikayesini sabitle
- her ekran icin sunum sirasinda gosterilecek 1 ana "wow" noktasi belirle
- demo sirasinda girilecek Uma komutlarini dokumante et
- internet sorunu halinde fallback plan cikar

## 12. Veri model backlog'u

Erken cikarilmasi gereken modeller:

- `Account`
- `BankConnection`
- `NormalizedTransaction`
- `CashflowSummary`
- `FraudEvent`
- `FraudSignal`
- `CreditDecision`
- `RiskFactor`
- `SubscriptionItem`
- `SubscriptionAlert`
- `UmaIntent`
- `UmaAction`
- `ApprovalPolicy`

## 13. Dokumantasyon backlog'u

- PRD benzeri urun gereksinim dokumani
- ekran bazli acceptance criteria dokumani
- mock veri senaryolari dokumani
- demo script dokumani
- AI guardrail ve policy dokumani
- test stratejisi dokumani

## 14. Onceliklendirilmis sprint plani

## Sprint 1 - Jürinin gorecegi cekirdek deneyim

- README ve urun vizyonu dokumanlari
- Home intelligence guclendirme
- Security explainability guclendirme
- Uma generic action system
- kopya ve tasarim dili temizligi

## Sprint 2 - AI cekirdegi

- Credit simulation MVP
- Wealth policy modeli
- Subscription feature MVP
- Uma intent catalog genisletme

## Sprint 3 - Guven ve baglantilar

- AI explanations repositories
- test kapsami
- loading / empty / error state
- settings / privacy / AI preferences

## Sprint 4 - Sunum sertlestirme

- demo scenario hardening
- polish ve animation
- fallback paths
- son lint ve bug cleanup

## 15. P0 / P1 / P2 / P3 siralamasi

## P0 - Mutlaka yap

- Product vision netlestir
- Home AI insight guclendir
- Credit simulation MVP
- Fraud explanation guclendir
- Uma 4 komutu desteklesin
- Subscription MVP kur

## P1 - Cok guclendirir

- Wealth autonomy policy
- user feedback loops
- explainability breakdown cards
- settings hub
- upcoming bills and savings goals

## P2 - Kaliteyi yukselten isler

- voice command MVP
- streaming response
- advanced filters
- animations ve micro-interactions

## P3 - Sonraya kalabilecek ama degerli

- gercek entegrasyonlar
- telemetry
- cache/retry katmani
- full localization

## 16. Hemen uygulanabilecek buyuk kazanclar

Su andan itibaren hizli ilerleme icin en mantikli siralama:

1. `subscriptions` feature'ini ac
2. `credit` icin rule engine + simulator ekle
3. `uma_chat` icin intent router ve audit modeli yaz
4. `home` icin account health + upcoming bills ekle
5. `wealth` icin autonomy policy ve activity state kur
6. AI explanation repository'lerini modül modül bagla

## 17. Riskler

- sadece UI cilalayip AI derinligini zayif birakmak
- demo gunu AI gecikmesi yasamak
- cok fazla feature acip hicbirini derinlestirememek
- jargon agir ama urun hikayesi zayif sunum yapmak

## 18. Risk azaltma plani

- her kritik AI akisi icin fallback yaz
- her modülde tek bir wow noktasi sec
- modül sayisini degil etkiyi optimize et
- karar, neden ve aksiyon ucgenini her yerde koru

## 19. Sonuc

Vera'nin en buyuk firsati, farkli finans use-case'lerini tek bir AI asistanda
birlestirmesi. Bu backlog'un amaci sadece yapilacaklar listesi vermek degil;
hangi islerin hackathon'da bizi "iyi gorunen proje"den "gercekten akilli urun"
seviyesine tasiyacagini netlestirmektir.
