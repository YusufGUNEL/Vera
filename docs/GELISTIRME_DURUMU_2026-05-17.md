# Vera Geliştirme Durumu

> Tarih: 2026-05-17
> Kapsam: Son geliştirme turunda tamamlanan işler + sıradaki önerilen işler
> Amaç: Repo içindeki son durumu hızlıca anlayabilmek ve kaldığımız yerden devam edebilmek

---

## 1. Genel durum

Vera demo uygulaması artık sadece statik mock ekranlardan oluşan bir prototip değil. Son turlarda ürün, şu eksenlerde daha gerçek ve daha güvenli hale getirildi:

- mock/fallback kaynaklı yanlış kullanıcı verisi üretimi azaltıldı
- ilk kullanım ve boş durum deneyimleri belirgin biçimde iyileştirildi
- onboarding akışı daha anlaşılır hale getirildi
- `AppStrings` üzerinden çok dilli kapsama alanı büyütüldü
- home ekranındaki kritik kartlar artık veri yokken de yön gösteriyor
- AI/heuristic katmanlar gerçek kullanıcı verisine daha anlamlı bağlanıyor

Şu anki odak, "demo görünümü"nden çok "ürün hissi" üretmek üzerine kaymış durumda.

---

## 2. Bu turda tamamlanan ana işler

### 2.1 OCR ve statement fallback güvenlik düzeltmeleri

Tamamlandı:

- `receipt_repository.dart` fallback’i artık sahte fiş verisi döndürmüyor
- `statement_repository.dart` fallback’i artık sahte ekstre verisi döndürmüyor
- receipt/statement UI tarafında fallback geldiğinde kullanıcı uyarılıyor
- fallback senaryosunda confirm/import aksiyonları disabled oluyor

Etkisi:

- kullanıcı yanlışlıkla mock transaction ekleyemiyor
- “AI parse edemedi” durumu artık sessizce sahte veri üretmiyor
- demo bütünlüğü ve güvenilirliği arttı

İlgili dosyalar:

- `lib/features/receipt_scan/data/receipt_repository.dart`
- `lib/features/receipt_scan/presentation/receipt_scan_sheet.dart`
- `lib/features/statement_import/data/statement_repository.dart`
- `lib/features/statement_import/presentation/statement_import_sheet.dart`

### 2.2 Geniş kapsamlı lokalizasyon temizliği

Tamamlandı:

- birçok yeni TR-hardcoded string `AppStrings` içine taşındı
- TR/EN/DE/AR/RU/ZH için yeni string setleri eklendi
- home, wealth, subscriptions, security ve onboarding tarafında yeni UI kopyaları locale-aware hale geldi

Özellikle lokalize edilen alanlar:

- manuel işlem ekleme
- fatura ekleme / upcoming bills empty-state
- transaction empty-state
- goal card çevresi
- wealth empty-state ve add holding sheet
- subscriptions empty-state / status / category / alert metinleri
- security empty-state
- onboarding yeni preview kartları ve CTA’ları

İlgili merkez dosya:

- `lib/core/localization/app_strings.dart`

### 2.3 Subscriptions akışının toparlanması

Tamamlandı:

- parser/repository/controller/screen tarafındaki kullanıcıya görünen stringler `AppStrings` ile konuşuyor
- subscriptions kategorileri artık iç kodlarla tutuluyor ve UI’da locale-aware gösteriliyor
- alert/insight/status pill metinleri daha tutarlı hale geldi

Etkisi:

- abonelik ekranı artık dil değiştirilince parçalı görünmüyor
- iç veri modeli ile görünen metin ayrıldı

İlgili dosyalar:

- `lib/features/subscriptions/data/recurring_transaction_parser.dart`
- `lib/features/subscriptions/data/subscriptions_repository.dart`
- `lib/features/subscriptions/data/firebase_subscriptions_service.dart`
- `lib/features/subscriptions/state/subscriptions_controller.dart`
- `lib/features/subscriptions/presentation/subscriptions_screen.dart`

### 2.4 Onboarding düzeltmeleri ve UX geliştirmeleri

Tamamlandı:

- sign-out ve demo reset sonrası onboarding state resetleniyor
- onboarding üst bölümüne step badge eklendi
- son adımda top-right skip gizlenip daha doğru secondary CTA verildi
- tema ve import adımlarına preview/support kartları eklendi
- onboarding metinleri diğer dillerde de tamamlandı

Etkisi:

- kullanıcı çıkış yapınca onboarding’in bir daha görünmemesi bug’ı çözüldü
- onboarding akışı daha “bitmiş ürün” gibi hissettiriyor
- son adımda kararlar daha açık hale geldi

İlgili dosyalar:

- `lib/features/auth/state/auth_controller.dart`
- `lib/features/profile_settings/presentation/profile_settings_sheet.dart`
- `lib/features/onboarding/presentation/onboarding_screen.dart`

