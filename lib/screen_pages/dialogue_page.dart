import 'dart:async';
import '../classes/room_settings.dart';
import '../custom_widget/simple_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; // 추가된 패키지 import
import '../classes/chat_room.dart';
import '../classes/dialogue.dart';
import '../classes/user_model.dart';
import '../custom_widget/dialogue_tile.dart';
import '../managers/my_auth_provider.dart';
import '../managers/translate_by_googleserver.dart';
import '../managers/language_select_control.dart';
import '../screens/language_select_screen.dart';
import '../screens/speech_recognition_popup.dart';

class DialoguePage extends StatefulWidget {
  final ChatRoom chatRoom;
  const DialoguePage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<DialoguePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<DialoguePage> {
  final MyAuthProvider authProvider = MyAuthProvider.instance;
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();
  final ItemScrollController _itemScrollController = ItemScrollController();
  Map<int, UserModel?> cachedUserModels = {}; // index별로 user data cache 유지

  List<Dialogue> dialogues = [];
  Map<String, Map<String, String>> translatedDialogues = {};
  bool isLoading = true;
  bool isRecordingBtnPressed = false;

  StreamSubscription<List<Dialogue>>? _dialogueSubscription;
  StreamSubscription<LanguageItem>? _languageSubscription;
  late LanguageItem curLangItem;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    initializeLanguages();
    initializeDialogues(languageSelectControl.myLanguageItem);
  }

  @override
  void dispose() {
    _dialogueSubscription?.cancel();
    _languageSubscription?.cancel();
    super.dispose();
  }

