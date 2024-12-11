import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class VolumeControl {
  static const MethodChannel _channel = MethodChannel('com.chatus.chatmate/volume');

  /// 볼륨 버튼 리스너 초기화
  static Future<void> initialize({
    required VoidCallback onVolumeUpPressed,
    required VoidCallback onVolumeDownPressed,
  }) async {
    // 네이티브에서 커스텀 볼륨 제어 활성화
    await enableCustomVolumeControl();

    // 메서드 호출 핸들러 설정
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volumeButton') {
        String event = call.arguments as String;
        if (event == 'up') {
          debugPrint("Volume UP button pressed");
          onVolumeUpPressed();
        } else if (event == 'down') {
          debugPrint("Volume DOWN button pressed");
          onVolumeDownPressed();
        }
      }
    });
  }

  /// 볼륨 버튼 리스너 해제
  static Future<void> dispose() async {
    // 네이티브에서 커스텀 볼륨 제어 비활성화
    await disableCustomVolumeControl();

    // 메서드 호출 핸들러 해제
    _channel.setMethodCallHandler(null);
    debugPrint("Volume listener disposed");
  }

  /// 네이티브에서 커스텀 볼륨 제어 활성화
  static Future<void> enableCustomVolumeControl() async {
    await _channel.invokeMethod("enableCustomVolumeControl");
    debugPrint("Custom volume control enabled");
  }

  /// 네이티브에서 커스텀 볼륨 제어 비활성화
  static Future<void> disableCustomVolumeControl() async {
    await _channel.invokeMethod("disableCustomVolumeControl");
    debugPrint("Custom volume control disabled");
  }
}
