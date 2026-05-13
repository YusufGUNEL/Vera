# Vera

BTK Hackathon mobil uygulamasi. Flutter + Gemini.

## Hizli baslangic

```bash
cd vera
flutter pub get
# .env.example -> .env kopyala, GEMINI_API_KEY ekle
flutter run
```

## Dokumantasyon

- [docs/MIMARI.md](docs/MIMARI.md) — Klasor yapisi, paralel calisma, yeni feature ekleme.
- [docs/GEMINI.md](docs/GEMINI.md) — Gemini servis kullanimi.

## Stack

- Flutter 3.24+
- Dart 3.5+
- `google_generative_ai` (Gemini)
- `flutter_riverpod` (state)
- `go_router` (navigation)
- `flutter_dotenv` (env)
- `google_fonts` (typography)
