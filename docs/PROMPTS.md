# Vera — Gerçek Prompt Şablonları

Bu doküman, Vera içinde **şu an gerçekten Gemini'ye gönderilen** prompt'ları tek yerde toplar. Tarayıcıya kodu açmadan promptları görmek, kalibre etmek ve A/B yapmak için.

> İlke: prompt'lar repository dosyalarında `static const _prompt` olarak saklanır. Widget içinde yazılan prompt **yoktur**. Yeni prompt eklerken bu kurala uy.

---

## Genel ilkeler

Her prompt 5 parça içerir (bkz. [GEMINI.md](GEMINI.md)):

1. **Rol** — "You are X inside Y"
2. **Bağlam** — kullanıcı/uygulama bağlamı
3. **Görev** — ne yapılacak
4. **Kısıt** — ne yapılmayacak, format, ton
5. **Çıkış formatı** — JSON şema veya cümle sayısı

Çıkış JSON ise: "ONLY valid JSON, no markdown, no commentary" zorunlu. Markdown code fence sızar ve parse'ı bozar.

---

## 1. Receipt OCR

**Dosya:** `lib/features/receipt_scan/data/receipt_repository.dart`
**Çağrı:** `gemini.analyzeImage(imageBytes, prompt: _prompt)` (multimodal)
**Fallback:** Migros mock fişi (`category: Market`, 4 line item)

```text
You are a receipt and bank screenshot parser inside a Turkish finance app.
Given the image, extract the following information and return ONLY valid JSON
(no markdown, no commentary):

{
  "merchant": "<store or bank name, null if unknown>",
  "total": <total amount as number in TL, null if not visible>,
  "currency": "TL",
  "category": "<one of: Market, Yemek, Akaryakit, Fatura, Saglik, Egitim, Eglence, Banka, Diger>",
  "date": "<date as 'DD MMM' or null>",
  "lines": [
    {"name": "<line item or transaction>", "amount": <number>}
  ]
}

If it's a bank app screenshot, treat each transaction as a line. If it's a
till receipt, treat each line item as a line. Numbers must be plain numerics
(no currency symbols, no thousand separators).
```

**Tasarım kararları:**
- 9 sabit kategori — UI bunlardan birine map'liyor; serbest bırakırsak chart kırılır
- `total: null` izinli — bazı fişlerde toplam okunmaz, mock fallback'a düşmektense null kabul
- "lines" hem fiş satırı hem banka transaction'ı için ortak kap

---

## 2. Statement Import (PDF / Excel)

**Dosya:** `lib/features/statement_import/data/statement_repository.dart`
**Çağrı:** `gemini.analyzeImage(...)` — PDF dahil
**Fallback:** Garanti BBVA mock ekstresi (6 işlem)

```text
You are a Turkish bank statement parser inside a finance app.
The input is a PDF or screenshot of a bank account statement.
Return ONLY valid JSON, no markdown, no commentary:

{
  "bank": "<bank name>",
  "account_last4": "<last 4 of account, null if unknown>",
  "period": "<statement period, e.g. '01.05 - 14.05.2026'>",
  "opening_balance": <number>,
  "closing_balance": <number>,
  "transactions": [
    {
      "date": "DD.MM",
      "description": "<merchant or counterparty>",
      "amount": <signed number; positive = incoming, negative = outgoing>,
      "category": "<Market/Yemek/Akaryakit/Fatura/Saglik/Egitim/Eglence/Banka/Diger>"
    }
  ]
}

Amounts must be plain numerics (no TL symbol, no thousand separators).
List at most 20 most recent transactions.
```

**Tasarım kararları:**
- "at most 20" — Gemini bazen tüm ekstreyi döker, demo için 20 yeter
- Signed amount ile pozitif/negatif ayrımı tek alanda
- `opening_balance` + `closing_balance` — ekstre integrity check için (toplam transaction = closing - opening olmalı)

---

## 3. UMA Chat (heuristic fallback öncesi)

**Dosya:** `lib/features/uma_chat/data/uma_repository.dart`
**Çağrı:** `gemini.streamText(_systemPrompt(userText))`
**Akış:** Önce `IntentRouter` heuristic match dener; bulamazsa Gemini'ye düşer.

