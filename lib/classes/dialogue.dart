import 'package:cloud_firestore/cloud_firestore.dart';

class Dialogue{

  static const kIdKey = 'id';
  static const kOwnerUidKey = 'ownerUid'; // 대화 주인의 UID를 나타냄
  static const kContentKey = 'content';
  static const kLangCodeKey = 'langCode';
  static const kCreatedAtKey = 'createdAt';

  // Members
  final String id;
  final String ownerUid;
  final String langCode;
  final String content;
  final DateTime createdAt;

  Dialogue({
    required this.id,
    required this.ownerUid,
    required this.langCode,
    required this.content,
    required this.createdAt,
  });

  factory Dialogue.fromMap(Map<String, dynamic> map) {
    final id = map[kIdKey] ?? '';
    final ownerUid = map[kOwnerUidKey] ?? ''; // ownerUid로 변경
    final langCode = map[kLangCodeKey] ?? '';
    final content = map[kContentKey] ?? '';
    final createdAt = map[kCreatedAtKey] is Timestamp
        ? (map[kCreatedAtKey] as Timestamp).toDate()
        : DateTime.now();

    return Dialogue(
      id: id,
      ownerUid: ownerUid,
      langCode: langCode,
      content: content,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kOwnerUidKey: ownerUid, // ownerUid로 변경
      kContentKey: content,
      kLangCodeKey: langCode,
      kCreatedAtKey: createdAt,
    };
  }
}
