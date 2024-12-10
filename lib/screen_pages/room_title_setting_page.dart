import 'dart:math';

import 'package:flutter/material.dart';
import '../classes/user_model.dart';
import '../custom_widget/simple_separator.dart';
import '../custom_widget/profile_circle.dart';
import '../screens/title_input_screen.dart';
import '../managers/my_auth_provider.dart';

class RoomTitleSettingPage extends StatefulWidget {
  const RoomTitleSettingPage({super.key});

  @override
  _RoomTitleSettingPageState createState() => _RoomTitleSettingPageState();
}

class _RoomTitleSettingPageState extends State<RoomTitleSettingPage> {
  final TextEditingController _textController = TextEditingController();
  bool _showError = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController.text = "Chat ${Random().nextInt(10000)}";
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onCreatePressed() {
    final title = _textController.text.trim();
    if (title.isNotEmpty) {
      Navigator.pop(context, title);
    } else {
      setState(() => _showError = true);
      Future.delayed(Duration(seconds: 2), () {
        setState(() => _showError = false);
      });
    }
  }
  void _resetText() {
    setState(() => _textController.text = '');
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildTitleField() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => TitleInputScreen(currentTitle: _textController.text),
          ),
        ).then((newTitle) {
          if (newTitle != null && newTitle.isNotEmpty) {
            setState(() {
              _textController.text = newTitle;
            });
          }
        });
      },
      child: TextField(
        controller: _textController,
        textAlign: TextAlign.center,
        enabled: false,
        decoration: InputDecoration(
          hintText: 'Enter room title',
          suffixIcon: Icon(Icons.edit),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    UserModel curUserModel = MyAuthProvider.instance.curUserModel!;
    return SizedBox(
      width: 500,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "회의실의 이름을 정해주세요",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(child: Align(alignment : Alignment.center, child: _buildTitleField())),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                      onTap: _onCreatePressed,
                      child: Icon(Icons.check_circle, color: Colors.green[400], size: 35,)),
                ),
              ),
            ),
            if (_showError)
              SizedBox(
                height: 20,
                child: Text(
                  'Please enter a valid room title.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
