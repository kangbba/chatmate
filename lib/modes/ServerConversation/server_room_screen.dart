import 'dart:async';
import '../../custom_widget/room_drawer.dart';
import 'server_conversation_page.dart';
import 'package:flutter/material.dart';
import '../../classes/chat_room.dart';
import '../../classes/user_model.dart';
import '../../classes/room_settings.dart';
import '../../managers/my_auth_provider.dart';

class ServerRoomScreen extends StatefulWidget {
  final ChatRoom chatRoomToLoad;

  ServerRoomScreen({Key? key, required this.chatRoomToLoad}) : super(key: key);

  @override
  State<ServerRoomScreen> createState() => _ServerRoomScreenState();
}

class _ServerRoomScreenState extends State<ServerRoomScreen> {
  ChatRoom? chatRoom;
  bool isEntered = false;
  final MyAuthProvider authProvider = MyAuthProvider.instance;
  StreamSubscription<List<UserModel>>? _userModelsSubscription;
  List<UserModel> userModels = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<double> myVolumeNotifier = ValueNotifier(RoomSettings().myVolume);
  final ValueNotifier<double> otherVolumeNotifier = ValueNotifier(RoomSettings().otherVolume);


  @override
  void initState() {
    super.initState();
    initializeChatRoom();
    listenToUserModels();
  }

  // 채팅방 초기화
  Future<void> initializeChatRoom() async {
    final userModel = authProvider.curUserModel;
    if (userModel != null) {
      final isJoined = await widget.chatRoomToLoad.joinRoom(userModel);
      if (isJoined) {
        chatRoom = widget.chatRoomToLoad;
        isEntered = true;
        setState(() {
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  // 멤버 리스트 스트림 구독
  void listenToUserModels() {
    _userModelsSubscription = widget.chatRoomToLoad.userModelsStream.listen((updatedUserModels) {
      setState(() {
        userModels = updatedUserModels;
      });

      // 조건에 따라 로그 출력
      final myUid = authProvider.curUserModel?.uid;

      if (updatedUserModels.isEmpty && isEntered) {
        debugPrint("Log: userModels count is 0.");
        Navigator.of(context).pop();
      }
      // else if (myUid != null && !updatedUserModels.any((user) => user.uid == myUid)) {
      //   debugPrint("Log: Current user is not in the userModels list.");
      //   Navigator.of(context).pop();
      // }
    });
  }

  @override
  void dispose() {
    _userModelsSubscription?.cancel();
    super.dispose();
  }

  // 나가기 버튼 기능
  Future<void> exitRoom() async {
    if (authProvider.curUserModel != null) {
      await chatRoom?.exitRoom(authProvider.curUserModel!);
      Navigator.pop(context);
    }
  }

  void saveVolumeSettings() {
    RoomSettings().myVolume = myVolumeNotifier.value;
    RoomSettings().otherVolume = otherVolumeNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: StreamBuilder<List<UserModel>>(
          stream: chatRoom?.userModelsStream,
          builder: (context, snapshot) {
            final memberCount = snapshot.data?.length ?? 0;
            return Text("${chatRoom?.name ?? 'Loading...'} ($memberCount)");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: RoomDrawer(chatRoom: widget.chatRoomToLoad),
      body: chatRoom == null
          ? Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Expanded(child: ServerConversationPage(chatRoom: widget.chatRoomToLoad)),
            ],
          ),
    );
  }
  Widget volumeSlider(String title, ValueNotifier<double> volumeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14)),
          ValueListenableBuilder<double>(
            valueListenable: volumeNotifier,
            builder: (context, currentValue, child) {
              return Slider(
                value: currentValue,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  volumeNotifier.value = value;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Drawer가 닫힐 때 RoomSettings에 볼륨 값을 저장
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    saveVolumeSettings();
  }
}
