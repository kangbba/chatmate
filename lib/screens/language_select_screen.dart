import 'package:flutter/material.dart';
import '../managers/language_select_control.dart';

class LanguageSelectScreen extends StatefulWidget {
  final LanguageSelectControl languageSelectControl;
  final bool isMyLanguage; // 내 언어인지 여부

  const LanguageSelectScreen({
    required this.languageSelectControl,
    required this.isMyLanguage,
    Key? key,
  }) : super(key: key);

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  late List<LanguageItem> languageDataList = widget.languageSelectControl.languageDataList;
  late LanguageItem selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.isMyLanguage
        ? widget.languageSelectControl.myLanguageItem
        : widget.languageSelectControl.yourLanguageItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 커스텀 헤더
          SafeArea(
            child: Container(
              height: 50, // 원하는 높이로 설정
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.indigo),
                    onPressed: () {
                      Navigator.of(context).pop(); // 뒤로가기
                    },
                  ),
                  SizedBox(width: 100,),
                  Row(
                    children: [
                      Text(
                        "Selected : ${selectedLanguage.menuDisplayStr!}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[900]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]), // 구분선
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 언어 리스트
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < languageDataList.length; i += 3)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (i < languageDataList.length)
                                  selectableLanguageButton(languageDataList[i]),
                                if (i + 1 < languageDataList.length)
                                  selectableLanguageButton(languageDataList[i + 1]),
                                if (i + 2 < languageDataList.length)
                                  selectableLanguageButton(languageDataList[i + 2]),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Confirm 버튼
                  Padding(
                    padding: const EdgeInsets.only(left : 8, right : 8, bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.isMyLanguage) {
                          widget.languageSelectControl.myLanguageItem = selectedLanguage;
                        } else {
                          widget.languageSelectControl.yourLanguageItem = selectedLanguage;
                        }
                        Navigator.of(context).pop(); // 화면 닫기
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40), // 버튼 크기
                        backgroundColor: Colors.indigo,
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectableLanguageButton(LanguageItem languageItem) {
    final bool isSelected = selectedLanguage == languageItem;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.indigo : Colors.grey[300],
          minimumSize: const Size(100, 40),
        ),
        onPressed: () {
          setState(() {
            selectedLanguage = languageItem;
          });
        },
        child: Text(
          languageItem.menuDisplayStr!,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
