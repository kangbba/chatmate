import 'package:chatmate/classes/chat_room.dart';
import 'package:chatmate/custom_widget/simple_separator.dart';
import 'package:chatmate/modes/DeviceConversation/device_conversation_page.dart';
import 'package:chatmate/modes/DoubleConversation/double_conversation_page.dart';
import 'package:flutter/material.dart';
import '../managers/chat_provider.dart';
import '../managers/my_auth_provider.dart';
import '../modes/DeviceConversation/device_room_list.dart';
import '../modes/SoloConversation/solo_conversation_page.dart';
import '../modes/ServerConversation/server_room_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final _authProvider = MyAuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 2:1 비율의 위쪽 Column
          SizedBox(
            height: 60,
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ChatUS",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // 임의의 로고 이미지, Image.asset로 대체 가능
                const Icon(
                  Icons.language, // 로고 대체
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Chat among us",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 하단 2:1 비율의 아래쪽 Column
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 통역 버튼
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.translate, size: 40),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoloConversationPage(),
                          ),
                        );
                      },
                    ),
                    const Text(
                      "통역",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                // 통역 버튼
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.interpreter_mode, size: 40),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceRoomList(),
                          ),
                        );
                      },
                    ),
                    const Text(
                      "대화",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                // 채팅 버튼
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat, size: 40),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServerRoomList(),
                          ),
                        );
                      },
                    ),
                    const Text(
                      "채팅",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                // 이미지 버튼 (비활성화 상태)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      onPressed: null, // 비활성화 상태
                    ),
                    const Text(
                      "사진번역",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 상단 2:1 비율의 위쪽 Column
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

}
