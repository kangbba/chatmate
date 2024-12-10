import 'package:flutter/material.dart';

class ConversationArea extends StatelessWidget {
  final bool isMine;
  final String displayText;
  final VoidCallback onPressed;

  const ConversationArea({
    Key? key,
    required this.isMine,
    required this.displayText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isMine ? Colors.blue : Colors.grey[300],
      child: Stack(
        children: [
          Center(
            child: Text(
              displayText,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: onPressed,
              child: Icon(Icons.mic),
              backgroundColor: isMine ? Colors.white : Colors.black,
              foregroundColor: isMine ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