### 2.5 Home ilk kullanım deneyimi iyileştirmeleri

Tamamlandı:

- hiç veri ve hiç banka yokken home’da `HomeFirstStepsCard` gösteriliyor
- kullanıcı doğrudan ekstre import / fiş tarama / banka ekleme aksiyonlarına gidebiliyor
- home section action label’larındaki hardcoded/metin bozulmaları temizlendi
- connected accounts bölümü boşsa artık refresh yerine anlamlı add CTA veriyor
- connected banks için açıklayıcı empty-state kartı eklendi
- proactive card artık veri yoksa import’a, veri varsa ama risk yoksa healthy insight’a dönüyor
- Uma insight strip artık bağlamsal CTA gösteriyor
- spending insight controller tamamen locale-aware hale getirildi

Etkisi:

- ana ekran artık “boş ama anlamsız” değil, “boş ama yön veren” bir ürün akışı sunuyor
- kullanıcıya sıradaki doğru adım her kartta daha net gösteriliyor
- home ekranındaki AI katmanı sadece alarm üretmiyor, rehberlik de ediyor

İlgili dosyalar:

- `lib/features/home/presentation/home_screen.dart`
- `lib/features/home/presentation/widgets/home_first_steps_card.dart`
- `lib/features/home/presentation/widgets/connected_banks.dart`
- `lib/features/home/presentation/widgets/proactive_insight_card.dart`
- `lib/features/home/presentation/widgets/uma_insight_strip.dart`
- `lib/features/home/state/spending_insight_controller.dart`

### 2.6 Test kapsamının büyütülmesi

Tamamlandı:

- home empty-state davranışları için widget testleri eklendi
- `HomeFirstStepsCard`, `ConnectedBanks`, `UmaInsightStrip`, `GoalCard`, `ProactiveInsightCard` artık testle doğrulanıyor
- onboarding akışı için smoke widget testleri eklendi
- receipt ve statement repository fallback davranışı için repository testleri eklendi
- AI parse başarısız olduğunda sahte veri üretilmemesi testle güvence altına alındı

Etkisi:

- empty-state UX katmanları daha güvenli hale geldi
- fallback güvenlik düzeltmeleri artık sadece manuel kontrolde değil, testte de korunuyor

İlgili dosyalar:

- `test/home_empty_states_test.dart`
- `test/onboarding_smoke_test.dart`
- `test/import_fallback_repositories_test.dart`

### 2.7 Goal boş durum UX dokunuşu

Tamamlandı:

- goal empty-state artık sadece “henüz hedef yok” demiyor
- kısa açıklama, zaman ufku preview’leri ve net bir CTA etiketi gösteriyor

Etkisi:

- hedef kurma ekranı daha davetkar hale geldi
- boş goal kartı artık pasif değil, niyet tetikleyen bir kart

İlgili dosya:

- `lib/features/home/presentation/widgets/goal_card.dart`

---

## 3. Yeni eklenen ürün davranışları

Şu davranışlar önceki sürüme göre yenidir:

- OCR/statement parse başarısızsa kullanıcı sahte veriyle ilerleyemez
- onboarding son adımında “import etmeden devam et” aksiyonu açıkça görünür
- home ana ekranında ilk veri ekleme yolculuğu çok daha görünürdür
- proactive insight kartı artık “yok olup gitmek” yerine:
  - risk varsa uyarır
  - veri yoksa yönlendirir
  - veri varsa ama risk yoksa güven verir
- Uma insight strip:
  - hiç veri yoksa import’a yönlendirir
  - banka var ama işlem yoksa ilk işlem eklemeye iter
  - veri varsa Uma ile derinleştirme çağrısı yapar

---

## 4. Teknik olarak dikkat edilmesi gereken noktalar

### 4.1 `app_strings.dart` büyüdü

Bu dosya artık çok merkezi ve uzun. Yeni işlerde:

- key isimlendirmesi tutarlı tutulmalı
- feature bazlı bloklar korunmalı
- mümkünse orta vadede parçalanmalı

Öneri:

- sonraki sprintte `app_strings.dart` dosyasını feature segmentlerine ayırmak
- örn. `app_strings_home.dart`, `app_strings_onboarding.dart`, `app_strings_subscriptions.dart`

### 4.2 Home ekranı daha akıllı ama daha kompleks

`home_screen.dart` artık sadece layout değil, bağlamsal CTA kararları da veriyor.

Öneri:

- orta vadede home’daki CTA kararlarını küçük presenter/helper katmanına taşımak
- özellikle `UmaInsightStrip` ve `ProactiveInsightCard` kararlarını sadeleştirmek

### 4.3 Bazı eski dosyalarda encoding geçmişi vardı

