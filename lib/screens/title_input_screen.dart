import 'package:flutter/material.dart';

class TitleInputScreen extends StatefulWidget {
  const TitleInputScreen({Key? key, required this.currentTitle}) : super(key: key);

  final String currentTitle;

  @override
  State<TitleInputScreen> createState() => _TitleInputScreenState();
}

class _TitleInputScreenState extends State<TitleInputScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.currentTitle;
    Future.delayed(Duration.zero, () {
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Align(alignment: Alignment.center, child: Text('회의실 이름 설정')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(_textController.text),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 110),
            TextField(
              controller: _textController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter room title',
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _textController.text = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
