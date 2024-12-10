import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

// 전역 변수로 색상과 텍스트 크기 설정
const Color indigoColor = Colors.indigo;
const Color whiteColor = Colors.white;
const double maxFontSize = 24.0;
const double minFontSize = 14.0;

class ConversationArea extends StatelessWidget {
  final bool isMine;
  final String text;
  final bool isRecording;
  final bool isDisabled;
  final VoidCallback onPressed;
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
      color: isMine ? indigoColor : whiteColor,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AutoSizeText(
                text,
                style: TextStyle(
                  color: isMine ? whiteColor : indigoColor,
                  fontSize: maxFontSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                minFontSize: minFontSize,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: isDisabled
                ? FloatingActionButton(
              onPressed: null,
              child: const Icon(Icons.mic_off),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            )
                : isRecording
                ? RippleAnimation(
              color: isMine ? whiteColor : indigoColor,
              delay: const Duration(milliseconds: 200),
              repeat: true,
              minRadius: 20,
              ripplesCount: 6,
              duration: const Duration(milliseconds: 1800),
              child: FloatingActionButton(
                onPressed: onPressedStop,
                child: const Icon(Icons.stop, size: 28),
                backgroundColor: isMine ? whiteColor : indigoColor,
                foregroundColor: isMine ? indigoColor : whiteColor,
              ),
            )
                : FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(Icons.mic),
              backgroundColor: isMine ? whiteColor : indigoColor,
              foregroundColor: isMine ? indigoColor : whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
