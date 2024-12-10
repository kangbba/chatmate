import 'dart:async';

import 'package:flutter/cupertino.dart';
enum TranslateLanguage{
  english, spanish, french, german, chinese, arabic, russian, portuguese, italian, japanese, dutch,
  korean, swedish, turkish, polish, danish, norwegian, finnish, czech, thai, greek, hungarian, hebrew, romanian, ukrainian , vietnamese,
  icelandic, bulgarian, lithuanian, latvian, slovenian, croatian, estonian, serbian, slovak, georgian, catalan, bengali, persian, marathi, indonesian
}

class LanguageItem {
  late final TranslateLanguage? translateLanguage;
  late final String? menuDisplayStr;
  late final String? sttLangCode;
  late final String? langCodeGoogleServer;
  final String androidTtsVoice;
  final String iosTtsVoice;

  String get ttsLangCode{
    switch(translateLanguage)
    {
      default:
        return sttLangCode!;
    }
  }


  LanguageItem({
    this.translateLanguage,
    this.menuDisplayStr,
    this.sttLangCode,
    this.langCodeGoogleServer,
    String? androidTtsVoice,
    String? iosTtsVoice,
  })  : androidTtsVoice = androidTtsVoice ?? '',
        iosTtsVoice = iosTtsVoice ?? '';
}


class LanguageSelectControl with ChangeNotifier{



  static LanguageSelectControl? _instance;
  static LanguageSelectControl get instance {
    _instance ??= LanguageSelectControl();
    return _instance!;
  }
  TranslateLanguage initialMyTranslateLanguage = TranslateLanguage.korean;
  TranslateLanguage initialYourTranslateLanguage = TranslateLanguage.english;

  // My Language 관련
  final _myLanguageItemController = StreamController<LanguageItem>.broadcast();
  late LanguageItem _myLanguageItem = findLanguageItemByTranslateLanguage(initialMyTranslateLanguage);

  Stream<LanguageItem> get myLanguageItemStream => _myLanguageItemController.stream;
  LanguageItem get myLanguageItem => _myLanguageItem;
  set myLanguageItem(LanguageItem value) {
    _myLanguageItem = value;
    _myLanguageItemController.add(value);
    notifyListeners();
  }

  // Your Language 관련
  final _yourLanguageItemController = StreamController<LanguageItem>.broadcast();
  late LanguageItem _yourLanguageItem = findLanguageItemByTranslateLanguage(initialYourTranslateLanguage);

  Stream<LanguageItem> get yourLanguageItemStream => _yourLanguageItemController.stream;
  LanguageItem get yourLanguageItem => _yourLanguageItem;
  set yourLanguageItem(LanguageItem value) {
    _yourLanguageItem = value;
    _yourLanguageItemController.add(value);
    notifyListeners();
  }



// TODO: LanguageItem 관리
  LanguageItem findLanguageItemByTranslateLanguage(TranslateLanguage translateLanguage) {
    return languageDataList.firstWhere((item) => item.translateLanguage == translateLanguage, orElse: () => LanguageItem());
  }
  LanguageItem findLanguageItemByMenuDisplayStr(String menuDisplayStr) {
    return languageDataList.firstWhere((item) => item.menuDisplayStr == menuDisplayStr, orElse: () => LanguageItem());
  }

  // 남자 목소리 정보
  // 한국 {name: ko-kr-x-koc-network, locale: ko-KR} /{name: ko-kr-x-koc-local, locale: ko-KR} {name: ko-kr-x-kod-network, locale: ko-KR} {name: ko-kr-x-kod-local, locale: ko-KR}
  // 미국 {name: en-us-x-iom-local, locale: en-US} {name: en-us-x-tpd-network, locale: en-US} {name: en-us-x-iom-network, locale: en-US} {name: en-us-x-tpd-local, locale: en-US} {name: en-us-x-iol-local, locale: en-US}

