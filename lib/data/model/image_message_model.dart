import 'package:llm_based_ai_chat_bot/domain/entities/image_message_entity.dart';

class ImageMessageModel extends ImageMessageEntity {
  ImageMessageModel({
    required super.role,
    required super.text,
    required super.time,
    super.imageUrl,
  });
}