  void scrollToEnd(int delayMilliSec) async{
    await Future.delayed(Duration(milliseconds: delayMilliSec));
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: dialogues.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Languages 초기화
  Future<void> initializeLanguages() async {
    try {
      curLangItem = languageSelectControl.myLanguageItem;
    } catch (e) {
      debugPrint("AudiencePage: Error loading initializeLanguages - $e");
    }
    tts.setLanguage(languageSelectControl.myLanguageItem.ttsLangCode);
    setState(() {});
    listenToLanguageChanges();
  }

  void listenToLanguageChanges() {
    _languageSubscription = languageSelectControl.myLanguageItemStream.listen((languageItem) async {
      curLangItem = languageItem;
      translatedDialogues.clear();
      tts.setLanguage(languageItem.ttsLangCode);
      await translateAllDialogues(languageItem.langCodeGoogleServer);
      setState(() {});
    });
  }

  void sortDialoguesByCreatedAt(List<Dialogue> dialogues) {
    dialogues.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Dialogues 초기화
  Future<void> initializeDialogues(LanguageItem? initialLanguageItem) async {
    try {
      dialogues = await widget.chatRoom.dialoguesStream().first;
      sortDialoguesByCreatedAt(dialogues);
      isLoading = false;
      await translateAllDialogues(initialLanguageItem?.langCodeGoogleServer);
      listenToDialogueStream();
      setState(() {});
    } catch (e) {
      debugPrint("AudiencePage: Error loading initial dialogues - $e");
    }
  }

  void listenToDialogueStream() {
    _dialogueSubscription = widget.chatRoom.dialoguesStream().listen(
          (dialogueList) async {
        final currentIds = dialogues.map((d) => d.id).toSet();
        final newDialogues = dialogueList.where((d) => !currentIds.contains(d.id)).toList();

        if (newDialogues.isNotEmpty) {
          sortDialoguesByCreatedAt(newDialogues);
          dialogues.addAll(newDialogues);
          debugPrint("AudiencePage: New dialogues received, count: ${newDialogues.length}");

          String lastTranslation = '';
          for (var dialogue in newDialogues) {
            lastTranslation = await translateDialogue(dialogue, curLangItem!.langCodeGoogleServer!);
          }
          setState(() {

          });
          scrollToEnd(1000);
          if (lastTranslation.isNotEmpty) {
            debugPrint("tts to speak : $lastTranslation");
            bool isMyDialogue = newDialogues.last.ownerUid == authProvider.curUserModel?.uid;
            await tts.setLanguage(curLangItem.ttsLangCode);
            await tts.setVolume(isMyDialogue ? RoomSettings().myVolume : RoomSettings().otherVolume);
            tts.speak(lastTranslation);
          }
        }
      },
      onError: (error) {
        debugPrint("AudiencePage: Error in dialogue stream - $error");
      },
      onDone: () {
        debugPrint("AudiencePage: Dialogue stream closed.");
      },
    );
  }

  Future<String> translateDialogue(Dialogue dialogue, String targetLangCode) async {
    final translatedData = translatedDialogues[dialogue.id];
    if (translatedData != null && translatedData['langCode'] == targetLangCode) {
      return dialogue.content;
    }

    try {
      final translation = await googleTranslator.textTranslate(dialogue.content, targetLangCode);
      translatedDialogues[dialogue.id] = {
        'text': translation ?? dialogue.content,
        'langCode': targetLangCode
      };
      return translation ?? '';
    } catch (e) {
      debugPrint("Translation error for '${dialogue.content}': $e");
      translatedDialogues[dialogue.id] = {
        'text': dialogue.content,
        'langCode': dialogue.langCode
      };
      return dialogue.content;
    }
  }

  Future<void> translateAllDialogues(String? targetLangCode) async {
    if (targetLangCode == null) return;
    if (dialogues.isEmpty){
      return;
    }
    for (var dialogue in dialogues) {
      await translateDialogue(dialogue, targetLangCode);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("대화를 번역하는 중입니다."),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
      ));
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: onPressedRecordBtn,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: dialogues.isEmpty
                ? const Center(child: Text('대화 내역이 없습니다'))
                : ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemCount: dialogues.length,
              itemBuilder: (context, index) {
                final dialogue = dialogues[index];
                final translatedData = translatedDialogues[dialogue.id];
                final translatedText = translatedData?['text'] ?? dialogue.content;
                final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dialogue.createdAt);

                // FutureBuilder 내에서 로딩 중 또는 오류가 있을 때 이전 데이터를 유지
                return FutureBuilder<UserModel?>(
                  future: widget.chatRoom.getUserByUid(dialogue.ownerUid),
                  builder: (context, snapshot) {
                    final userModel = snapshot.data ?? cachedUserModels[index];

                    if (userModel != null) {
                      cachedUserModels[index] = userModel; // 데이터를 캐시에 저장하여 유지
                      return DialogueTile(
                        isMine: dialogue.ownerUid == authProvider.curUserModel?.uid,
                        userModel: userModel,
                        text: translatedText,
                        date: formattedDate,
                        onTap: () => showDialogueDetails(context, userModel, dialogue), // 팝업 호출

                      );
                    }
                    return const SizedBox.shrink(); // 사용자 정보가 완전히 없을 때는 빈 위젯 반환
                  },
                );
              },
            ),
          ),
          IconButton(onPressed: () => scrollToEnd(100), icon: Icon(Icons.keyboard_arrow_down)),
          SimpleSeparator(color: Colors.black12, height: 1, top: 16, bottom: 8),
        ],
      ),
    );
  }
  //


  void showDialogueDetails(BuildContext context, UserModel userModel, Dialogue dialogue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5, // 화면의 절반 크기 설정
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Original Sentences:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1.0),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Text(
                      dialogue.content,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const Divider(thickness: 1.0),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Speaker", style: TextStyle(fontSize: 12),),
                  subtitle: Text(
                    userModel.displayName.isNotEmpty ? userModel.displayName : userModel.uid, style: TextStyle(fontSize: 10),),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Original Language", style: TextStyle(fontSize: 12),),
                  subtitle: Text(dialogue.langCode, style: TextStyle(fontSize: 10),),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    child: const Text("Close", style: TextStyle(fontSize: 16),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget languageSelectScreenBtn() {
    return InkWell(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("   ${ LanguageSelectControl.instance.myLanguageItem.menuDisplayStr}"),
            SizedBox(height: 8,),
            Text( " 언어 변경 ", textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        onTap: () async {
          late LanguageSelectScreen myLanguageSelectScreen =
          LanguageSelectScreen(

            languageSelectControl: LanguageSelectControl.instance, isMyLanguage: true,
          );
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: myLanguageSelectScreen,
                ),
              );
            },
          );
          setState(() {

          });
        }
    );
  }


  onPressedRecordBtn() async{
    try {
      if (authProvider.curUserModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: 로그인 상태가 아닙니다. 로그인 후 시도해주세요.")),
        );
        return;
      }

      if (curLangItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: 언어 설정이 선택되지 않았습니다.")),
        );
        return;
      }

      String resultStr = await showVoicePopUp(curLangItem!);
      if (resultStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: 녹음된 내용이 없습니다.")),
        );
        return;
      }

      await widget.chatRoom.addDialogue(
        authProvider.curUserModel!.uid,
        curLangItem!.sttLangCode!,
        resultStr,
      );

      setState(() {});
    } catch (e) {
      debugPrint("AudioRecordBtn: Error adding dialogue - $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류: 대화를 추가하는 중 문제가 발생했습니다.")),
      );
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
}
