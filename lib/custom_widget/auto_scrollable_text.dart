import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'simple_separator.dart';

class AutoScrollableText extends StatefulWidget {
  final String content;
  final TextStyle textStyle;
  final double bottomPadding;

  AutoScrollableText({
    Key? key,
    required this.content,
    required this.textStyle,
    required this.bottomPadding,
  }) : super(key: key);

  @override
  _AutoScrollableTextState createState() => _AutoScrollableTextState();
}

class _AutoScrollableTextState extends State<AutoScrollableText> {
  final _scrollController = ScrollController();
  bool _isAutoScrollEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 수정
          mainAxisAlignment: MainAxisAlignment.end, // 수정
          children: [
            const Text("자동 스크롤 켜기 : ", textAlign: TextAlign.center,),
            Transform.scale(
              scaleX: 0.87,
              scaleY: 0.85,
              child: CupertinoSwitch(
                value: _isAutoScrollEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAutoScrollEnabled = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SimpleSeparator(color: Colors.black45, height: 0.3, top: 2, bottom: 2),
        Expanded(
          child: Stack(
            children: [
              Container(
                color: Colors.grey[100],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.grey[100],

                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: widget.bottomPadding),
                    controller: _scrollController,
                    child: Text(
                      widget.content,
                      style: widget.textStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SimpleSeparator(color: Colors.black45, height: 0.3, top: 2, bottom: 2),
      ],
    );
  }

  @override
  void didUpdateWidget(AutoScrollableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(_isAutoScrollEnabled) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
