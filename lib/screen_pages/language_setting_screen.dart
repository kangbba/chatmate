import 'package:flutter/material.dart';

import '../screens/language_select_screen.dart';
import '../managers/language_select_control.dart';

class LanguageSettingScreen extends StatefulWidget {
  const LanguageSettingScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingScreen> createState() => _LanguageSettingScreenState();
}

class _LanguageSettingScreenState extends State<LanguageSettingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 명시적으로 설정
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo, // AppBar 배경색 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                "My Language (${LanguageSelectControl.instance.myLanguageItem.menuDisplayStr})",
                style: TextStyle(color: Colors.black87), // 텍스트 색상 설정
              ),
              onTap: () {
                // 풀스크린으로 My Language 선택 화면 호출
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectScreen(
                      languageSelectControl: LanguageSelectControl.instance,
                      isMyLanguage: true,
                    ),
                  ),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              title: Text(
                "Other's Language (${LanguageSelectControl.instance.yourLanguageItem.menuDisplayStr})",
                style: TextStyle(color: Colors.black87), // 텍스트 색상 설정
              ),
              onTap: () {
                // 풀스크린으로 Other Language 선택 화면 호출
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectScreen(
                      languageSelectControl: LanguageSelectControl.instance,
                      isMyLanguage: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
