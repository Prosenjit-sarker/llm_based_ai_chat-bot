import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({required super.role, required super.text, required super.time});
  // sample -- > ui without macking a real api call
  factory MessageModel.sampleUser() => MessageModel(
        role: 'user',
        text: 'Hello! what can you help me with?',
        time: DateTime.now(),
      );
  factory MessageModel.sampleBot() => MessageModel(
        role: 'assistant',
        text: 'Hi there! I am you AI assistant. Ask me anything',
        time: DateTime.now(),
      );
  // Converts to the format that api expects
  Map<String, String> toApiMap() => {'role': role, 'content': text};
}
