import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:llm_based_ai_chat_bot/core/constans/app_strings.dart';
import 'package:llm_based_ai_chat_bot/data/model/image_message_model.dart';

import '../../data/service/image_gen_api_service.dart';

class ImageGenProvider extends ChangeNotifier {
  ImageGenProvider({ImageGenApiService? service})
      : _service = service ?? ImageGenApiService();

  final ImageGenApiService _service;
  final List<ImageMessageModel> _messages = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<ImageMessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> generateImage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    _messages.add(
      ImageMessageModel(role: 'user', text: prompt, time: DateTime.now()),
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final assistantMessage = await _service.generateImage(prompt);
      _messages.add(assistantMessage);
    } on TimeoutException {
      _errorMessage = AppStrings.errorTimeout;
    } on SocketException {
      _errorMessage = AppStrings.errorNoInternet;
    } catch (_) {
      _errorMessage = AppStrings.errorGeneral;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearImages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
