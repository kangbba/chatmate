import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

// 전역 변수로 색상과 텍스트 크기 설정
const Color indigoColor = Colors.indigo;
const Color whiteColor = Colors.white;
const double maxFontSize = 26.0;
const double minFontSize = 14.0;

class ConversationArea extends StatelessWidget {
  final bool isMine;
  final String text;
  final bool isRecording;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final VoidCallback onPressedStop;

  const ConversationArea({
    Key? key,
    required this.isMine,
    required this.text,
    required this.isRecording,
    required this.isDisabled,
    required this.onPressed,
    required this.onPressedStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: !isMine ? indigoColor : whiteColor,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20.0, top : 12),
              child: AutoSizeText(
                text,
                style: TextStyle(
                  color: !isMine ? whiteColor : indigoColor,
                  fontSize: maxFontSize,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                minFontSize: minFontSize,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: onPressed == null ? Container() : isDisabled
                ? FloatingActionButton(
              heroTag: isMine ? 'mine-disabled' : 'yours-disabled',
              onPressed: null,
              child: const Icon(Icons.mic_off),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            )
                : isRecording
                ? RippleAnimation(
              color: !isMine ? whiteColor : indigoColor,
              delay: const Duration(milliseconds: 300),
              repeat: true,
              minRadius: 50,
              ripplesCount: 2,
              duration: const Duration(milliseconds: 2000),
              child: SizedBox(
                child: FloatingActionButton(
                  shape: const CircleBorder(), // 원형으로 설정
                  heroTag: isMine ? 'mine-recording' : 'yours-recording',
                  onPressed: onPressedStop,
                  child: SizedBox(
                      height : 35,
                      child: const Icon(Icons.stop, size: 30)),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            )
                : FloatingActionButton(
              shape: const CircleBorder(), // 원형으로 설정
              heroTag: isMine ? 'mine' : 'yours',
              onPressed: onPressed,
              child: const Icon(Icons.mic, size: 30,),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
