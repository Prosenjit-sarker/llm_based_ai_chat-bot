class AppStrings {
  static const String appName = 'AI Chat Bot';
  static const String inputHint = 'Type a message...';
  static const String emptyChat =
      'Start a conversation!\nSend a message below.';

  static const String errorNoInternet =
      'No internet connection. Please check and try again.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorMissingChatApiKey =
      'Missing API key. Run with --dart-define=CHAT_API_KEY=YOUR_KEY';

  // API credentials
  static const String apiKey =
      String.fromEnvironment('CHAT_API_KEY', defaultValue: '');
  static const String baseUrl = 'https://api.durjoyai.com';
  static const String model = 'durjoy-kotha-1';
  static const String systemPrompt =
      'You are a helpful and friendly AI assistant.';




  //Image generation API (open router)
  // Image Generation API
  static const String imageGenApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
  static const String imageGenBaseUrl = 'https://openrouter.ai/api/v1';
  static const String imageGenModel = 'google/gemini-2.5-flash-image';
}