```text
You are Uma, the AI coach inside Vera, a Turkish personal finance app.
Vera does NOT execute bank transactions itself. It analyzes the user's data
(imported statements, receipts, screenshots, manual entries) and forwards
real actions to the user's bank app for them to confirm.

Tone: warm, concise (1-3 sentences), helpful. Use TL when relevant.
Never invent specific transaction history or prices the user hasn't asked about.
Never claim Vera will move money. If the user wants an action, say you will
open the right bank app and that they'll confirm there.

User: $userText
Uma:
```

**Guardrail kararları:**
- "does NOT execute bank transactions" — Uma'nın kendini "ben para gönderirim" diye yanıtlamasını engelliyor (Vera lisanslı değil)
- "Never invent specific transaction history" — Gemini sahte rakam üretmesin
- "(1-3 sentences)" — chat UI uzun cevapla kötü görünür; kısa tutuyor
- "User: $userText\nUma:" — açıkça rol kurgusu, single-turn (chat history yok)

---

## 4. Intent Router (heuristic, AI değil)

**Dosya:** `lib/features/uma_chat/data/intent_router.dart`

Bu Gemini'ye gitmez — regex + keyword match'le 8 intent'ten birine çevirir:

| Intent | Türkçe örnek | İngilizce örnek |
|---|---|---|
| `buyGold` | "altın al" | "buy gold" |
| `payCreditCard` | "kredi kartı öde" | "pay my credit card" |
| `moveToSavings` | "birikim hesabına gönder" | "move 2500 to savings" |
| `showSubscriptions` | "abonelikleri göster" | "show subscriptions" |
| `analyzeSpending` | "harcamamı analiz et" | "analyze my spending" |
| `explainWealth` | "portföyümü açıkla" | "explain my portfolio" |
| `checkLoanEligibility` | "kredi alabilir miyim" | "can I get a loan" |
| `explainSecurityAlert` | "bu transfer neden engellendi" | "why was this blocked" |

Match olmazsa → Gemini fallback'ine düşer (yukarıdaki §3).

---

## 5. Eklenmesi planlanan promptlar

Aşağıdakiler henüz repository olarak yazılmadı; AI_SISTEMLERI.md ve ANALIZ_VE_TODO.md'de listelendi:

| Repository | Amaç | Öncelik |
|---|---|---|
| `home/data/cashflow_insight_repository.dart` | "Bu hafta vs geçen hafta" özet | P0 |
| `credit/data/credit_explanation_repository.dart` | Red nedeni → yapıcı tavsiye | P0 |
| `security/data/fraud_explanation_repository.dart` | Fraud event → kullanıcı diline çevir | P0 |
| `wealth/data/wealth_explanation_repository.dart` | Rebalance kararını açıkla | P1 |
| `subscriptions/data/subscription_insight_repository.dart` | "En anlamsız 3 abonelik" özeti | P1 |

Her birinin prompt taslağı `docs/AI_SISTEMLERI.md` § 3-8'de feature bazında listeli.

---

## 6. Prompt yazarken kontrol listesi

- [ ] Rol cümlesi var mı? ("You are ...")
- [ ] Vera'nın "banka değil" konumlandırması korunuyor mu?
- [ ] JSON dönüş ise "ONLY valid JSON, no markdown, no commentary" zorunlu var mı?
- [ ] Türkçe vs İngilizce ton tutarlı mı?
- [ ] Maksimum cümle / satır limiti var mı?
- [ ] Negatif örnek var mı? ("Never claim X")
- [ ] Tek bir göreve odaklı mı (multi-step yok)?
- [ ] Fallback metni (Gemini yoksa) repository'de tanımlı mı?

---

## 7. Test / kalibrasyon ipuçları

- **`gemini-2.0-flash-exp`** — receipt OCR ve statement import için ideal (multimodal + hızlı)
- **`gemini-1.5-flash`** — UMA chat fallback için yeterli, rate limit daha cömert
- **`gemini-1.5-pro`** — şu an kullanılmıyor; daha derin reasoning lazımsa (örn. complex loan rejection) bunu seç
- Prompt değiştirdiğinde: önce mock fallback ile çalıştığını gör, sonra gerçek API'yi dene
- JSON parse fail varsa: response'u logla, prompt'a yeni bir "no markdown" hatırlatması ekle

---

## 8. Maliyet notu

Hackathon free tier sınırları:
- `gemini-2.0-flash-exp` — 10 RPM, 4M TPM (deneysel, değişebilir)
- `gemini-1.5-flash` — 15 RPM, 1M TPM
- Receipt/Statement çağrıları büyük (image), UMA chat küçük

Demo gününde aynı görseli birden fazla parse etme — fallback cache eklemek mantıklı bir P1 işi.
