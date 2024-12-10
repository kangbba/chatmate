import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import '../secrets/secret_keys.dart';

class TranslateByGoogleServer {
  late Translation _translation;

  initializeTranslateByGoogleServer() {
    _translation = Translation(apiKey: googleTranslationApiKey);
  }

  Future<String?> textTranslate(String inputStr, String to) async {
    try {
      final translationModel = await _translation.translate(text: inputStr, to: to);
      return translationModel.translatedText;
    } on Exception catch (e) {
      debugPrint('Translation error: $e');
      return null;

    }
  }
}
