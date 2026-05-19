import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Web-safe Gemini multimodal calls via REST (avoids dart2js Int64 in the SDK).
class GeminiWebRest {
  const GeminiWebRest();

  Future<String> generateContent({
    required String apiKey,
    required String model,
    required String prompt,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    ).replace(queryParameters: {'key': apiKey});
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Encode(bytes),
                },
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gemini REST ${response.statusCode}: ${response.body}',
      );
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = map['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return '';

    final first = candidates.first;
    if (first is! Map<String, dynamic>) return '';

    final content = first['content'];
    if (content is! Map<String, dynamic>) return '';

    final parts = content['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return '';

    final textPart = parts.first;
    if (textPart is! Map<String, dynamic>) return '';

    return (textPart['text'] as String?)?.trim() ?? '';
  }
}
