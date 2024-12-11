import 'dart:async';

import 'package:chatmate/screen_pages/conversation_area.dart';
import 'package:chatmate/services/vibrate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가

import '../managers/language_select_control.dart';
import '../managers/translate_by_googleserver.dart';
import '../screens/language_select_screen.dart';
import '../screens/speech_recognition_popup.dart';
import '../services/volume_control.dart';
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
    VolumeControl.initialize(
      onVolumeUpPressed: (){},
      onVolumeDownPressed: ()=> onPressedRecordingBtn(),
    );
  }

  @override
  void dispose() {
    VolumeControl.dispose();
    myLanguageSubscription?.cancel();
    yourLanguageSubscription?.cancel();
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
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


  onPressedRecordingBtn() async{
    if(isRecordingBtnPressed){
      return;
    }
    try {
      tts.setLanguage(currentYourLangItem.langCodeGoogleServer!);

      isRecordingBtnPressed = true;
      String resultStr = await showVoicePopUp(currentMyLangItem);
      if (resultStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("오류: 녹음된 내용이 없습니다.")),
        );
        isRecordingBtnPressed = false;
        return;
      }
      isRecordingBtnPressed = false;

      // 녹음된 텍스트를 아래 텍스트 필드에 표시
      setState(() {
        _bottomController.text = resultStr;
      });

      String? translation = await googleTranslator.textTranslate(resultStr, currentYourLangItem.langCodeGoogleServer!);
      VibrationUtils.vibrate();
      // 번역된 텍스트를 위 텍스트 필드에 표시
      setState(() {
        _topController.text = translation ?? '';
      });

      // 저장
      await saveLastTranslation(resultStr, translation ?? '');

      tts.speak(translation ?? '');
    } catch (e) {
      isRecordingBtnPressed = false;
    }
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
          onPressedRecordingBtn();
        },
        child: isRecordingBtnPressed
            ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white)
            : const Icon(Icons.mic, color: Colors.white, size: 33),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.indigo,
                    child:
                    ConversationArea(isMine: false, text: _topController.text, isRecording: false, isDisabled: false, onPressed: null, onPressedStop: (){})
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        ConversationArea(
                            isMine: true,
                            text: _bottomController.text,
                            isRecording: false,
                            isDisabled: false,
                            onPressed: () => onPressedRecordingBtn(),
                            onPressedStop: (){}
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

            Positioned(left : 8, top : 20, child: backBtn()),
          ],
        ),
      ),
    );
  }
  Widget backBtn(){
    // 뒤로가기 버튼
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
      onPressed: () {
        Navigator.pop(context); // 뒤로가기 동작
      },
    );
  }

  Widget switchBtn() {
    return InkWell(
      onTap: () {
        setState(() {
          final temp = languageSelectControl.myLanguageItem;
          languageSelectControl.myLanguageItem = languageSelectControl.yourLanguageItem;
          languageSelectControl.yourLanguageItem = temp;

          final temp2 = _topController.text;
          _topController.text = _bottomController.text;
          _bottomController.text = temp2;
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
