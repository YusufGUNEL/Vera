# Hackathon'26 — Eksikler ve Eklenecekler

> BTK Akademi × Google × GİRVAK Hackathon'26 için Vera'nın kapsama analizi
> ve önem sırasına göre yapılacaklar listesi.

## Yarışmanın bizden istediği (özet)

| Boyut | Detay |
| --- | --- |
| Çekirdek teknoloji | **Gemini** (üretken AI) zorunlu |
| Teslim | GitHub repo + **canlı link** (yoksa 1 dk video) + form |
| Format | 6–19 Mayıs online, 5 Haziran final sunum |
| Ödüller | 140k / 85k / 55k ₺ |
| Önceki şablon | 2025 ikincisi **STOX**: multimodal Gemini + agentic davranış + gerçek iş problemi |

Resmi rubric kamuya açık değil. Aşağıdaki sıralama; STOX şablonu, yarışma
metinleri ve Google ürün entegrasyonu sinyaliyle çıkarıldı.

---

## Vera'nın bugünkü kapsaması

| Alan | Durum |
| --- | --- |
| Gemini text (chat, kategorizasyon, hedef tavsiyesi) | ✅ |
| Gemini multimodal (fiş görüntüsü, PDF ekstre) | ✅ |
| Firebase Auth / Firestore / FCM / App Check / Analytics / Crashlytics / Remote Config | ✅ |
| 6 dil + RTL, 24 tema kombinasyonu | ✅ |
| Android release config (R8, ProGuard, signing) | ✅ |
| Canlı web deployment | ❌ |
| Hesap silme (Google Play zorunlu) | ✅ |
| Gemini function calling / agentic davranış | ✅ kısıtlı tool policy + confirmation-first |
| Google Sign-In | ✅ |
| Voice (Gemini Live / STT) | ✅ STT tabanlı + partial transcript |
| Google Maps entegrasyonu | ❌ |

---

## P0 — Olmazsa kaybederiz

### 1. Firebase Hosting'e deploy
Yarışma kuralı "ürünün canlı halinin olduğu link" diyor. Web build hazır,
sadece `flutter build web && firebase deploy --only hosting` gerekli.
Bu olmadan teslim eksik.

### 2. Hesap silme
Google Play Store politikası: hesap oluşturmaya izin veren her uygulama
hem app içinde hem web'de silme sunmak zorunda. Jüri "production ready mi"
sinyalini buradan da okur. Akış:
- `FirebaseAuth.instance.currentUser.delete()`
- Tüm `users/{uid}/...` Firestore koleksiyonlarının silinmesi
- Local cache temizliği (`signOut` zaten yapıyor)
- Profile sheet'te onay diyaloğu + 6 dil l10n
- Demo hesabı için (`a`/`b`) sadece local seed wipe

---

## P1 — Jüri "vay be"e geçer (yüksek etki)

### 3. Gemini function calling (Uma → gerçek aksiyon)
Şu an Uma sadece konuşuyor. Function calling ile:
- "Acil durum hedefi 100k oluştur" → `createGoal` tool çağrılır, hedef
  gerçekten yaratılır
- "Netflix aboneliğini dondur" → `freezeSubscription`
- "Bu ay markette ne kadar harcadım" → `queryCategorySpend`

STOX kazandı çünkü "AI agent operations" yapıyordu. Bu Vera'yı chatbot'tan
**agent**'a çıkarır.

### 4. Google Sign-In
1-2 saatlik iş. Mevcut Firebase Auth üstüne `google_sign_in` paketi.
"Google ekosistemini gerçekten kullanıyor" sinyali çok güçlü; email/şifre
tek başına yetersiz görünüyor.

### 5. Voice input (sesle Uma'yı çağır)
`speech_to_text` paketi → metin → mevcut Gemini akışı. L10n'da
`voiceCommandTooltip` zaten duruyor, implementasyon eksik.
Demo'da mikrofon basıp "ne kadar param var" demek = anında etki.

---

## P2 — Görsel demo zenginleştirici

### 6. Google Maps — "nereye harcadın"
İşlem merchant'ından lokasyon heuristic çıkar, haritada harcama ısı
haritası. 5 dk geliştirilir, jüri 30 sn'de etkilenir.

### 7. Vertex AI Search / RAG citation
Uma cevap verirken hangi ekstreden/işlemden çıkardığını gösterir
(citation chip'leri). "Hallüsinasyon yok, kaynak var" güven sinyali.

---

## P3 — Varsa hoş

### 8. Imagen — kategori rozetleri
AI üretilmiş kategori ikonları. Gimmick ama görselde fark eder.

### 9. Workspace entegrasyonu
"Google Sheets'e aktar" / "Drive'a PDF kaydet" tile'ları.

### 10. Google Pay / Wallet Pass
Fatura "öde" akışı. Lisans engeli var, vaat etme — sadece deep-link.

---

## Önerilen sprint planı

| Süre | Kapsam |
| --- | --- |
| 6 saat (minimum) | P0 — deploy + hesap silme |
| 2 gün (ideal) | P0 + P1 (function calling, Sign-In, voice) |
| 3+ gün (lüks) | P0 + P1 + P2 |

P0 olmadan teslim geçersiz sayılabilir. P1 yarışmada finalist olma şansını
ciddi şekilde artırır.
