# Vera — App Icon + Splash Promptları

> Bu dosya tasarım üreteci (Midjourney, DALL·E 3, Imagen 3, Stable Diffusion, Flux) için hazır promptları içerir. Üretilen görseli `assets/icons/` ve `assets/images/` altına koy, `flutter_launcher_icons` + `flutter_native_splash` ile bağla. Aşağıdaki promptlar **Vera'nın güncel kimliği** ile birebir uyumlu — sahte özellik kalmadıktan sonra ürünün vaadi: *"banka değil, finansal koç"*.

---

## Kimlik özeti (prompt yazarken zihninde tut)

- Ürün adı: **Vera**
- Asistan adı: **UMA** (Universal Money Assistant — uygulamada parıltı/sparkle olarak temsil ediliyor)
- Konum: Türkiye, multi-language (TR, EN, DE, AR, RU, ZH — RTL desteği var)
- Ton: premium, sade, "akıllı sekreter", finans değil koç
- Asla şu hisleri verme: agresif fintech, kripto, kumar, oyun
- Hep şu hisleri ver: güven, sadelik, hafif sıcaklık, gelecek hissi

## Renk paleti (plum varsayılan)

- **Brand (V harfi):** `#3D2645` (koyu eflatun / aubergine)
- **UMA spark:** `#2EAB7E` (canlı teal-yeşil) — *"AI ışığı"*
- **Light BG:** `#F5F2F4` (kremsi)
- **Dark BG:** `#0E1014`
- **İnk:** `#15171A`
- **Muted:** `#8A857C`

---

## 1) App Icon — Ana Prompt (Midjourney / DALL·E 3 / Imagen / Flux)

```
A minimalist mobile app icon for "Vera", a personal finance AI coach.
A bold, geometric letter "V" formed by two clean diagonal strokes in
deep plum (#3D2645), set on a soft cream square background (#F5F2F4)
with iOS-style rounded corners (continuous corners, ~22% corner radius).
At the upper-right of the V's apex, a single 4-point sparkle in vibrant
teal-green (#2EAB7E) with a soft 6px halo — representing the UMA AI light.
Style: flat 2D vector, Apple HIG inspired, premium fintech, calm.
Negative space: balanced, breathing room around the V (~14% padding).
No text, no glow on the V itself, no shadow under the letter, no skeuomorphism,
no 3D, no gradient on the V, no banking clichés (no dollar sign, no coin,
no card, no chart). Crisp edges, perfectly centered, 1024×1024.
```

**Negative prompt (Stable Diffusion / Flux için):**
```
text, watermark, signature, blurry, low-quality, 3d render, glossy,
shiny, neon, gradient on V, skeuomorphism, dollar sign, coin, money,
chart, bank building, human, face, hand, multiple icons, frame, border,
metallic, dark mode, photographic
```

## 2) App Icon — Alternatif (daha cesur, koyu zemin)

```
Premium fintech app icon: solid plum-aubergine rounded square (#3D2645)
filling the entire 1024×1024 canvas (continuous iOS rounded corners).
Centered: a glossy-clean letter "V" in cream off-white (#F2EEE4), formed
by two crisp diagonal strokes meeting at a sharp point. Upper-right of
the V's apex: a single 4-point sparkle in luminous teal-green (#2EAB7E)
with a faint 4px outer glow. No other elements, no text. Style: Apple
App Store quality, minimal, Linear / Stripe-inspired, sharp vector.
```

## 3) Splash Screen — Açılış (1290×2796, iPhone Pro Max oranı)

```
Mobile app splash screen, vertical 1290×2796.
Background: deep plum-to-dark vertical gradient from #3D2645 (top) to
#1A0F1F (bottom), extremely subtle directional lighting from upper-left.
Centered (both axes): large stylized letter "V", height ~180pt, in cream
off-white #F2EEE4, two clean diagonal strokes. Above the V's apex (small
offset upper-right), a single 4-point sparkle in teal-green #2EAB7E with
a soft 40px glow halo.
Below the V (~60px gap): the word "Vera" in a modern geometric sans-serif
(SF Pro Display / Inter Tight feel), weight 600, color #F2EEE4, letter-
spacing -0.5px, size 32pt.
Below "Vera" (~16px gap): a single tagline line in muted #9C8FA4 reading
"Your money, understood." (or in TR: "Paranı anlayan koç."), weight 400,
13pt, letter-spacing 0.3px.
No status bar, no progress indicator, no other UI elements.
Composition: airy, generous vertical breathing room above and below.
```

## 4) Android Adaptive Icon — foreground katmanı

Android adaptive icon iki katman ister. Foreground transparan olur; background tek renk dolgu (#3D2645) — kodla.

**Foreground prompt:**
```
Transparent PNG, 432×432 safe zone within a 1024×1024 canvas (Android
adaptive icon foreground). Centered cream off-white letter "V" (#F2EEE4),
two clean diagonal strokes; plus a small teal-green (#2EAB7E) 4-point
sparkle to the upper-right of the V's apex with a soft inner glow.
Transparent everywhere else. Pure flat 2D vector, no background fill.
```

**Background:**
Düz dolgu: `#3D2645`. Ayrı prompt gerekmez; kodda renk olarak ver.

## 5) Notification icon (Android, monokrom)

```
Single-color silhouette icon, white-only on transparent, 96×96 (Android
notification small icon). Stylized letter "V" with a tiny 4-point sparkle
to the upper-right. No outline, no fill variation, no anti-alias bleed.
```

---

## Kurulum (üretilen görseller geldikten sonra)

`pubspec.yaml`'a iki dev_dependency ekle ve yolları ayarla:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.1

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#3D2645"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
    background_color: "#3D2645"
    theme_color: "#3D2645"

flutter_native_splash:
  color: "#3D2645"
  image: "assets/images/splash_logo.png"
  android_12:
    color: "#3D2645"
    image: "assets/images/splash_logo.png"
  ios: true
  android: true
  web: false
```

Sonra:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Dosya isimlendirme önerisi

```
assets/
├── icons/
│   ├── app_icon.png                  # 1024×1024 ana ikon
│   ├── app_icon_foreground.png       # 1024×1024 transparan
│   └── app_icon_notification.png     # 96×96 monokrom (opsiyonel)
└── images/
    ├── splash_logo.png               # 768×768 splash ortası
    └── onboarding_*.png              # opsiyonel
```

## Çabuk test

İkon kalitesi için 3 ölçek kontrol et:

- **1024px** (App Store / Play Store) — V + sparkle dengeli olmalı
- **180px** (iPhone home @3x) — V hâlâ keskin
- **48px** (Android notification) — V okunabiliyorsa OK; sparkle gözükmüyorsa ayrı monokrom versiyon kullan

Web Chrome devtools'ta `Application → Manifest` ekranında ikon önizlemesi yapabilirsin.
