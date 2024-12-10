import 'dart:ui';

import 'package:chatmate/screen_pages/room_title_setting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../custom_widget/simple_dialog.dart';
import '../managers/my_auth_provider.dart';
import '../managers/chat_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../custom_widget/profile_circle_stack.dart';
import '../managers/network_checking_service.dart';
import '../screens/room_screen.dart';

class RoomSelectingPage extends StatefulWidget {
  const RoomSelectingPage({Key? key}) : super(key: key);

  @override
  State<RoomSelectingPage> createState() => _RoomSelectingPageState();
}

class _RoomSelectingPageState extends State<RoomSelectingPage>{
  NetworkCheckingService networkCheckingService = NetworkCheckingService();
  final _authProvider = MyAuthProvider.instance;
  final _chatProvider = ChatProvider.instance;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 1,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Padding(padding: EdgeInsets.only(left: 5, top: 1),
                    child: const Icon(Icons.add, size: 30, color: Colors.white)),
                const Icon(Icons.chat_bubble_outline_sharp, size: 40, color: Colors.white,),
              ],
            ),
            onPressed: () async {
              onPressedCreateChatRoomBtn();
            },
          )
        ],
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatProvider.chatRoomsStream(),
        initialData: [],
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Error: hasData is false'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<ChatRoom> chatRooms = snapshot.data!;
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return StreamBuilder<List<UserModel>>(
                  stream: chatRoom.userModelsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 10);
                    }
                    return Slidable(
                      key: Key(chatRoom.id),
                      endActionPane: ActionPane(
                        extentRatio: 0.2,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              chatRoom.exitRoom(UserModel.fromFirebaseUser(_authProvider.curUser!));
                            },
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: '삭제',
                          ),
                        ],
                      ),
                      child: chatRoomListTile(chatRoom, snapshot.data!, context),
                    );
                  });
            },
          );
        },
      ),
    );
  }

  void onPressedCreateRoom() {
    // 방 만들기 버튼 클릭 시 동작 추가
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Room'),
          content: const Text('방 만들기 기능을 구현하세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget chatRoomListTile(ChatRoom chatRoom, List<UserModel> userModels, BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: ListTile(
          title: SizedBox(width: 200, child: Text(chatRoom.name)),
          leading: ProfileCircleStack(users: [chatRoom.host], maxRectangleSize: 45),
          subtitle: Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(scale: 0.8, child: const Icon(Icons.account_box)),
                  Text(chatRoom.host.displayName, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(scale: 0.8, child: const Icon(Icons.people_alt)),
                  Text('${userModels.length}', style: const TextStyle(fontSize: 13)),
                ],
              )
            ],
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomScreen(chatRoomToLoad: chatRoom),
              ),
            );
          },
        ),
      ),
    );
  }
  void onPressedCreateChatRoomBtn() async{
    bool networkAvailable = await networkCheckingService.isInternetConnectionAvailable();
    if(!networkAvailable){
      await sayneConfirmDialog(context, "", "네트워크 상태를 확인해주세요");
      return;
    }
    String? roomTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: RoomTitleSettingPage(),
        );
      },
    );
    if (roomTitle != null && roomTitle.isNotEmpty) {
      ChatRoom? chatRoom = await _chatProvider.createChatRoom(
        roomTitle,
        _authProvider.curUserModel!,
      );
      if(chatRoom == null){
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            chatRoomToLoad: chatRoom,
          ),
        ),
      );
    }
  }
}
