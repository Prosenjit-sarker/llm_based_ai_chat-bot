class ImageMessageEntity {
  final String role;
  final String text;
  final String? imageUrl;
  final DateTime time;

  ImageMessageEntity({
    required this.role,
    required this.text,
    required this.time,
    this.imageUrl,
  });

  bool get isUser => role == 'user';
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
}

