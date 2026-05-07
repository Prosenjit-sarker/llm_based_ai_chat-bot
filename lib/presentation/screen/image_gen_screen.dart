import 'package:flutter/material.dart';
import 'package:llm_based_ai_chat_bot/core/constans/app_colors.dart';
import 'package:llm_based_ai_chat_bot/presentation/provider/image_gen_provider.dart';
import 'package:llm_based_ai_chat_bot/presentation/widget/chat_input_field.dart';
import 'package:llm_based_ai_chat_bot/presentation/widget/empty_chat.dart';
import 'package:llm_based_ai_chat_bot/presentation/widget/error_banner.dart';
import 'package:llm_based_ai_chat_bot/presentation/widget/image_message_bubble.dart';
import 'package:llm_based_ai_chat_bot/presentation/widget/typeing_indicator.dart';
import 'package:provider/provider.dart';

class ImageGenScreen extends StatefulWidget {
  const ImageGenScreen({super.key});

  @override
  State<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends State<ImageGenScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageGenProvider>(
      builder: (context, provider, _) {
        if (provider.messages.isNotEmpty || provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: const [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Gemini Images',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Clear',
                onPressed: provider.messages.isEmpty ? null : provider.clearImages,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              if (provider.errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: ErrorBanner(
                    message: provider.errorMessage!,
                    onDismiss: provider.clearError,
                  ),
                ),
              ],
              Expanded(
                child: provider.messages.isEmpty && !provider.isLoading
                    ? const EmptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: provider.messages.length +
                            (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length) {
                            return const TypingIndicator();
                          }

                          return ImageMessageBubble(
                            message: provider.messages[index],
                          );
                        },
                      ),
              ),
              ChatInputField(
                onSend: provider.generateImage,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
