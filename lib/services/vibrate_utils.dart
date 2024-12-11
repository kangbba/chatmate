import 'package:vibration/vibration.dart';

class VibrationUtils{

  static void vibrate() async{
    if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 100);
    }
  }

}