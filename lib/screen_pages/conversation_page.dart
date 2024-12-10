// conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../managers/language_select_control.dart';
import '../managers/translate_by_googleserver.dart';
import '../screens/language_select_screen.dart';
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
    setupVolumeButtons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initializeTTS() async {
    tts.setLanguage(languageSelectControl.yourLanguageItem.sttLangCode!);
  }

  void setupVolumeButtons() {
    HardwareButtons.volumeButtonEvents.listen((event) {
      if (event == VolumeButtonEvent.VOLUME_UP) {
        onPressedRecordingBtn(isMine: false);
      } else if (event == VolumeButtonEvent.VOLUME_DOWN) {
        onPressedRecordingBtn(isMine: true);
      }
    });
  }

  Future<void> onPressedRecordingBtn({required bool isMine}) async {
    if (isMyRecording || isYourRecording) return; // 비활성화 상태에서 실행 방지

    final currentLangItem = isMine
        ? languageSelectControl.myLanguageItem
        : languageSelectControl.yourLanguageItem;


    String othersSttLangCode = isMine ? languageSelectControl.yourLanguageItem.sttLangCode!
        : languageSelectControl.myLanguageItem.sttLangCode!;
    String othersGoogleLangCode = isMine ? languageSelectControl.yourLanguageItem.langCodeGoogleServer!
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
            // 자동으로 녹음 중단 처리
            onPressedStopBtn(isMine: isMine);

            String resultStr = result.recognizedWords;;

            // 번역 수행
            String? translation = await googleTranslator.textTranslate(
              resultStr,
              othersGoogleLangCode,
            );
            if (translation != null && translation.isNotEmpty) {
              debugPrint("Translation Succeed: $translation");
              if (isMine) {
                yourResultString = translation;
              } else {
                myResultString = translation;
              }
              setState(() {
              });

              if (await Vibration.hasVibrator() ?? false) {
                Vibration.vibrate(duration: 100);
              }

              tts.speak(translation ?? "");
            } else {
              debugPrint("Translation Failed: $translation");
              if (isMine) {
                myResultString = originalString;
              } else {
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

  void showVolumeSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Volume Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: 0.5, // Replace with current volume value
                onChanged: (value) {
                  // Update volume value logic here
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: "50%",
              ),
              const Text("Adjust your device's volume.")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
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
              buildLanguageLayout(),
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
          Positioned(
            top: 30,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              onPressed: showVolumeSettingsDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLanguageLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: StreamBuilder<LanguageItem>(
            stream: languageSelectControl.myLanguageItemStream,
            initialData: languageSelectControl.myLanguageItem,
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectScreen(
                      languageSelectControl: languageSelectControl,
                      isMyLanguage: true,
                    ),
                  ),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    snapshot.data?.menuDisplayStr ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.indigo, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              final temp = languageSelectControl.myLanguageItem;
              languageSelectControl.myLanguageItem = languageSelectControl.yourLanguageItem;
              languageSelectControl.yourLanguageItem = temp;
            });
          },
          child: Container(
            width: 50,
            height: 54,
            color: Colors.black38,
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
        ),
        Expanded(
          child: StreamBuilder<LanguageItem>(
            stream: languageSelectControl.yourLanguageItemStream,
            initialData: languageSelectControl.yourLanguageItem,
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectScreen(
                      languageSelectControl: languageSelectControl,
                      isMyLanguage: false,
                    ),
                  ),
                ),
                child: Container(
                  color: Colors.indigo,
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    snapshot.data?.menuDisplayStr ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}