# Vera

Vera, hackathon odakli bir yeni nesil mobil finans uygulamasi prototipidir.
Amacimiz sadece "bankacilik arayuzu" yapmak degil; yapay zeka ile karar veren,
aciklama ureten, risk algilayan, kullaniciyi yonlendiren ve kontrollu sekilde
aksiyon alabilen bir finans asistani ortaya cikarmak.

Urunun ana vaadi:

- Tum hesaplari tek yerde goren AI destekli finans merkezi
- Harcama, birikim, kredi ve guvenlik konularinda proaktif icgoru
- Kullanici adina islem oneren ve kontrollu sekilde uygulayan Uma asistani
- Hackathon jürisine "gorunen AI" degil, urun akisini gercekten guclendiren AI sistemleri gostermek

## Hackathon vizyonu

Vera bir "AI-native financial operating system" demosu olarak konumlanir.
Urun, su 6 AI katmaninin birlikte calistigini gostermelidir:

1. Open Banking Intelligence
2. Fraud Radar
3. AI Credit Decisioning
4. Autonomous Wealth Coach
5. Subscription Intelligence
6. Uma Agent Orchestration

Bu katmanlarin her biri icin urun, ekran, state, mock veri, karar motoru ve
aciklanabilirlik katmani tasarlanmalidir.

Detaylar icin:

- [docs/URUN_VIZYONU.md](docs/URUN_VIZYONU.md)
- [docs/AI_SISTEMLERI.md](docs/AI_SISTEMLERI.md)
- [docs/ANALIZ_VE_TODO.md](docs/ANALIZ_VE_TODO.md)

## Hizli baslangic

```bash
flutter pub get
# .env.example dosyasini .env olarak kopyala
# GEMINI_API_KEY ve opsiyonel GEMINI_MODEL degerlerini ekle
flutter run
```

## Proje durumu

Su anda projede bulunan ana alanlar:

- `home` - hesaplar, bakiye, islemler
- `wealth` - portfoy ve otonom yonetim
- `credit` - kredi skoru ve basvuru deneyimi
- `security` - fraud radar ve guvenlik olaylari
- `uma_chat` - AI asistan ve aksiyon kartlari
- `profile_settings` - tema ve tercih yonetimi

Bu alanlarin cogu demo seviyesinde iskelet olarak mevcut; hedefimiz bunlari
hackathon sunumunda etkileyici bir urun hikayesine baglamaktir.

## Dokumantasyon

- [docs/MIMARI.md](docs/MIMARI.md) - Flutter feature-first mimari ve ekip calisma kurallari
- [docs/GEMINI.md](docs/GEMINI.md) - Gemini servis kullanimi ve AI repository prensipleri
- [docs/URUN_VIZYONU.md](docs/URUN_VIZYONU.md) - urun konumlandirma, persona, demo hikayesi
- [docs/AI_SISTEMLERI.md](docs/AI_SISTEMLERI.md) - AI modulleri, veri akislari, guardrail'ler
- [docs/DEMO_AKISI.md](docs/DEMO_AKISI.md) - hackathon sunum akisi ve sahne hikayesi
- [docs/ANALIZ_VE_TODO.md](docs/ANALIZ_VE_TODO.md) - genisletilmis backlog, sprint plani, karar listesi

## Stack

- Flutter 3.24+
- Dart 3.5+
- `flutter_riverpod`
- `go_router`
- `flutter_dotenv`
- `google_fonts`
- `google_generative_ai`

## Gelistirme prensipleri

- UI degil urun zekasi satin: her ekran AI ile daha anlamli hale gelsin
- Her AI cikisi icin aciklama, guven, fallback ve user control dusun
- Mock veri kullanilabilir ama akislari gercek urun mantigi gibi tasarla
- Hackathon demoda "wow" etkisi kadar "guven" etkisi de olustur

## Bir sonraki buyuk hedefler

- Subscription Tracker MVP
- Credit simulation + explainability
- Security feedback loop
- Uma action router + voice command MVP
- Wealth automation policy modeli
