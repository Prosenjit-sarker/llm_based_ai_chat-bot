import 'dart:convert';

import 'package:llm_based_ai_chat_bot/core/constans/app_strings.dart';
import 'package:llm_based_ai_chat_bot/data/model/message_model.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  Future<String> fetchAssistantReply(List<MessageModel> messages) async {
    if (AppStrings.apiKey.trim().isEmpty) {
      return _fetchFreeReply(messages);
    }

    try {
      final response = await http
          .post(
            Uri.parse('${AppStrings.baseUrl}/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppStrings.apiKey}',
            },
            body: jsonEncode({
              'model': AppStrings.model,
              'messages': [
                {"role": "system", "content": AppStrings.systemPrompt},
                ...messages.map((message) => message.toApiMap()),
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return _fetchFreeReply(messages);
      }

      final data = jsonDecode(response.body);
      return (data['choices'][0]['message']['content'] as String).trim();
    } catch (_) {
      return _fetchFreeReply(messages);
    }
  }

  Future<String> _fetchFreeReply(List<MessageModel> messages) async {
    final prompt = _buildPlainPrompt(messages);
    final url = Uri.parse(
      'https://text.pollinations.ai/${Uri.encodeComponent(prompt)}',
    );

    final response =
        await http.get(url).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Free chat failed: ${response.statusCode}');
    }

    return response.body.trim();
  }

  String _buildPlainPrompt(List<MessageModel> messages) {
    final buffer = StringBuffer();
    buffer.writeln('System: ${AppStrings.systemPrompt}');
    for (final message in messages) {
      final role = message.role == 'user' ? 'User' : 'Assistant';
      buffer.writeln('$role: ${message.text}');
    }
    buffer.writeln('Assistant:');
    return buffer.toString();
  }
}
