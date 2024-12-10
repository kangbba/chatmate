import 'package:flutter/material.dart';
import '../helper/colors.dart';

import '../managers/my_auth_provider.dart';
import '../custom_widget/simple_dialog.dart';

class ChangingNicknameScreen extends StatefulWidget {
  const ChangingNicknameScreen({Key? key}) : super(key: key);

  @override
  State<ChangingNicknameScreen> createState() => _ChangingNicknameScreenState();
}

class _ChangingNicknameScreenState extends State<ChangingNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final _authProvider = MyAuthProvider.instance;

  @override
  void initState() {
    super.initState();
    if (_authProvider.curUser?.displayName?.isNotEmpty ?? false) {
      // 사용자의 닉네임이 비어있지 않은 경우
      _nicknameController.text = _authProvider.curUser!.displayName!;
    } else {
      // 사용자의 닉네임이 비어있는 경우
      _nicknameController.text = _authProvider.curUser?.email?.split("@")[0] ?? '';
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('닉네임 설정'), backgroundColor: ColorManager.color_standard,),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('새로운 닉네임을 입력해주세요.'),
            TextField(
              controller: _nicknameController,
            ),
            ElevatedButton(
              onPressed: () async {
                final user = _authProvider.curUser;
                if (user == null) {
                  return; // 로그인되어 있지 않으면 종료
                }
                await user.updateDisplayName(_nicknameController.text);
                simpleToast('닉네임이 변경되었습니다.');
                Navigator.pop(context);
              },
              child: Text('변경하기'),
            ),
          ],
        ),
      ),
    );
  }
}

