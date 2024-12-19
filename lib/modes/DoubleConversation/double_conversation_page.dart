// double_conversation_page.dart
import 'package:chatmate/services/vibrate_utils.dart';
import 'package:chatmate/services/volume_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/services.dart';
import '../../managers/language_select_control.dart';
import '../../managers/translate_by_googleserver.dart';
import '../../screens/language_select_screen.dart';
import 'conversation_area.dart';

class DoubleConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<DoubleConversationPage> {
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();

  String myResultString = "마이크 버튼을 눌러 시작";
  String yourResultString = "";
  bool isMyRecording = false;
  bool isYourRecording = false;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    speechToText.initialize();
    initializeTTS();
    VolumeControl.initialize(
        onVolumeUpPressed: ()=> onPressedRecordingBtn(isMine: false),
        onVolumeDownPressed: ()=> onPressedRecordingBtn(isMine: true),
    );
  }

  @override
  void dispose() {
    VolumeControl.dispose();
    super.dispose();
  }

  initializeTTS() async {
    tts.setLanguage(languageSelectControl.yourLanguageItem.sttLangCode!);
  }

  Future<void> onPressedRecordingBtn({required bool isMine}) async {
    if (isMyRecording || isYourRecording) return; // 비활성화 상태에서 실행 방지

    final currentLangItem = isMine
        ? languageSelectControl.myLanguageItem
        : languageSelectControl.yourLanguageItem;

    String othersSttLangCode = isMine
        ? languageSelectControl.yourLanguageItem.sttLangCode!
        : languageSelectControl.myLanguageItem.sttLangCode!;
    String othersGoogleLangCode = isMine
        ? languageSelectControl.yourLanguageItem.langCodeGoogleServer!
        : languageSelectControl.myLanguageItem.langCodeGoogleServer!;

    if (!speechToText.isAvailable) {
      await speechToText.initialize();
    }
    tts.setLanguage(othersSttLangCode);

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
            onPressedStopBtn(isMine: isMine);
            String resultStr = result.recognizedWords;

            String? translation = await googleTranslator.textTranslate(
              resultStr,
              othersGoogleLangCode,
            );
            if (translation != null && translation.isNotEmpty) {
              VibrationUtils.vibrate();
              debugPrint("Translation Succeed: $translation");
              if (isMine) {
                yourResultString = translation;
              } else {
                myResultString = translation;
              }
              setState(() {});
              tts.speak(translation ?? "");
            } else {
              debugPrint("Translation Failed: $translation");
              if (isMine) {
                myResultString = originalString;
              } else {
                yourResultString = originalString;
              }
              setState(() {});
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
      body: Stack(
        children: [
          Column(
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
          Positioned(
            top: 30,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              switchBtn(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  languageDisplayer(false, Colors.indigo, Colors.white),
                  languageDisplayer(true, Colors.white, Colors.indigo),
                ],
              ),
              SizedBox(
                width: 24,
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget switchBtn() {
    return InkWell(
      onTap: () {
        setState(() {
          final temp = languageSelectControl.myLanguageItem;
          languageSelectControl.myLanguageItem = languageSelectControl.yourLanguageItem;
          languageSelectControl.yourLanguageItem = temp;

          final temp2 = myResultString;
          myResultString = yourResultString;
          yourResultString = temp2;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle, // 원형으로 변경
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // 그림자 색상
              offset: Offset(2, 2), // 그림자의 위치
              blurRadius: 8, // 흐림 정도
              spreadRadius: 1, // 그림자 확산 정도
            ),
          ],
        ),
        child: const Icon(Icons.swap_vert, color: Colors.white, size: 24),
      ),
    );
  }

  Widget languageDisplayer(bool isMine, Color backgroundColor, Color textColor){
    return StreamBuilder<LanguageItem>(
      stream: isMine ? languageSelectControl.myLanguageItemStream : languageSelectControl.yourLanguageItemStream,
      initialData: isMine ? languageSelectControl.myLanguageItem : languageSelectControl.yourLanguageItem,
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageSelectScreen(
                languageSelectControl: languageSelectControl,
                isMyLanguage: isMine,
              ),
            ),
          ),
          child: Container(
            color: backgroundColor,
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Text(
              snapshot.data?.menuDisplayStr ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
