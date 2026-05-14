# Gemini

Bu dokuman, Vera icinde Gemini tabanli AI kabiliyetlerinin nasil
kurgulanacagini tanimlar.

Temel ilke:

- `lib/core/services/gemini_service.dart` tek giris noktasi
- Widget'tan direkt Gemini cagrisi yok
- Her feature kendi repository katmani uzerinden prompt ve fallback yonetsin

## 1. Hackathon hedefi acisindan Gemini'nin rolu

Gemini bu projede "chat bot" olmaktan fazlasidir. Kullanacagimiz baslica roller:

- Harcama ozetleme
- Fraud aciklama yazma
- Kredi kararini insan diline cevirme
- Portfoy aksiyonlarini yorumlama
- Abonelik tespiti ve tasarruf oneri uretme
- Uma agent icin dogal dilden intent cikarmaya yardim etme

## 2. Kurulum

`.env` icine:

```env
GEMINI_API_KEY=AIzaSy...
GEMINI_MODEL=gemini-2.0-flash-exp
```

Varsayilan tercih:

- `gemini-2.0-flash-exp` -> hizli demo deneyimi

Alternatifler:

- `gemini-1.5-flash` -> daha stabil fallback
- `gemini-1.5-pro` -> daha agir reasoning ihtiyaclari

## 3. Kullanim kalibi

```dart
final gemini = ref.read(geminiServiceProvider);
final reply = await gemini.generateText('Aylik harcamayi ozetle');
```

Streaming gerekiyorsa:

```dart
await for (final chunk in gemini.streamText('Kredi kararini acikla')) {
  print(chunk);
}
```

Multimodal ileride su alanlarda kullanilabilir:

- fis / fatura okuma
- kimlik ve belge analizi
- kart ekrani veya dolandiricilik ekran goruntusu yorumlama

## 4. Repository pattern zorunlulugu

Dogru patern:

```dart
class FraudExplanationRepository {
  FraudExplanationRepository(this._gemini);

  final GeminiService _gemini;

  Future<String> explain(FraudEvent event) async {
    return _gemini.generateText(_promptFor(event));
  }
}
```

Yanlis patern:

- widget icinde prompt yazmak
- farkli feature'larda birbirinden kopuk Gemini instance'lari acmak
- fallback'siz AI cagrisi yapmak

## 5. Prompt tasarim ilkeleri

Her prompt su 5 parcayi dusunmeli:

1. Rol
2. Baglam
3. Gorev
4. Kisit
5. Cikis formati

Ornek:

```text
You are a financial risk assistant inside a Turkish mobile banking app.
Explain the fraud alert in concise user-facing language.
Do not invent facts beyond the provided event.
Use 2-4 sentences.
End with one recommended user action.
```

## 6. JSON / yapi tercihleri

Hackathon surecinde her zaman serbest metin yeterli olmayabilir.
Ozellikle Uma ve karar motorlari icin yapisal cikis tercih edilmeli.

Hedef senaryolar:

- intent classification
- risk factor listesi
- savings recommendation
- subscription extraction

Ornek hedef format:

```json
{
  "intent": "pay_credit_card",
  "confidence": 0.91,
  "requires_confirmation": true,
  "entities": {
    "amount": 12450
  }
}
```

Not:

- Ilk asamada regex + heuristic + Gemini hybrid modeli yeterli olabilir
- Tam JSON guvenilirligi icin parse guard'lari eklenmeli

## 7. Feature bazli Gemini kullanim rehberi

### 7.1 Home

Kullanim:

- aylik harcama ozeti
- kategori bazli icgoru
- "daha az harcadin" gibi proaktif mesajlar

Fallback:

- repository icinde statik fakat mantikli bir summary

### 7.2 Wealth

Kullanim:

- rebalance aciklamasi
- risk toleransi ozetleri
- "neden bu dagilim?" cevabi

Fallback:

- kural bazli deterministic metin

### 7.3 Credit

Kullanim:

- kredi sonucu aciklamasi
- red nedenlerini sade dille yazma
- alternatif teklif onermesi

Fallback:

- rule engine sonucunu template string ile aciklama

### 7.4 Security

Kullanim:

- fraud raporu
- risk sinyallerini sade dile cevirme
- "neden engellendi?" aciklama katmani

Fallback:

- event template + risk flags

### 7.5 Subscriptions

Kullanim:

- tekrar eden odemeleri ozetleme
- fiyat artisi riskini anlatma
- iptal veya dondurma oneri dili

### 7.6 Uma

Kullanim:

- serbest metni yorumlama
- aciklayici cevap
- tool secimi icin ikinci gorus

Not:

- Para etkili son karar her zaman local policy ile kontrol edilmeli
- Gemini'nin tek basina "islem yap" otoritesi olmamali

## 8. Guardrail prensipleri

Asagidakiler zorunludur:

- AI olmayan gercegi uyduramaz
- mevcut olmayan banka islemi yaratamaz
- riskli finansal aksiyonu confirmation'siz yurutemez
- oran, fiyat, durum gibi sayisal verileri repository'den almadan uyduramaz
- fraud veya kredi kararinda tek otorite gibi davranamaz

## 9. Fallback stratejisi

Her AI call icin en az bir fallback dusun:

- network fail
- rate limit
- parse fail
- bos cevap

Fallback tipleri:

- deterministic template
- son basarili cache
- sade "manual mode" mesaji
- loading yerine local summary

## 10. Maliyet ve hiz stratejisi

Hackathon icin hedef:

- kisa yanitlar
- dusuk latency
- kontrollu token kullanimi

Bu nedenle:

- prompt'lari kisa tut
- uzun history gonderme
- tek amaca yonelik prompt yaz
- gerekiyorsa son 3 mesajdan fazla baglam gonderme

## 11. Ornek repository listesi

Planlanan AI repository'leri:

- `home/data/cashflow_insight_repository.dart`
- `wealth/data/wealth_explanation_repository.dart`
- `credit/data/credit_explanation_repository.dart`
- `security/data/fraud_explanation_repository.dart`
- `subscriptions/data/subscription_insight_repository.dart`
- `uma_chat/data/intent_router.dart`

## 12. Testing yaklasimi

AI katmanini test ederken:

- prompt'in aynisini golden testleme yerine
- repository'nin fallback davranisini ve parse mantigini test et

Ornek:

- Gemini fail olursa uygun fallback donuyor mu?
- parse edilemeyen sonuc guvenli sekilde ignore ediliyor mu?
- required confirmation flag'i korunuyor mu?

## 13. Sik hatalar

| Hata | Cozum |
|---|---|
| `GEMINI_API_KEY ... tanimli degil` | `.env` icini kontrol et |
| `429 RESOURCE_EXHAUSTED` | kisa bekle, prompt hacmini azalt |
| `403 PERMISSION_DENIED` | API key yetkisini ve dogrulugunu kontrol et |
| Bos / alakasiz yanit | prompt rol ve kisitlarini netlestir |
| Fazla yaratıcı ama guvensiz aksiyon dili | output policy ve confirmation kuralini repository'de sertlestir |

## 14. Son not

Hackathon kazanacak AI deneyimi, sadece "yanit veren model" degil;
urunun karar anlarina akil, aciklama ve guven ekleyen sistemlerdir.
Gemini entegrasyonunu her zaman bu gozle ele al.
