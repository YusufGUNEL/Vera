# Vera: Yapay Zeka Yerel (AI-Native) Finansal İşletim Sistemi

Geleneksel mobil bankacılık ve finans uygulamaları kullanıcıya sadece ham verileri, grafikleri ve sayıları gösterir. Vera ise bu veriyi **anlar, yorumlar, riskleri tespit eder ve kullanıcı kontrolünde otonom kararlar alarak** finansal farkındalığı bir üst seviyeye taşır.

Vera, sıradan bir "bankacılık arayüzü" veya basit bir chat bot değildir. Yapay zeka ile karar veren, açıklama üreten, risk algılayan, kullanıcıyı yönlendiren ve kontrollü şekilde aksiyon alabilen 6 farklı AI katmanının senkronize çalıştığı bütünsel bir **Finansal İşletim Sistemi**dir.

---

## 🌟 Ürün Vaadi ve Lisanssız İş Modeli

Finans teknolojilerinde (FinTech) en büyük pazara giriş bariyeri, BDDK lisansları almak ve bankalarla karmaşık API entegrasyonları/iş ortaklıkları kurmaktır.

**Vera, bankaları doğrudan sisteme bağlamaz; veriyi kullanıcı getirir.**
Kullanıcı PDF ekstre yükleyerek, fiş fotoğrafı çekerek ya da sadece ekran görüntüsü paylaşarak verisini uygulamaya dahil ettiğinde, Vera bu verileri Gemini multimodal yapay zekası ile anında yapılandırır ve anlamlandırır. Doğru bankaya deep-link ile yönlendirme yaparak finansal aksiyonların tamamlanmasını takip eder.

Bu yenilikçi iş modeli sayesinde:
* **BDDK lisansına gerek kalmaz.**
* **Banka iş ortaklığı kurulması zorunlu değildir.**
* **Mevzuata %100 uyumlu** ve bugün çalışabilen bir finansal asistan doğmuş olur.

---

## 🚀 Hackathon Vizyonunu Oluşturan 6 Yapay Zeka Katmanı

1. 🏦 **Open Banking Intelligence**: PDF/Excel ekstrelerinden veya manuel girdilerden harcama analizleri, otomatik kategorilendirme ve finansal özetler çıkarır.
2. 🚨 **Fraud Radar**: Şüpheli işlemleri yakalar. Açıklanabilir (explainable) kurallar çerçevesinde kullanıcıyı uyarır ve geri bildirimi ile kendini geliştirir.
3. 📊 **AI Credit Decisioning**: Gelişmiş kural motoru ve Gemini açıklamaları ile kredi başvurularını değerlendirir, reddedilen durumlar için alternatif yol haritaları sunar.
4. 🧠 **Autonomous Wealth Coach**: Kullanıcı varlıklarını analiz ederek kişiye özel portföy önerileri geliştirir ve otonom rebalancing tavsiyeleri sunar.
5. 💸 **Subscription Intelligence**: Kullanıcı harcamalarındaki sessiz para kaçışlarını (unutulan abonelikler, gizli fiyat artışları) tespit eder.
6. 🗣️ **Uma Agent Orchestration**: Doğal dil komutlarıyla çalışan finansal yardımcı. Güven skorları, kaynak referansları ve otonom araç tetikleyicileri ile tüm modülleri yönetir.

---

## 🎨 Arayüz & Görsel Deneyim

Vera, modern mobil tasarım trendlerini (Glassmorphism, Neon gradyanlar, Karanlık mod öncelikli şablonlar) en üst seviyede uygular.

### 🛠️ Gelişmiş Kişiselleştirme & Tema Motoru
Uygulama, kullanıcının ruh haline ve tarzına göre anında değişebilen **24 farklı görsel kombinasyon** sunar:
- **4 Renk Paleti**: Emerald Green, Deep Orchid, Sapphire Neon, Sunset Gold
- **2 Görsel Mod (Mood)**: Cyberpunk (Canlı neon), Velvet Dark (Mat & Premium)
- **3 Arayüz Hissi (Vibe)**: Rounded (Yumuşak köşeler), Sharp (Köşeli / Tech), Glass (Cam efekti)

---

## 🔑 Öne Çıkan Çalışan Özellikler

- **📁 Masaüstü/Web Sürükle-Bırak Entegrasyonu**: Ekstre ve fiş yükleme ekranlarında sürükle-bırak (`desktop_drop`) desteği ile masaüstü veya web ortamlarında hızlı dosya okuma.
- **📄 Akıllı OCR (Fiş & Ekstre PDF İçe Aktarma)**: `image_picker` ve `file_picker` ile yüklenen belgeleri Gemini çok modlu (multimodal) yapay zekasıyla anında ayrıştırma ve işlemleri otomatik oluşturma.
- **💬 Gelişmiş UMA Asistanı (v2)**: 
  - Kararların arkasındaki güven oranlarını gösteren *Confidence Label*
  - Bilginin kaynağını gösteren *Source Chips*
  - İşlem öncesi onay isteyen *Confirmation-first* aksiyon kartları
- **📅 Abonelik Detektörü**: Tekrarlanan ödemeleri otomatik saptama, dondurma veya Uma'ya yönlendirme.
- **📈 Kredi Simülatörü**: 4 farklı slider ile esnek vade ve tutar simülasyonu, risk analizi ve alternatif teklifler.
- **🛡️ Fraud Önleme**: `FraudHeuristic` altyapısı ile olağandışı transferleri (büyük miktarlar, ani artışlar vb.) tespit etme ve kullanıcı dönütleriyle modeli eğitme.
- **🌍 6 Dil & RTL Desteği**: Türkçe, İngilizce, Almanca, Arapça (RTL), Rusça ve Çince dilleriyle entegre yerelleştirme yapısı.
- **🔐 Firebase Auth & Yerel Fallback**: Güvenli e-posta girişi ve tüm yerel önbelleği temizleyen oturum kapatma akışı.

---

## 🏗️ Teknik Stack & Altyapı
* **Framework:** Flutter **3.24+** & Dart **3.5+** (Web / Android / iOS / Desktop)
* **State Management:** `flutter_riverpod` ile temiz veri akışı
* **Router:** `go_router` ile deklaratif yönlendirme
* **GenAI SDK:** `google_generative_ai` (Gemini API)
* **Drag-and-Drop:** Masaüstü ve Web tarayıcıları için `desktop_drop` entegrasyonu
* **Backend & Auth:** Firebase Core, Auth, Firestore ve Cloud Storage
* **Yerel Bildirimler:** `flutter_local_notifications`

---

## 🌐 Canlı Yayın & Dağıtım Bilgileri
* **Canlı Web Uygulaması (Firebase Hosting):** [https://vera-ai-finance.web.app](https://vera-ai-finance.web.app)
* **GitHub Deposu:** [https://github.com/YusufGUNEL/Vera](https://github.com/YusufGUNEL/Vera)
