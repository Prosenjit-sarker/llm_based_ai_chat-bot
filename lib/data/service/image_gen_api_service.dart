import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:llm_based_ai_chat_bot/data/model/image_message_model.dart';

import '../../core/constans/app_strings.dart';

class ImageGenApiService {
  Future<ImageMessageModel> generateImage(String prompt) async {
    try {
      return await _generateViaOpenRouter(prompt);
    } catch (_) {
      return _generateViaPollinations(prompt);
    }
  }

  Future<ImageMessageModel> _generateViaOpenRouter(String prompt) async {
    final response = await http
        .post(
          Uri.parse('${AppStrings.imageGenBaseUrl}/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppStrings.imageGenApiKey}',
            'HTTP-Referer': 'https://localhost',
            'X-Title': AppStrings.appName,
          },
          body: jsonEncode({
            'model': AppStrings.imageGenModel,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': prompt},
                ],
              },
            ],
            'modalities': ['image', 'text'],
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw Exception('OpenRouter failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final message = (data['choices'] as List).first['message'];

    final parsed = _parseAssistantMessage(message);
    if (parsed.imageUrl == null || parsed.imageUrl!.trim().isEmpty) {
      throw Exception('OpenRouter returned no image');
    }

    return ImageMessageModel(
      role: 'assistant',
      text: (parsed.text ?? '').trim(),
      imageUrl: parsed.imageUrl,
      time: DateTime.now(),
    );
  }

  ImageMessageModel _generateViaPollinations(String prompt) {
    final encoded = Uri.encodeComponent(prompt.trim());
    final url = 'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';

    return ImageMessageModel(
      role: 'assistant',
      text: '',
      imageUrl: url,
      time: DateTime.now(),
    );
  }

  _ParsedAssistant _parseAssistantMessage(dynamic message) {
    if (message is! Map<String, dynamic>) return const _ParsedAssistant();

    final content = message['content'];

    if (content is String) {
      return _ParsedAssistant(text: content.trim());
    }

    if (content is List) {
      String? text;
      String? imageUrl;
      String? imageBase64;

      for (final part in content) {
        if (part is! Map<String, dynamic>) continue;

        final type = part['type'];
        if (type == 'text' && part['text'] is String) {
          final t = (part['text'] as String).trim();
          if (t.isNotEmpty) text = (text == null) ? t : '$text\n$t';
        }

        if (type == 'image_url') {
          final url = part['image_url'];
          if (url is Map<String, dynamic> && url['url'] is String) {
            imageUrl ??= (url['url'] as String);
          } else if (url is String) {
            imageUrl ??= url;
          }
        }

        if (type == 'image' && part['image'] is Map<String, dynamic>) {
          final img = part['image'] as Map<String, dynamic>;
          if (img['b64_json'] is String) {
            imageBase64 ??= img['b64_json'] as String;
          }
        }

        if (type == 'output_image') {
          if (part['b64_json'] is String) {
            imageBase64 ??= part['b64_json'] as String;
          }
          if (part['image_url'] is Map<String, dynamic> &&
              (part['image_url'] as Map)['url'] is String) {
            imageUrl ??= (part['image_url'] as Map)['url'] as String;
          }
        }

        if (part['image_url'] is Map<String, dynamic> &&
            (part['image_url'] as Map)['url'] is String) {
          imageUrl ??= (part['image_url'] as Map)['url'] as String;
        }
      }

      if (imageUrl == null && imageBase64 != null && imageBase64.isNotEmpty) {
        imageUrl = 'data:image/png;base64,$imageBase64';
      }

      if (imageUrl == null) {
        final images = message['image'] ?? message['images'];
        if (images is List &&
            images.isNotEmpty &&
            images.first is Map<String, dynamic>) {
          final first = images.first as Map<String, dynamic>;
          final img = first['image_url'];
          if (img is Map<String, dynamic> && img['url'] is String) {
            imageUrl = img['url'] as String;
          } else if (img is String) {
            imageUrl = img;
          }
        }
      }

      return _ParsedAssistant(text: text, imageUrl: imageUrl);
    }

    final images = message['image'] ?? message['images'];
    if (images is List && images.isNotEmpty && images.first is Map) {
      final first = images.first as Map;
      final img = first['image_url'];
      if (img is Map && img['url'] is String) {
        return _ParsedAssistant(imageUrl: img['url'] as String);
      }
      if (first['b64_json'] is String) {
        final b64 = first['b64_json'] as String;
        if (b64.trim().isNotEmpty) {
          return _ParsedAssistant(imageUrl: 'data:image/png;base64,$b64');
        }
      }
    }

    return const _ParsedAssistant();
  }
}

class _ParsedAssistant {
  final String? text;
  final String? imageUrl;
  const _ParsedAssistant({this.text, this.imageUrl});
}
