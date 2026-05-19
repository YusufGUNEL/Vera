# Vera — Geliştirici Kurulum Rehberi

Bu doküman, projeyi sıfırdan kuran biri için tam ortamı yazar.

---

## 1. Gereksinimler

| Bileşen | Sürüm | Notu |
|---|---|---|
| Flutter | **3.24+** (3.41.9 önerilen) | `flutter --version` ile kontrol |
| Dart | **3.5+** | Flutter ile gelir |
| Android Studio | Hornet veya üzeri | Android emulator + SDK için |
| Xcode | 15+ | iOS build alacaksanız (macOS) |
| Chrome | 120+ | Web hedefi için |
| Git | 2.40+ | — |

`flutter doctor` çalıştırıp tüm tikleri yeşil yap.

---

## 2. Projeyi klonla

```bash
git clone https://github.com/YusufGUNEL/Vera.git
cd Vera
flutter pub get
```

---

## 3. `.env` ayarla

```bash
cp .env.example .env
```

Sonra `.env` içine kendi değerlerini koy:

```env
GEMINI_API_KEY=AIzaSy...         # Google AI Studio'dan al
GEMINI_MODEL=gemini-2.0-flash-exp # veya gemini-1.5-flash
HOME_FEED_URL=                    # opsiyonel canlı veri endpoint'i
SECURITY_FEED_URL=                # opsiyonel
```

> **Key yoksa ne olur?** Uygulama yine çalışır. Receipt OCR ve statement import fallback mock veri kullanır, UMA chat heuristic intent router ile cevap verir. Demo akışında bu da "DEMO" rozetiyle dürüstçe gösterilir.

Gemini key almak için: <https://aistudio.google.com/apikey>

---

## 4. Çalıştırma

### Android emulator / fiziksel cihaz

```bash
flutter devices                  # cihazları listele
flutter run -d <device_id>
```

### iOS simulator (macOS)

```bash
cd ios && pod install && cd ..
flutter run -d <iphone_simulator_id>
```

### Web (Chrome)

```bash
flutter run -d chrome
```

> Web hedefinde `image_picker` ve `file_picker` davranışı sınırlı (kamera yok, sürükle-bırak yok). Tam OCR akışını mobilde test et.

---

## 5. Release build alma

### Android APK (demo için)

```bash
flutter build apk --release
# Çıktı: build/app/outputs/flutter-apk/app-release.apk
```

### Web (statik host)

```bash
flutter build web --release
# Çıktı: build/web/  -> herhangi bir static host'a koy
```

> Bu repo dinamik `IconData` kullandığı için production web build'i şu komutla
> alınmalı:
>
> ```bash
> flutter build web --release --no-tree-shake-icons
> ```
>
> Vercel ile en hızlı yol:
>
> ```bash
> flutter build web --release --no-tree-shake-icons
> vercel --prod build/web
> ```

Web deploy ve sprint sonu release checklist'i için: [DEPLOY.md](DEPLOY.md)

### App bundle (Play Store)

```bash
flutter build appbundle --release
```

---

## 6. Icon ve splash üretimi

Branding için tek kaynak klasör `assets/branding/`. Repo içindeki güncel üretim scripti `tool/gen_branding.py`; eski `tool/generate_icon.py` referans amaçlı duruyor ama ana kaynak değil.

```
assets/branding/
├── icon.png                    # 1024×1024 ana ikon
├── icon_background.png         # 1024×1024 adaptive bg
├── icon_foreground.png         # 1024×1024 adaptive fg (transparan)
└── splash_logo.png             # 768×768 splash ortası
```

Sonra:

```bash
python tool/gen_branding.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Web splash `web/index.html` içindeki branding ile aynı asset ailesini kullanır. Asset güncelledikten sonra:

```bash
flutter clean
flutter pub get
```

`pubspec.yaml` içindeki `flutter_launcher_icons:` ve `flutter_native_splash:` blokları zaten yapılandırılmış; Android launcher icon, Android 12 splash ve web splash bu dört dosyadan üretilir.

---

## 7. Klasör yapısı (özet)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/         # env, runtime config
│   ├── localization/   # 6 dilli i18n (TR/EN/DE/AR/RU/ZH)
│   ├── routing/        # go_router setup
│   ├── services/       # GeminiService, NotificationService
│   ├── theme/          # palette, tokens, vibe
│   └── utils/          # formatters, font weight helpers
├── shared/widgets/     # tekrar kullanılan UI primitifleri
└── features/
    ├── home/
    ├── wealth/
    ├── credit/
    ├── security/
    ├── subscriptions/
    ├── receipt_scan/
    ├── statement_import/
    ├── uma_chat/
    ├── auth/
    └── profile_settings/
```

Her feature içinde: `domain/` (modeller) → `data/` (repository) → `state/` (Riverpod controller) → `presentation/` (screen + widgets).

Detay: [MIMARI.md](MIMARI.md)

---

## 8. Lint ve test

```bash
flutter analyze       # 0 issue beklenir
flutter test          # widget + unit testler
dart format lib/ docs/
```

CI yoksa commit öncesi üçünü de çalıştır.
Deploy öncesi tam akış için: [DEPLOY.md](DEPLOY.md)

---

## 9. Yaygın sorunlar

| Sorun | Çözüm |
|---|---|
| `GEMINI_API_KEY tanımlı değil` | `.env` içinde key'i kontrol et, `flutter clean && flutter pub get` |
| Android adaptive icon görünmüyor | `dart run flutter_launcher_icons` koşmadın mı? `flutter clean` sonra tekrar build |
| Web'de `image_picker` çalışmıyor | Bu beklenen — kamera web'de yok, dosya yükleme ile devam |
| `429 RESOURCE_EXHAUSTED` (Gemini) | Free tier rate limit. `GEMINI_MODEL=gemini-1.5-flash` ile dene |
| Build sonrası eski strings görüyorum | `flutter clean && flutter pub get`; cached assets temizle |
| `flutter_local_notifications` Android'de izin istemiyor | Android 13+ için manifest'te `POST_NOTIFICATIONS` izni var; ilk fraud alert geldiğinde sistem isteyecek |
| Splash ekranı eski logo gösteriyor | `dart run flutter_native_splash:create` ile yeniden üret, sonra `flutter clean` |

---

## 10. Demo öncesi checklist

- [ ] `.env`'de geçerli `GEMINI_API_KEY` var
- [ ] `flutter analyze` → 0 issue
- [ ] `flutter build apk --release` başarılı
- [ ] Test cihazında APK kurulu, uçak modunda da açılıyor (fallback test)
- [ ] Demo cihazı şarjda, auto-lock kapalı
- [ ] Sahnede gösterilecek dilleri (TR + EN + AR/RTL) test ettin
- [ ] `docs/DEMO_SCRIPT.md` ezberlendi

---

## 11. Sorun bildirimi

GitHub Issues: <https://github.com/YusufGUNEL/Vera/issues>

Demo gününde takıldığında: önce `flutter clean && flutter pub get`, sonra `.env` kontrolü, sonra konsola bak.
