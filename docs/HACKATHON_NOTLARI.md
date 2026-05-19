# Hackathon'26 - Durum ve Kalan Isler

> BTK Akademi x Google x GIRVAK Hackathon'26 icin Vera'nin guncel durum ozeti,
> kalan blokajlar ve teslim oncesi son kontrol listesi.

## Bugunku durum

| Alan | Durum |
| --- | --- |
| Gemini text ve agent-assisted finance flows | Tamam |
| Gemini multimodal (fis ve PDF ekstre) | Tamam |
| Firebase Auth / Firestore / FCM / Analytics / Crashlytics / Remote Config | Tamam |
| Google Sign-In kod akisi | Tamam |
| Voice input (STT tabanli) | Tamam |
| Hesap silme akisi | Tamam |
| Responsive web iyilestirmeleri | Tamam |
| Android release altyapisi | Tamam |
| Canli link / deploy karari | Opsiyonel |
| Google Maps entegrasyonu | Yok |

## Artik tamamlanmis ana maddeler

### Google Sign-In

Kod akisi repo icinde var. Login ve signup ekranlari Google ile devam et
aksiyonunu destekliyor. Eger Android tarafinda `sign_in_failed` gorulurse bu
kod eksigi degil, Firebase Console tarafinda SHA-1 fingerprint eksigi demektir.

### Voice input

Voice input artik "eksik feature" degil. UMA icinde STT tabanli sesli giris ve
partial transcript akisi var. Bu kisim demo kapsaminda kullanilabilir.

### Hesap silme

Hesap silme akisi uygulama icinde mevcut. Demo hesapta local temizleme,
gercek Firebase hesapta destructive warning ve silme akisi bulunuyor.

### Responsive web

Flutter web arayuzu artik sadece mobil buyutmesi gibi davranmiyor. Home,
login, signup ve kritik modal/sheet yuzeyleri tablet ve desktop genisliklerinde
daha kontrollu bir yerlesime sahip.

## Kalan tek kritik blokaj

### Firebase Console - Android SHA-1

Google Sign-In'in gercek cihazda sorunsuz calismasi icin Firebase Console'a
Android uygulamasi icin SHA-1 fingerprint eklenmeli ve yeni
`android/app/google-services.json` indirilmelidir. Bu adim repo disidir.

Yapilacaklar:

1. Firebase Console -> Project Settings -> Android app -> Add fingerprint
2. Debug veya release SHA-1 degerini ekle
3. Yeni `google-services.json` dosyasini indir
4. `android/app/google-services.json` uzerine yaz
5. Android cihazda "Google ile devam et" akisina tekrar bak

Not: Kod tarafinda kullaniciya bu problem icin daha anlasilir hata mesaji zaten
gosteriliyor.

## Teslim oncesi son smoke listesi

### Zorunlu teknik kontroller

- `flutter analyze` -> `0 issue`
- `flutter test`
- `flutter build web --release --no-tree-shake-icons`
- `flutter build apk --debug --no-tree-shake-icons`

### Manuel UI kontrolleri

- Login ekraninda local/demo bilgi alani dogru gorunuyor.
- Signup ekraninda terms/policy linkleri aciliyor.
- Home desktop/tablet yerlesimi kirik veya tasmali gorunmuyor.
- Notification badge sayisi ve `Tumunu okudum` / `Temizle` aksiyonlari calisiyor.
- Receipt scan ve statement import fallback/disabled durumlari gorunuyor.
- UMA icinde `Yeni sohbet` butonu yalnizca selamlama durumuna donuyor.
- Profile icinde hesap silme metni demo ve gercek hesapta mantikli.

## Opsiyonel sonraki tur

Bu maddeler teslim blokaji degil, vakit kalirsa ele alinabilir:

- Google Maps tabanli harcama gorsellestirmesi
- Citation / RAG benzeri kaynak gosterimi
- Goal / budget kartlarinda ekstra polish
- Empty-state ve motion iyilestirmeleri

## Repo disi kalan isler

| Is | Neden repo disi |
| --- | --- |
| Firebase Console'a SHA-1 eklemek | Google hesabina erisim gerekir |
| Android cihazda final smoke test | Fiziksel cihaz gerekir |
| Play Store / Test track yukleme | Hesap ve signing sahipligi gerekir |
| Gemini API key rotate | Anahtar sahipligi gerekir |
