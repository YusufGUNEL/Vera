# Vera Deploy Rehberi

Bu dokuman, sprint sonunda canli link ve release dogrulamasini tek akista
tamamlamak icin hazirlandi.

## 1. Ortam hazirligi

```bash
flutter pub get
cp .env.example .env
```

- `.env` icinde en az `GEMINI_API_KEY` doldur.
- Firebase env fallback kullanacaksan `FIREBASE_*` alanlarini da doldur.
- Web hedefi icin production build komutu her zaman `--no-tree-shake-icons`
  ile alinmali.

## 2. Release oncesi dogrulama

```bash
flutter analyze
flutter test
flutter build web --release --no-tree-shake-icons
flutter build apk --debug
```

Mumkunse ek olarak:

```bash
flutter build apk --release
```

Manuel smoke checklist:

- `.env` tam iken login, signup, home ve profile aciliyor.
- `.env` eksikken uygulama aciliyor, local/demo yonlendirmesi gorunuyor.
- Demo hesap (`a` / `b`) seeded home ile aciliyor.
- Receipt scan ve statement import fallback halinde sari uyari gosteriyor ve
  import CTA disable kaliyor.
- Profile icindeki hesap silme akisi demo ve gercek hesapta farkli metin
  gosteriyor.

## 3. Web deploy

Repo icinde `vercel.json` bulundugu icin varsayilan canli link akisi Vercel
uzerinden alinabilir:

```bash
flutter build web --release --no-tree-shake-icons
vercel --prod build/web
```

Kontrol et:

- Acilis sayfasi yukleniyor.
- Login / signup ekranlari aciliyor.
- Home navigation bozulmuyor.
- Responsive temel akis masaustu ve mobil genislikte kirilmiyor.

## 4. Android teslim paketi

```bash
flutter build appbundle --release
```

Eger Play Store icin imzali bundle gerekiyorsa `docs/YAPILACAKLAR.md`
icindeki `android/key.properties` ve upload keystore adimlarini uygula.

## 5. Sorun aninda hizli triage

1. `flutter clean && flutter pub get`
2. `.env` ve `FIREBASE_*` alanlarini kontrol et
3. Login ekranindaki local/demo uyarilarini kontrol et
4. `main.dart` startup loglarinda `[Env]` ve `[Startup]` satirlarini incele
