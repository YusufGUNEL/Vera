# Demo Akisi

Bu dokuman, hackathon sunumunda Vera'yi en etkili sekilde gostermek icin
onerilen demo hikayesini tanimlar.

## 1. Ana mesaj

Vera birden fazla AI sistemini tek bir finansal deneyimde birlestirir.

## 2. Acilis cumlesi onerisi

"Insanlar finansal hayatlarini farkli uygulamalarda parca parca yonetiyor.
Vera ise bunu tek yerde topluyor, yorumluyor ve kullanici adina guvenli
aksiyonlar onerebiliyor."

## 3. Onerilen 3 dakikalik demo

### Adim 1 - Home

Goster:

- toplam net worth
- grouped transactions
- AI spending insight

Soyle:

- "Vera sadece hareketleri listelemiyor, harcama davranisini da anliyor."

### Adim 2 - Subscriptions

Goster:

- tekrar eden odemeler
- fiyat artisi veya kullanilmayan abonelik
- potential savings

Soyle:

- "Bir cok kullanici sessiz para kacislarini fark etmiyor. Vera burada tasarruf
  firsatini aktif olarak buluyor."

### Adim 3 - Security

Goster:

- supheli transfer
- AI fraud report
- Keep blocked / This was me feedback

Soyle:

- "Sistem sadece block etmiyor; nedenini acikliyor ve kullanicidan ogreniyor."

### Adim 4 - Credit

Goster:

- tutar / vade degistir
- karar degissin
- reason listesi gorunsun

Soyle:

- "Burada karar kara kutu degil. AI sonucu acikliyor ve alternatif yol sunuyor."

### Adim 5 - Uma

Goster:

- "Pay my credit card"
- "Move money to savings"
- "Show my subscriptions"

Soyle:

- "Uma tum bu AI sistemlerini birbirine baglayan finansal copilot."

## 4. Demo sirasinda kullanilacak ornek komutlar

- `Pay my credit card`
- `Move 2500 TL to savings`
- `Why was this transfer blocked?`
- `Show my subscriptions`
- `Can I get a 50k loan?`

## 5. Demo veri senaryolari

Sunumda kullanilacak kullanici profili:

- bir maas kullanicisi
- 3 bankada hesabi var
- 2 aktif abonelik, 1 gereksiz abonelik var
- bir supheli transfer olayi var
- kredi karti son odemesi yaklasiyor

## 6. Kaçinilacak seyler

- tek ekranda cok uzun kalmak
- sadece chat gostermek
- AI'in neden faydali oldugunu aciklamadan ilerlemek
- sadece guzel UI gostermek

## 7. Sunum sonrasi sorulabilecek sorulara hazir cevaplar

### "Gercek veri mi?"

- "Su an hackathon prototipi olarak mock ve rule-based veri kullaniyoruz, ama
  mimari gercek entegrasyonlara hazir tasarlandi."

### "AI karari nasil veriyor?"

- "Karar kritik alanlarda rule engine + AI explanation seklinde ayriliyor.
  Boylece hem kontrol hem de aciklanabilirlik sagliyoruz."

### "Guvenlik nasil saglaniyor?"

- "Para etkili aksiyonlarda confirmation policy uyguluyoruz. AI tek basina
  kritik transfer baslatmiyor."

## 8. Demo oncesi checklist

- internet var mi kontrol et
- `.env` dogru mu kontrol et
- seeded veri senaryolari hazir mi
- butun ekranlar aciliyor mu
- Uma komutlari beklenen karsiligi veriyor mu
- fallback mesajlari duzgun mu

Bu dokumanin amaci, teknik gelistirmeleri sahnede en yuksek etkiyi yaratacak
sekilde birlestirmektir.