  List<LanguageItem> languageDataList = [
    LanguageItem(translateLanguage: TranslateLanguage.english, menuDisplayStr: "English", sttLangCode: "en-US", langCodeGoogleServer: "en", androidTtsVoice: 'en-us-x-iom-local'),
    LanguageItem(translateLanguage: TranslateLanguage.korean, menuDisplayStr: "Korean", sttLangCode: "ko-KR", langCodeGoogleServer: "ko", androidTtsVoice: 'ko-kr-x-kod-network'),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, menuDisplayStr: "Spanish", sttLangCode: "es-ES", langCodeGoogleServer: "es", ),
    LanguageItem(translateLanguage: TranslateLanguage.french, menuDisplayStr: "French", sttLangCode: "fr-FR", langCodeGoogleServer: "fr",  ),
    LanguageItem(translateLanguage: TranslateLanguage.german, menuDisplayStr: "German", sttLangCode: "de-DE", langCodeGoogleServer: "de", ),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, menuDisplayStr: "Chinese", sttLangCode: "zh-CN", langCodeGoogleServer: "zh",  ),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, menuDisplayStr: "Arabic", sttLangCode: "ar-AR", langCodeGoogleServer: "ar",  ),
    LanguageItem(translateLanguage: TranslateLanguage.russian, menuDisplayStr: "Russian", sttLangCode: "ru-RU", langCodeGoogleServer: "ru", ),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, menuDisplayStr: "Portuguese", sttLangCode: "pt-PT", langCodeGoogleServer: "pt", ),
    LanguageItem(translateLanguage: TranslateLanguage.italian, menuDisplayStr: "Italian", sttLangCode: "it-IT", langCodeGoogleServer: "it", ),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, menuDisplayStr: "Japanese", sttLangCode: "ja-JP", langCodeGoogleServer: "ja", ),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, menuDisplayStr: "Dutch", sttLangCode: "nl-NL", langCodeGoogleServer: "nl", ),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, menuDisplayStr: "Swedish", sttLangCode: "sv-SE", langCodeGoogleServer: "sv",),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, menuDisplayStr: "Turkish", sttLangCode: "tr-TR", langCodeGoogleServer: "tr", ),
    LanguageItem(translateLanguage: TranslateLanguage.polish, menuDisplayStr: "Polish", sttLangCode: "pl-PL", langCodeGoogleServer: "pl", ),
    LanguageItem(translateLanguage: TranslateLanguage.danish, menuDisplayStr: "Danish", sttLangCode: "da-DK", langCodeGoogleServer: "da", ),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, menuDisplayStr: "Norwegian", sttLangCode: "nb-NO", langCodeGoogleServer: "no", ),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, menuDisplayStr: "Finnish", sttLangCode: "fi-FI", langCodeGoogleServer: "fi",),
    LanguageItem(translateLanguage: TranslateLanguage.czech, menuDisplayStr: "Czech", sttLangCode: "cs-CZ", langCodeGoogleServer: "cs", ),
    LanguageItem(translateLanguage: TranslateLanguage.thai, menuDisplayStr: "Thai", sttLangCode: "th-TH", langCodeGoogleServer: "th", ),
    LanguageItem(translateLanguage: TranslateLanguage.greek, menuDisplayStr: "Greek", sttLangCode: "el-GR", langCodeGoogleServer: "el", ),
    LanguageItem(translateLanguage: TranslateLanguage.hungarian, menuDisplayStr: "Hungarian", sttLangCode: "hu-HU", langCodeGoogleServer: "hu", ),
    LanguageItem(translateLanguage: TranslateLanguage.hebrew, menuDisplayStr: "Hebrew", sttLangCode: "he-IL", langCodeGoogleServer: "he", ),
    LanguageItem(translateLanguage: TranslateLanguage.romanian, menuDisplayStr: "Romanian", sttLangCode: "ro-RO", langCodeGoogleServer: "ro",),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, menuDisplayStr: "Ukrainian", sttLangCode: "uk-UA", langCodeGoogleServer: "uk", ),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, menuDisplayStr: "Vietnamese", sttLangCode: "vi-VN", langCodeGoogleServer: "vi", ),
    LanguageItem(translateLanguage: TranslateLanguage.icelandic, menuDisplayStr: "Icelandic", sttLangCode: "is-IS", langCodeGoogleServer: "is",),
    LanguageItem(translateLanguage: TranslateLanguage.bulgarian, menuDisplayStr: "Bulgarian", sttLangCode: "bg-BG", langCodeGoogleServer: "bg", ),
    LanguageItem(translateLanguage: TranslateLanguage.lithuanian, menuDisplayStr: "Lithuanian", sttLangCode: "lt-LT", langCodeGoogleServer: "lt", ),
    LanguageItem(translateLanguage: TranslateLanguage.latvian, menuDisplayStr: "Latvian", sttLangCode: "lv-LV", langCodeGoogleServer: "lv", ),
    LanguageItem(translateLanguage: TranslateLanguage.slovenian, menuDisplayStr: "Slovenian", sttLangCode: "sl-SI", langCodeGoogleServer: "sl", ),
    LanguageItem(translateLanguage: TranslateLanguage.croatian, menuDisplayStr: "Croatian", sttLangCode: "hr-HR", langCodeGoogleServer: "hr",),
    LanguageItem(translateLanguage: TranslateLanguage.estonian, menuDisplayStr: "Estonian", sttLangCode: "et-EE", langCodeGoogleServer: "et", ),
    LanguageItem(translateLanguage: TranslateLanguage.serbian , menuDisplayStr: "Serbian", sttLangCode: "sr-RS", langCodeGoogleServer: "sr",),
    LanguageItem(translateLanguage: TranslateLanguage.slovak, menuDisplayStr: "Slovak", sttLangCode: "sk-SK", langCodeGoogleServer: "sk",),
    LanguageItem(translateLanguage: TranslateLanguage.georgian, menuDisplayStr: "Georgian", sttLangCode: "ka-GE", langCodeGoogleServer: "ka", ),
    LanguageItem(translateLanguage: TranslateLanguage.catalan, menuDisplayStr: "Catalan", sttLangCode: "ca-ES", langCodeGoogleServer: "ca",),
    LanguageItem(translateLanguage: TranslateLanguage.bengali, menuDisplayStr: "Bengali", sttLangCode: "bn-IN", langCodeGoogleServer: "bn",),
    LanguageItem(translateLanguage: TranslateLanguage.persian, menuDisplayStr: "Persian", sttLangCode: "fa-IR", langCodeGoogleServer: "fa",),
    LanguageItem(translateLanguage: TranslateLanguage.marathi, menuDisplayStr: "Marathi", sttLangCode: "mr-IN", langCodeGoogleServer: "mr",),
    LanguageItem(translateLanguage: TranslateLanguage.indonesian, menuDisplayStr: "Indonesian", sttLangCode: "id-ID", langCodeGoogleServer: "id",),
  ];

}