Özellikle önceki turlarda bazı dosyalarda bozulmuş karakter izleri görülüyordu. Kritik yerler temizlendi ama repo genelinde ileride bir “encoding hijyen” turu iyi olur.

Öneri:

- UTF-8 temizliği
- bozuk literal taraması
- gerekiyorsa editorconfig / workspace ayarı sabitleme

---

## 5. Şu an test/doğrulama durumu

Son turlarda her ana değişiklikten sonra tekrar çalıştırıldı:

```powershell
flutter analyze
flutter test
```

Son bilinen durum:

- `flutter analyze`: temiz
- `flutter test`: geçti

Mevcut test kapsaması:

- 6 home widget testi
- 2 onboarding smoke testi
- 6 receipt/statement repository testi

Not:

- widget test kapsamı hâlâ çok sınırlı
- şu an “analyze temiz + smoke düzeyi test geçti” seviyesindeyiz
- ürün davranışlarının çoğu manuel UX doğrulamasına dayanıyor

---

## 6. Şu anda önerilen yapılacaklar

Öncelik sırasıyla:

### P1 — Demo öncesi yüksek değerli işler

1. Home ekranı için widget testleri ekle
2. Onboarding akışını manuel olarak baştan sona bir kez daha smoke test et
3. OCR/statement fallback senaryosunu gerçek bozuk API key ile tekrar kontrol et
4. Empty-state kartlarının mobile/desktop kırılımında spacing davranışını görsel kontrol et

### P2 — Ürün hissini artıracak işler

1. `GoalEditSheet` içine daha güçlü ilk öneri akışı eklemek
2. `UmaInsightStrip` ve `ProactiveInsightCard` için küçük animasyon/stagger geçişleri eklemek
3. Connected accounts / subscriptions / wealth empty-state kartları arasında görsel dil birliği artırmak
4. Goal kartında “örnek hedefler” veya “hızlı preset” akışı eklemek

### P3 — Teknik iyileştirme işleri

1. `app_strings.dart` dosyasını modülerleştirmek
2. Home CTA kararlarını ayrı helper/presenter katmanına taşımak
3. Encoding/locale hijyen taraması yapmak
4. String key kullanılmayan alanları temizlemek

---

## 7. Dosya bazlı hızlı özet

Bu bölüm, “nerelere dokunuldu?” sorusuna kısa cevap verir.

### Home

- `lib/features/home/presentation/home_screen.dart`
- `lib/features/home/presentation/widgets/home_first_steps_card.dart`
- `lib/features/home/presentation/widgets/connected_banks.dart`
- `lib/features/home/presentation/widgets/proactive_insight_card.dart`
- `lib/features/home/presentation/widgets/uma_insight_strip.dart`
- `lib/features/home/presentation/widgets/goal_card.dart`
- `lib/features/home/state/spending_insight_controller.dart`

### Onboarding / Auth

- `lib/features/onboarding/presentation/onboarding_screen.dart`
- `lib/features/auth/state/auth_controller.dart`
- `lib/features/profile_settings/presentation/profile_settings_sheet.dart`

### Import / Scan

- `lib/features/receipt_scan/data/receipt_repository.dart`
- `lib/features/receipt_scan/presentation/receipt_scan_sheet.dart`
- `lib/features/statement_import/data/statement_repository.dart`
- `lib/features/statement_import/presentation/statement_import_sheet.dart`

### Subscriptions

- `lib/features/subscriptions/data/recurring_transaction_parser.dart`
- `lib/features/subscriptions/data/subscriptions_repository.dart`
- `lib/features/subscriptions/data/firebase_subscriptions_service.dart`
- `lib/features/subscriptions/state/subscriptions_controller.dart`
- `lib/features/subscriptions/presentation/subscriptions_screen.dart`

### Localization

- `lib/core/localization/app_strings.dart`

---

## 8. Kaldığımız yerden devam etmek için kısa plan

Eğer bir sonraki oturumda doğrudan devam edilecekse önerilen akış:

1. `flutter analyze`
2. `flutter test`
3. Home empty-state kartlarını görsel olarak bir kez smoke test et
4. Goal / Uma / Proactive üçlüsünde kalan mikro UX boşluklarını kapat
5. Ardından test kapsamı ve docs temizliği turuna geç

---

## 9. Özet

Bugünkü ilerleme en çok şu üç şeyi güçlendirdi:

- güven: fallback’ler artık sahte veriyle kullanıcıyı yanıltmıyor
- yönlendirme: boş ekranlar artık kullanıcıyı doğru aksiyona itiyor
- tutarlılık: çok dilli ürün davranışı daha tamamlanmış görünüyor

Bir sonraki mantıklı aşama, “ürün akışı iyi hissettiriyor” seviyesinden “testli ve bakım dostu” seviyesine geçmek.
