import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가

import '../managers/language_select_control.dart';
import '../managers/translate_by_googleserver.dart';
import '../screens/speech_recognition_popup.dart';
import 'language_setting_screen.dart';

class TranslatingPage extends StatefulWidget {
  const TranslatingPage({super.key});

  @override
  State<TranslatingPage> createState() => _TranslatingPageState();
}

class _TranslatingPageState extends State<TranslatingPage> {
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TextEditingController _topController = TextEditingController();
  final TextEditingController _bottomController = TextEditingController();
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();
  late LanguageItem currentMyLangItem;
  late LanguageItem currentYourLangItem;
  StreamSubscription<LanguageItem>? myLanguageSubscription;
  StreamSubscription<LanguageItem>? yourLanguageSubscription;
  bool isRecordingBtnPressed = false;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    initializeLanguages();
    loadLastTranslation(); // 최근 번역된 내용 로드
  }

  Future<void> initializeLanguages() async {
    try {
      currentMyLangItem = languageSelectControl.myLanguageItem;
      currentYourLangItem = languageSelectControl.yourLanguageItem;
    } catch (e) {
      debugPrint("AudiencePage: Error loading initializeLanguages - $e");
    }
    tts.setLanguage(currentYourLangItem.ttsLangCode);
    setState(() {});
    listenToMyLanguageChanges();
    listenToYourLanguageChanges();
  }

  void listenToMyLanguageChanges() {
    myLanguageSubscription = languageSelectControl.myLanguageItemStream.listen((languageItem) async {
      currentMyLangItem = languageItem;
      setState(() {});
    });
  }

  void listenToYourLanguageChanges() {
    yourLanguageSubscription = languageSelectControl.yourLanguageItemStream.listen((languageItem) async {
      currentYourLangItem = languageItem;
      setState(() {});
    });
  }

  Future<void> saveLastTranslation(String original, String translation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOriginalText', original);
    await prefs.setString('lastTranslatedText', translation);
  }

  Future<void> loadLastTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOriginal = prefs.getString('lastOriginalText') ?? '';
    final lastTranslated = prefs.getString('lastTranslatedText') ?? '';
    setState(() {
      _bottomController.text = lastOriginal;
      _topController.text = lastTranslated;
    });
  }

  @override
  void dispose() {
    myLanguageSubscription?.cancel();
    yourLanguageSubscription?.cancel();
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
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
                onCompleted: () => (),
                onCanceled: () async {}),
          ),
        );
      },
    ) ?? '';
    return speechStr;
  }

  Widget _audioRecordBtn() {
    return RippleAnimation(
      color: Colors.blue,
      delay: const Duration(milliseconds: 200),
      repeat: true,
      minRadius: isRecordingBtnPressed ? 35 : 0,
      ripplesCount: 8,
      duration: const Duration(milliseconds: 6 * 300),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(55, 55)),
          shape: MaterialStateProperty.all(const CircleBorder()),
          backgroundColor: MaterialStateProperty.all(Colors.redAccent),
        ),
        onPressed: () async {
          try {
            tts.setLanguage(currentYourLangItem.langCodeGoogleServer!);

            String resultStr = await showVoicePopUp(currentMyLangItem);
            if (resultStr.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("오류: 녹음된 내용이 없습니다.")),
              );
              return;
            }

            // 녹음된 텍스트를 아래 텍스트 필드에 표시
            setState(() {
              _bottomController.text = resultStr;
            });

            String? translation = await googleTranslator.textTranslate(resultStr, currentYourLangItem.langCodeGoogleServer!);

            // 번역된 텍스트를 위 텍스트 필드에 표시
            setState(() {
              _topController.text = translation ?? '';
            });

            // 저장
            await saveLastTranslation(resultStr, translation ?? '');

            tts.speak(translation ?? '');
          } catch (e) {
          }
        },
        child: isRecordingBtnPressed
            ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white)
            : const Icon(Icons.mic, color: Colors.white, size: 33),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 주요 콘텐츠
          Column(
            children: [
              Expanded(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  color: Colors.indigo,
                                  child: TextField(
                                    controller: _topController,
                                    readOnly: true,
                                    maxLines: null,
                                    expands: true,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                  child: TextField(
                                    controller: _bottomController,
                                    readOnly: true,
                                    maxLines: null,
                                    expands: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: '마이크 버튼을 눌러 번역 시작',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          // 뒤로가기 버튼
          Positioned(
            top: 30, // 화면 상단에서의 간격
            left: 10, // 화면 왼쪽에서의 간격
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 동작
              },
            ),
          ),
          // 언어 설정 버튼
          Positioned(
            top: 30, // 화면 상단에서의 간격
            right: 10, // 화면 오른쪽에서의 간격
            child: IconButton(
              icon: const Icon(Icons.language, color: Colors.white, size: 40),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const LanguageSettingScreen();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _audioRecordBtn(),
    );
  }

}
