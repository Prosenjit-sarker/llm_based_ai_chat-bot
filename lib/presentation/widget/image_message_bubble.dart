import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:llm_based_ai_chat_bot/core/constans/app_colors.dart';
import 'package:llm_based_ai_chat_bot/domain/entities/image_message_entity.dart';

class ImageMessageBubble extends StatelessWidget {
  final ImageMessageEntity message;

  const ImageMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 64 : 16,
          right: isUser ? 16 : 64,
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.userBubble : AppColors.botBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.text.trim().isNotEmpty)
              Text(
                message.text,
                style: TextStyle(
                  color: isUser ? AppColors.userText : AppColors.botText,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            if (!isUser && message.hasImage) ...[
              if (message.text.trim().isNotEmpty) const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _ImageView(urlOrData: message.imageUrl!),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              _formatTime(message.time),
              style: const TextStyle(color: AppColors.timestamp, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ImageView extends StatelessWidget {
  final String urlOrData;
  const _ImageView({required this.urlOrData});

  @override
  Widget build(BuildContext context) {
    final trimmed = urlOrData.trim();

    final dataBytes = _tryDecodeDataUrl(trimmed) ?? _tryDecodeRawBase64(trimmed);
    if (dataBytes != null) {
      return Image.memory(
        dataBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _error(),
      );
    }

    return Image.network(
      trimmed,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.black.withValues(alpha: 0.04),
          alignment: Alignment.center,
          child: const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => _error(),
    );
  }

  Widget _error() {
    return Container(
      color: Colors.black.withValues(alpha: 0.04),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Failed to load image',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Uint8List? _tryDecodeDataUrl(String input) {
    if (!input.startsWith('data:image')) return null;
    final commaIndex = input.indexOf(',');
    if (commaIndex < 0) return null;
    final meta = input.substring(0, commaIndex);
    if (!meta.contains('base64')) return null;
    final b64 = input.substring(commaIndex + 1);
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  Uint8List? _tryDecodeRawBase64(String input) {
    final normalized = input.replaceAll('\n', '').replaceAll('\r', '');
    final looksLikeBase64 = RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(normalized) &&
        normalized.length > 256;
    if (!looksLikeBase64) return null;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }
}
