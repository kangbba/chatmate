import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../managers/language_select_control.dart';
import '../screens/language_select_screen.dart';


class LanguageSelectScreenButton extends StatefulWidget {
  const LanguageSelectScreenButton({super.key, });

  @override
  State<LanguageSelectScreenButton> createState() => _LanguageSelectScreenButtonState();
}

class _LanguageSelectScreenButtonState extends State<LanguageSelectScreenButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageSelectControl>(
      builder: (context, languageSelectControl, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              late LanguageSelectScreen myLanguageSelectScreen =
              LanguageSelectScreen(
                languageSelectControl: languageSelectControl, isMyLanguage: true,
              );
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: myLanguageSelectScreen,
                    ),
                  );
                },
              );
              setState(() {});
            },
            child: SizedBox(
              height: 60,
              child: Column(
                children: [
                  Text(
                      "현재 설정 언어 : ${languageSelectControl.myLanguageItem.menuDisplayStr}"),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "  번역 언어 변경하기   ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
