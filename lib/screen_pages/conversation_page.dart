// conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../managers/language_select_control.dart';
import '../managers/translate_by_googleserver.dart';
import '../screens/speech_recognition_popup.dart';
import 'conversation_area.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();

  String myResultString = "";
  String yourResultString = "";

  Future<void> onPressedRecordingBtn({required bool isMine}) async {
    final currentLangItem = isMine
        ? languageSelectControl.myLanguageItem
        : languageSelectControl.yourLanguageItem;

    String resultStr = await showVoicePopUp(currentLangItem);
    if (resultStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류: 녹음된 내용이 없습니다.")),
      );
      return;
    }

    setState(() {
      if (isMine) {
        myResultString = resultStr;
      } else {
        yourResultString = resultStr;
      }
    });
  }

  Future<String> showVoicePopUp(LanguageItem languageItem) async {
    String speechStr = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 500,
            child: SpeechRecognitionPopUp(
              icon: Icons.mic,
              iconColor: Colors.white,
              backgroundColor: Colors.blue,
              langItem: languageItem,
              fontSize: 26,
              titleText: "Please speak now",
              onCompleted: () {},
              onCanceled: () async {},
            ),
          ),
        );
      },
    ) ?? '';
    return speechStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ConversationArea(
              isMine: false,
              displayText : yourResultString,
              onPressed: () => onPressedRecordingBtn(isMine: false),
            ),
          ),
          Expanded(
            child: ConversationArea(
              isMine: true,
              displayText: myResultString,
              onPressed: () => onPressedRecordingBtn(isMine: true),
            ),
          ),
        ],
      ),
    );
  }
}