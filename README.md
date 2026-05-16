# Vera

Vera, BTK Hackathon için geliştirilen yeni nesil AI-native mobil finans uygulaması prototipidir. Amacımız sadece "bankacılık arayüzü" yapmak değil; yapay zeka ile karar veren, açıklama üreten, risk algılayan, kullanıcıyı yönlendiren ve kontrollü şekilde aksiyon alabilen bir finans asistanı (Uma) ortaya çıkarmak.

> **Ürünün vaadi (tek cümle):** *Vera bankaları bağlamıyor — sen veriyi getiriyorsun (PDF ekstre, fiş fotoğrafı, ekran görüntüsü, manuel giriş), Vera AI ile birleştirip anlamlandırıyor, doğru bankaya yönlendirip sonucu takip ediyor.* Bu modelde **BDDK lisansı veya bank partnership gerekmiyor.**

## Hackathon vizyonu

Vera bir "AI-native financial operating system" demosu olarak konumlanır. Ürün, şu 6 AI katmanının birlikte çalıştığını gösterir:

1. **Open Banking Intelligence** — harcama anlama, kategori özetleri
2. **Fraud Radar** — açıklanabilir fraud önleme + kullanıcı geri bildirimi
3. **AI Credit Decisioning** — kural motoru + Gemini açıklaması
4. **Autonomous Wealth Coach** — portföy önerileri, "neden Uma bunu yaptı?"
5. **Subscription Intelligence** — sessiz para kaçışlarını bulma
6. **Uma Agent Orchestration** — doğal dil komutla bütün modülleri tetikleme

Detay için: [docs/URUN_VIZYONU.md](docs/URUN_VIZYONU.md), [docs/MIMARI.md](docs/MIMARI.md)

## Şu an çalışan ana özellikler

- **6 dilli i18n + RTL** — TR / EN / DE / AR / RU / ZH; `context.l10n` extension; SharedPreferences ile kalıcı; AR seçildiğinde otomatik RTL
- **Tema sistemi** — 4 palette × 2 mood × 3 vibe = 24 görsel kombinasyon
- **Auth (demo)** — SharedPreferences tabanlı sign-in / sign-up
- **Home** — net worth, savings story, upcoming bills, connected banks, transactions, credit summary, Uma insight
- **Wealth** — portfolio donut, policy chips, AI aksiyon kartı, activity feed
- **Subscriptions** — filter chips, AI insight, freeze/ask-Uma aksiyonları
- **Credit** — score gauge, loan simulation (4 slider), risk faktörleri, alternatif teklif
- **Security** — fraud feed, "keep blocked / this was me" feedback, Uma fraud raporu
- **UMA Chat** — intent router, Gemini fallback, order cards, bank deep-linkler
- **Receipt OCR** — `image_picker` + Gemini multimodal parse; demo fallback
- **PDF/Excel ekstre import** — `file_picker` + Gemini parser; demo fallback
- **Profile hub** — palette, mood, vibe, AI tonu, dil, bildirim, fraud-alert tercihleri

Tam liste için: [docs/FEATURES.md](docs/FEATURES.md)

## Hızlı başlangıç

```bash
flutter pub get
# .env.example dosyasını .env olarak kopyala, GEMINI_API_KEY'i doldur
flutter run
```

Daha ayrıntılı kurulum: [docs/SETUP.md](docs/SETUP.md)

## Dokümantasyon

| Dosya | İçerik |
|---|---|
| [docs/URUN_VIZYONU.md](docs/URUN_VIZYONU.md) | Ürün konumlandırma, persona, demo hikayesi |
| [docs/MIMARI.md](docs/MIMARI.md) | Feature-first Flutter mimarisi, AI katmanları, ekip kuralları |
| [docs/PROMPTS.md](docs/PROMPTS.md) | Vera içinde gerçekten Gemini'ye gönderilen prompt şablonları |
| [docs/FEATURES.md](docs/FEATURES.md) | ✅/🔜 özellik durumu, lisans matrisi |
| [docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md) | 90 saniyelik sahne senaryosu |
| [docs/SETUP.md](docs/SETUP.md) | Geliştirici ortamı ve build rehberi |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Sürüm geçmişi |

## Stack

- Flutter **3.24+** / Dart **3.5+**
- `flutter_riverpod` — state management
- `go_router` — routing
- `flutter_dotenv` — env config
- `google_fonts` — typography
- `google_generative_ai` — Gemini
- `shared_preferences` + `flutter_secure_storage` — local storage
- `image_picker` — fiş OCR girişi
- `file_picker` — PDF/Excel ekstre seçimi
- `url_launcher` — bankaya deep-link
- `flutter_local_notifications` + `timezone` — fraud alert bildirimi

## Geliştirme prensipleri

- **UI değil ürün zekâsı sat** — her ekran AI ile daha anlamlı olsun
- **Açıkla, güven ver** — her AI çıkışı için açıklama + fallback + user control
- **Mock veriyi gerçek akış gibi tasarla** — sayı + sebep birlikte gelsin
- **Demoda hem "wow" hem "güven"** — sahne dramatik ama ürün dürüst

## Lisans matrisi (özet)

| Yetenek | Lisans gerekir mi? | Vera bugün yapabilir mi? |
|---|---|---|
| PDF ekstre okuma | ❌ | ✅ |
| Fiş OCR | ❌ | ✅ |
| AI harcama analizi | ❌ | ✅ |
| Kredi simülasyonu | ❌ | ✅ |
| Bankaya deep-link | ❌ | ✅ |
| Gerçek zamanlı bakiye | ✅ AISP | ❌ (partnership şart) |
| Banka adına para gönder | ✅ PSP | ❌ (lisans şart) |
| Kart blokla / fraud durdur | ✅ Banka | ❌ (sadece iletilir) |

Tam matris ve detay: [docs/FEATURES.md](docs/FEATURES.md)
