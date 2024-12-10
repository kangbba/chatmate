import 'package:shared_preferences/shared_preferences.dart';

class RoomSettings {
  // 싱글톤 패턴으로 전역 접근 가능하게 함
  static final RoomSettings _instance = RoomSettings._internal();
  factory RoomSettings() => _instance;
  RoomSettings._internal();

  double myVolume = 1;
  double otherVolume = 1;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    myVolume = prefs.getDouble('myVolume') ?? 1;
    otherVolume = prefs.getDouble('otherVolume') ?? 1;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('myVolume', myVolume);
    await prefs.setDouble('otherVolume', otherVolume);
  }
}
