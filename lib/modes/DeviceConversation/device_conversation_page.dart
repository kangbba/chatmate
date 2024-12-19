import 'dart:async';
import 'package:chatmate/screen_pages/language_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../classes/chat_room.dart';
import '../../classes/dialogue.dart';
import '../../managers/my_auth_provider.dart';
import '../../managers/translate_by_googleserver.dart';
import '../../managers/language_select_control.dart';
import '../../screens/language_select_screen.dart';
import '../../screens/speech_recognition_popup.dart';
import '../../services/volume_control.dart';
import '../DoubleConversation/conversation_area.dart';

class DeviceConversationPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final bool isHost;

  const DeviceConversationPage({Key? key, required this.chatRoom, required this.isHost}) : super(key: key);

  @override
  State<DeviceConversationPage> createState() => _DeviceConversationPageState();
}

class _DeviceConversationPageState extends State<DeviceConversationPage> {

  final MyAuthProvider authProvider = MyAuthProvider.instance;
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();

  TextEditingController _topController = TextEditingController();
  TextEditingController _bottomController = TextEditingController();

  bool isLoading = true;
  Dialogue? latestDialogue;
  StreamSubscription<List<Dialogue>>? dialogueSubscription;

  late LanguageItem currentMyLangItem;
  late LanguageItem currentYourLangItem;
  StreamSubscription<LanguageItem>? myLanguageSubscription;
  StreamSubscription<LanguageItem>? yourLanguageSubscription;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    initializeLanguages();
    initializeDialogues();
    listenToDialogues();

    speechToText.initialize();
    tts.setLanguage(languageSelectControl.yourLanguageItem.sttLangCode!);
    VolumeControl.initialize(
      onVolumeUpPressed:  (){},
      onVolumeDownPressed: ()=> onPressedRecordBtn(),
    );
  }

  @override
  void dispose() {
    dialogueSubscription?.cancel();
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

  Future<void> initializeDialogues() async {
    try {
      final dialogues = await widget.chatRoom.dialoguesStream().first;
      sortDialoguesByCreatedAt(dialogues);
      if (dialogues.isNotEmpty) {
        latestDialogue = dialogues.last;
      }
      isLoading = false;
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing dialogues: $e");
    }
  }

  List<Dialogue> sortDialoguesByCreatedAt(List<Dialogue> dialogues) {
    dialogues.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return dialogues;
  }

  void listenToDialogues() {
    dialogueSubscription = widget.chatRoom.dialoguesStream().listen((dialogues) async {
      if (dialogues.isNotEmpty) {
        dialogues = sortDialoguesByCreatedAt(dialogues);
        if (latestDialogue == null || dialogues.last.id != latestDialogue?.id) {
          latestDialogue = dialogues.last;
          String langCode = latestDialogue!.langCode;
          String content = latestDialogue!.content;

          bool isMyTry = latestDialogue?.ownerUid == authProvider.curUser?.uid;
          if(isMyTry){

          }
          else{
            //전용 기기로부터 정보를 받을때
            if (widget.isHost) {
              debugPrint("전용기기로부터 메세지 수신");
              if(currentYourLangItem.langCodeGoogleServer != langCode){
                String? topTranslation = await googleTranslator.textTranslate(content, currentYourLangItem.langCodeGoogleServer!);
                _topController.text = topTranslation ?? content;
              }
              else{
                _topController.text = content;
              }
              // Update bottom text area with my language
              String? bottomTranslation = await googleTranslator.textTranslate(content, currentMyLangItem.langCodeGoogleServer!);
              _bottomController.text = bottomTranslation ?? content;

              await tts.setLanguage(languageSelectControl.myLanguageItem.ttsLangCode);
              tts.speak(_bottomController.text);
            }
            else{
              debugPrint("모바일로부터 메세지 수신");
              //모바일로부터 정보를 받을때.
              String? bottomTranslation = await googleTranslator.textTranslate(content, currentMyLangItem.langCodeGoogleServer!);
              _bottomController.text = bottomTranslation ?? content;
              await tts.setLanguage(languageSelectControl.myLanguageItem.ttsLangCode);
              tts.speak(_bottomController.text);
            }
            setState(() {});
          }
        }
      }
    });
  }

  Future<void> onPressedRecordBtn() async {
    try {
      if (authProvider.curUserModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to send messages.")),
        );
        return;
      }

      final resultStr = await showVoicePopUp(languageSelectControl.myLanguageItem);
      if (resultStr.isNotEmpty) {
        // Update top text area with your language

        _bottomController.text = resultStr;
        setState(() {

        });
        if(widget.isHost){
          String? topTranslation = await googleTranslator.textTranslate(resultStr, currentYourLangItem.langCodeGoogleServer!);
          _topController.text = topTranslation ?? resultStr;
        }
        setState(() {

        });

        final newDialogue = Dialogue(
          id: DateTime.now().toString(),
          content: resultStr,
          ownerUid: authProvider.curUserModel!.uid,
          langCode: languageSelectControl.myLanguageItem.langCodeGoogleServer!,
          createdAt: DateTime.now(),
        );
        await widget.chatRoom.addDialogue(newDialogue.ownerUid, newDialogue.langCode, newDialogue.content);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error recording or sending message: $e");
    }
  }

  Future<String> showVoicePopUp(LanguageItem languageItem) async {
    final speechStr = await showDialog<String>(
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
              onCompleted: () => {},
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
      body:
      widget.isHost ?
      Stack(
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
                          onPressed: () => onPressedRecordBtn(),
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
        ],
      )
          :
      Column(
        children: [
          // Non-host mode: Single bottom text area
          Expanded(
            child: Container(
              color: Colors.indigo,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        _bottomController.text, // TextField의 내용을 직접 가져오기
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 36, color: Colors.white),
                        softWrap: true, // 줄바꿈 허용
                        overflow: TextOverflow.visible, // 텍스트가 잘리지 않도록 설정
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LanguageSettingScreen(), // 화면 이동
                                ),
                              );
                            },
                            backgroundColor: Colors.blueAccent, // 언어 변환 버튼 배경색
                            child: const Icon(Icons.swap_horiz, color: Colors.white, size: 36), // 언어 변환 아이콘
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: onPressedRecordBtn,
                            backgroundColor: Colors.redAccent, // 버튼 배경색
                            child: const Icon(Icons.mic, color: Colors.white, size: 36), // 아이콘 색상과 크기
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
