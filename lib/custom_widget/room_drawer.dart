import '../custom_widget/user_list.dart';
import '../managers/my_auth_provider.dart';
import 'package:flutter/material.dart';
import '../classes/room_settings.dart';
import '../classes/chat_room.dart';
import '../custom_widget/simple_separator.dart';
import '../screens/language_select_screen.dart';
import '../managers/language_select_control.dart';

class RoomDrawer extends StatefulWidget {
  final ChatRoom chatRoom;

  const RoomDrawer({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<RoomDrawer> createState() => _RoomDrawerState();
}

class _RoomDrawerState extends State<RoomDrawer> {
  MyAuthProvider authProvider = MyAuthProvider.instance;
  final ValueNotifier<double> myVolumeNotifier = ValueNotifier(RoomSettings().myVolume);
  final ValueNotifier<double> otherVolumeNotifier = ValueNotifier(RoomSettings().otherVolume);

  @override
  void initState() {
    super.initState();
    _loadVolumeSettings();
  }

  // SharedPreferences에서 볼륨 설정 로드
  Future<void> _loadVolumeSettings() async {
    await RoomSettings().loadSettings();
    myVolumeNotifier.value = RoomSettings().myVolume;
    otherVolumeNotifier.value = RoomSettings().otherVolume;
  }

  // RoomDrawer가 닫힐 때 볼륨 설정 저장
  Future<void> _saveVolumeSettings() async {
    RoomSettings().myVolume = myVolumeNotifier.value;
    RoomSettings().otherVolume = otherVolumeNotifier.value;
    await RoomSettings().saveSettings();
  }

  @override
  void dispose() {
    _saveVolumeSettings(); // Drawer가 닫힐 때 저장
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.chatRoom.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 언어 변경 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectScreen(
                        languageSelectControl: LanguageSelectControl.instance,
                        isMyLanguage: true,
                      ),
                    ),
                  );
                },
                child: const Text("Change Language"),
              ),
            ),
            const Divider(),
            // 참여자 목록
            Expanded(child: UserList(userModelsStream: widget.chatRoom.userModelsStream)),
          ],
        ),
      ),
    );
  }

  Widget volumeSlider(String title, ValueNotifier<double> volumeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableBuilder<double>(
        valueListenable: volumeNotifier,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                onChanged: (newValue) {
                  volumeNotifier.value = newValue;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
