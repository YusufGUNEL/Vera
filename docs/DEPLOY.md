# Vera Release Rehberi

Bu dokuman deploy kararindan bagimsiz olarak release dogrulamasini tek akista
tamamlamak icin hazirlandi. Bu turda odak canli platform secmek degil,
Flutter web ve Android ciktilarini teslime hazir hale getirmektir.

## 1. Ortam hazirligi

```bash
flutter pub get
cp .env.example .env
```

- `.env` icinde en az `GEMINI_API_KEY` doldur.
- Firebase env fallback kullanacaksan `FIREBASE_*` alanlarini da doldur.
- Web production build komutu her zaman `--no-tree-shake-icons` ile alinmali.

## 2. Release oncesi dogrulama

```bash
flutter analyze
flutter test
flutter build web --release --no-tree-shake-icons
flutter build apk --debug --no-tree-shake-icons
```

Mumkunse ek olarak:

```bash
flutter build apk --release
```

## 3. Manuel smoke checklist

- `.env` tam iken login, signup, home ve profile aciliyor.
- `.env` eksikken uygulama aciliyor ve local/demo yonlendirmesi gorunuyor.
- Demo hesap (`a` / `b`) seeded home ile aciliyor.
- Login ve signup ekranlari mobil, tablet ve desktop genisliklerinde kirilmiyor.
- Home dashboard desktop'ta buyutulmus mobil ekran gibi gorunmuyor.
- Notification badge sayisi dogru ve sheet aksiyonlari calisiyor.
- Receipt scan ve statement import fallback halinde uyari gosteriyor ve import
  CTA disabled kaliyor.
- UMA icinde `Yeni sohbet` akisi ve voice input acilabiliyor.
- Profile icindeki hesap silme akisi demo ve gercek hesapta farkli metin
  gosteriyor.

## 4. Android ozel not

Google Sign-In cihazda hata veriyorsa once Firebase Console tarafindaki SHA-1
fingerprint ayarini kontrol et. Bu adim repo disidir; ayrintili notlar
`docs/HACKATHON_NOTLARI.md` ve `docs/YAPILACAKLAR.md` icindedir.

## 5. Android teslim paketi

```bash
flutter build appbundle --release
```

Play Store icin imzali bundle gerekiyorsa `docs/YAPILACAKLAR.md` icindeki
keystore ve `android/key.properties` adimlarini uygula.

## 6. Sorun aninda hizli triage

1. `flutter clean && flutter pub get`
2. `.env` ve `FIREBASE_*` alanlarini kontrol et
3. Login ekranindaki local/demo uyarilarini kontrol et
4. `main.dart` startup loglarinda `[Env]` ve `[Startup]` satirlarini incele
