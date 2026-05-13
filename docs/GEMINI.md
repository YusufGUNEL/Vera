# Gemini

`lib/core/services/gemini_service.dart` tek dokunma noktasi. Direkt `GenerativeModel` yaratma, her zaman `geminiServiceProvider` uzerinden git.

## Kurulum

`.env` dosyasini ac:

```
GEMINI_API_KEY=AIzaSy...
GEMINI_MODEL=gemini-2.0-flash-exp
```

Key icin: https://aistudio.google.com/apikey

## Kullanim

```dart
final gemini = ref.read(geminiServiceProvider);

// Tek seferlik metin
final reply = await gemini.generateText('Istanbul nufusu kac?');

// Streaming (chat icin)
await for (final chunk in gemini.streamText('Hikaye anlat')) {
  print(chunk);
}

// Multi-turn (baglam tutar)
final session = gemini.startChat();
await session.sendMessage(Content.text('Adim Yusuf'));
await session.sendMessage(Content.text('Adimi hatirliyor musun?'));
```

Multimodal (gorsel) icin `image_picker` paketi ekle, sonra `gemini.analyzeImage(imageBytes: ..., prompt: ..., mimeType: 'image/jpeg')`.

## Repository pattern

Feature icinde direkt `geminiServiceProvider`'i widget'tan cagirma. Bir repository ile sarmala:

```dart
// features/uma_chat/data/uma_repository.dart
class UmaRepository {
  UmaRepository(this._gemini);
  final GeminiService _gemini;

  Future<UmaMessage> handle(String userText) async {
    final reply = await _gemini.generateText(_systemPrompt(userText));
    return UmaMessage(role: UmaRole.uma, text: reply.trim());
  }
}

final umaRepositoryProvider = Provider<UmaRepository>((ref) {
  return UmaRepository(ref.watch(geminiServiceProvider));
});
```

Boylece prompt'lar ve mock fallback'ler tek yerde kalir.

## Modeller

| Model | Hiz | Onerim |
|---|---|---|
| `gemini-2.0-flash-exp` | Cok hizli | Default — hackathon icin ideal |
| `gemini-1.5-flash` | Hizli | Stabil alternatif |
| `gemini-1.5-pro` | Yavas | Karmasik akil yurutme |

## Sik hatalar

| Hata | Cozum |
|---|---|
| `GEMINI_API_KEY ... tanimli degil` | `.env`'e key yapistir |
| `429 RESOURCE_EXHAUSTED` | Rate limit — biraz bekle |
| `403 PERMISSION_DENIED` | Key yanlis/devre disi — yenile |
