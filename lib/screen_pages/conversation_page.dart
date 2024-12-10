// conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../managers/language_select_control.dart';
import '../managers/translate_by_googleserver.dart';
import 'conversation_area.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();

  String myResultString = "Start speaking...";
  String yourResultString = "Waiting for input...";
  bool isMyRecording = false;
  bool isYourRecording = false;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    speechToText.initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onPressedRecordingBtn({required bool isMine}) async {
    if (isMyRecording || isYourRecording) return; // 비활성화 상태에서 실행 방지

    final currentLangItem = isMine
        ? languageSelectControl.myLanguageItem
        : languageSelectControl.yourLanguageItem;

    if (!speechToText.isAvailable) {
      await speechToText.initialize();
    }

    if (speechToText.isAvailable) {
      setState(() {
        if (isMine) {
          isMyRecording = true;
        } else {
          isYourRecording = true;
        }
      });

      String originalString = isMine ? myResultString : yourResultString;
      speechToText.listen(
        onResult: (result) async {
          _handleSpeechResult(result, isMine);
          if (result.finalResult) {
            // 자동으로 녹음 중단 처리
            onPressedStopBtn(isMine: isMine);

            String resultStr = result.recognizedWords;
            String othersSttLangCode = isMine ? languageSelectControl.yourLanguageItem.sttLangCode!
                : languageSelectControl.myLanguageItem.sttLangCode!;
            String othersGoogleLangCode = isMine ? languageSelectControl.yourLanguageItem.langCodeGoogleServer!
                : languageSelectControl.myLanguageItem.langCodeGoogleServer!;

            // 번역 수행
            String? translation = await googleTranslator.textTranslate(
              resultStr,
              othersGoogleLangCode,
            );
            if(translation != null && translation.isNotEmpty){
              debugPrint("Translation Succeed: $translation");
              if(isMine){
                yourResultString = translation;
              }
              else{
                myResultString = translation;
              }
              setState(() {
              });

              // 번역된 텍스트를 음성으로 출력
              await tts.setLanguage(othersSttLangCode);
              tts.speak(translation ?? "");
            }
            else{
              debugPrint("Translation Failed: $translation");
              if(isMine){
                myResultString = originalString;
              }
              else{
                yourResultString = originalString;
              }
              setState(() {
              });
            }
          }
        },
        localeId: currentLangItem.sttLangCode,
      );
    }
  }

  void onPressedStopBtn({required bool isMine}) {
    if (isMine ? isMyRecording : isYourRecording) {
      setState(() {
        if (isMine) {
          isMyRecording = false;
        } else {
          isYourRecording = false;
        }
      });
      debugPrint("Recording stopped for ${isMine ? "my" : "your"} side.");
      speechToText.stop();
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result, bool isMine) {
    setState(() {
      if (isMine) {
        myResultString = result.recognizedWords;
      } else {
        yourResultString = result.recognizedWords;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ConversationArea(
              isMine: false,
              text: yourResultString,
              isRecording: isYourRecording,
              isDisabled: isMyRecording,
              onPressed: () => onPressedRecordingBtn(isMine: false),
              onPressedStop: () => onPressedStopBtn(isMine: false),
            ),
          ),
          Expanded(
            child: ConversationArea(
              isMine: true,
              text: myResultString,
              isRecording: isMyRecording,
              isDisabled: isYourRecording,
              onPressed: () => onPressedRecordingBtn(isMine: true),
              onPressedStop: () => onPressedStopBtn(isMine: true),
            ),
          ),
        ],
      ),
    );
  }
}