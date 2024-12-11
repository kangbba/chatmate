import 'package:flutter/material.dart';
import '../screens/language_select_screen.dart';
import '../managers/language_select_control.dart';

class LanguageSettingScreen extends StatefulWidget {
  const LanguageSettingScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingScreen> createState() => _LanguageSettingScreenState();
}

class _LanguageSettingScreenState extends State<LanguageSettingScreen> {
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 명시적으로 설정
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '언어 설정',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo, // AppBar 배경색 설정
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "내 언어",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageSelectScreen(
                          languageSelectControl: languageSelectControl,
                          isMyLanguage: true,
                        ),
                      ),
                    ),
                    child: StreamBuilder<LanguageItem>(
                      stream: languageSelectControl.myLanguageItemStream,
                      initialData: languageSelectControl.myLanguageItem,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data?.menuDisplayStr ?? "",
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.black38,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  final temp = languageSelectControl.myLanguageItem;
                  languageSelectControl.myLanguageItem = languageSelectControl.yourLanguageItem;
                  languageSelectControl.yourLanguageItem = temp;
                });
              },
              child: const Icon(Icons.swap_horiz),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "상대 언어",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageSelectScreen(
                          languageSelectControl: languageSelectControl,
                          isMyLanguage: false,
                        ),
                      ),
                    ),
                    child: StreamBuilder<LanguageItem>(
                      stream: languageSelectControl.yourLanguageItemStream,
                      initialData: languageSelectControl.yourLanguageItem,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data?.menuDisplayStr ?? "",
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
