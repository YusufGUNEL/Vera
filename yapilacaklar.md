# Vera Projesi - Üretim Hazırlığı Yapılacaklar Listesi

En son yaptığımız çalışmalarla projedeki statik demo verileri temizlendi, dinamik auth entegrasyonu sağlandı ve web/masaüstü için sürükle-bırak dosya yükleme altyapısı kuruldu.

## 🛠️ Tamamlanan Görevler
- [x] **Desktop Drop Bağımlılığı**: `desktop_drop: ^0.5.0` paketi `pubspec.yaml`'a eklendi ve `flutter pub get` çalıştırıldı.
- [x] **Ortak Sürükle-Bırak Widget'ı**: `lib/shared/widgets/drag_drop_zone.dart` widget'ı oluşturuldu. Masaüstü/Web'de aktif çalışırken mobil platformlarda fallback olarak normal buton akışını koruyor.
- [x] **Ekstre İçe Aktarma Güncellemesi**: `StatementImportSheet` dosya seçici alanı `DragDropZone` ile sarmalandı. PDF/Resim dosyaları artık sürüklenip bırakılarak okunabiliyor.
- [x] **Fiş Tarama Güncellemesi**: `ReceiptScanSheet` dosya seçici alanı `DragDropZone` ile sarmalandı.
- [x] **AuthSession Geliştirmesi**: `AuthSession` modeline `isAnonymous` computed property'si eklenerek `demo-user` kontrolü merkezi hale getirildi.
- [x] **Demo Profil Referanslarının Temizlenmesi**: `ProfileSettingsSheet` içerisindeki hardcoded `'demo@vera.app'` ve `'demo-user'` gibi tüm statik metinler temizlendi; yerine kullanıcı bilgisi yoksa localized `l10n.defaultUserName` veya `l10n.notSet` gelecek şekilde güncellendi.
- [x] **Yerelleştirme (Localization) Güncellemeleri**: `notSet` ve sürükle-bırak aşamasındaki yönlendirme metinleri (`dragDropHint`, `dragDropActive` vb.) `app_strings.dart`, `en.dart` ve `tr.dart` dosyalarına eklendi.
- [x] **Derleme & Hata Kontrolü**: `flutter analyze` başarıyla çalıştırıldı ve sıfır hata ile tamamlandı.

## 📋 Sırada Bekleyen Görevler
- [ ] **Git Commit & Push**: Mevcut yapılan tüm değişiklikleri branch'e commitleyip uzak sunucuya (GitHub) göndermek.
- [ ] **Test**:
  - Hem "Anonim/Demo Giriş" hem de "Gerçek Google/Email Girişi" ile profil detay sayfasındaki dinamik verilerin doğruluğunu test etmek.
  - Web veya Masaüstü emülatöründe PDF ekstre veya fiş sürükleyip bırakarak AI okuma akışını test etmek.
