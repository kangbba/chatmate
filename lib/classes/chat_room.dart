
import 'dart:async';

import '../classes/dialogue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../custom_widget/simple_dialog.dart';
import '../classes/user_model.dart';

import '../exceptions/chat_room_exception.dart';

class ChatRoom{

  static const String kChatRoomsKey = 'chatRooms';
  static const String kIdKey = 'id';
  static const String kNameKey = 'name';
  static const  String kHostKey = 'host';
  static const String kCreatedAtKey = 'createdAt';
  static const  String kMembersKey = 'members';
  static const  String kDialoguesKey = 'dialogues';

  final String id;
  final String name;
  final UserModel host;
  final DateTime createdAt;


  //chatRoom
  ChatRoom({
    required this.id,
    required this.name,
    required this.host,
    required this.createdAt
  });

  Map<String, dynamic> toMap() {
    return {
      kIdKey: id,
      kNameKey: name,
      kHostKey: host.toMap(),
      kCreatedAtKey: createdAt.toIso8601String(),
    };
  }

  factory ChatRoom.fromFirebaseSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatRoom(
      id: snapshot.id,
      name: data[kNameKey],
      host: UserModel.fromMap(data[kHostKey]),
      createdAt: data[kCreatedAtKey] != null
          ? DateTime.tryParse(data[kCreatedAtKey]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  //host
  void setHost(UserModel host) {
    FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .update({
      kHostKey: host.toMap(),
    }).onError((error, stackTrace) {
      print('Error setting chat room host: $error');
      print(stackTrace);
      throw ChatRoomException('Failed to set chat room host.');
    });
  }

  //hostStream
  Stream<UserModel> hostStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .snapshots()
        .map((snapshot) =>
        UserModel.fromMap((snapshot.data() ?? {})[kHostKey] ?? {}));
  }

  Stream<List<Dialogue>> dialoguesStream() {
    return FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .collection(kDialoguesKey)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => Dialogue.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addDialogue(String ownerUid, String langCode, String content) async {
    final dialoguesCollectionRef = FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .collection(kDialoguesKey);

    // 새로운 문서 ID로 dialogue 문서 생성
    final newDialogue = Dialogue(
      id: dialoguesCollectionRef.doc().id, // Firestore가 생성한 고유 ID
      ownerUid: ownerUid,
      langCode: langCode,
      content: content,
      createdAt: DateTime.now(),
    );

    try {
      await dialoguesCollectionRef.add(newDialogue.toMap());
      debugPrint("adddialogue: New dialogue added successfully.");
    } catch (e) {
      debugPrint("adddialogue: Failed to add new dialogue - $e");
    }
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final userDoc = await membersRef.doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        // 해당 UID에 일치하는 사용자가 없으면 null을 반환
        return null;
      }
    } catch (e) {
      print("Error fetching user by UID: $e");
      return null;
    }
  }

  // 방 멤버 정보를 한 번만 가져오는 함수
  Future<List<UserModel>> getMembers() async {
    try {
      final membersSnapshot = await membersRef.get();
      return membersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching members: $e");
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  CollectionReference get membersRef =>
      FirebaseFirestore.instance.collection(kChatRoomsKey).doc(id).collection(kMembersKey);

  Stream<List<UserModel>> get userModelsStream {
    final membersRef = FirebaseFirestore.instance
        .collection(kChatRoomsKey)
        .doc(id)
        .collection(kMembersKey);

    return membersRef.snapshots().map((querySnapshot) => querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }
  Future<bool> joinRoom(UserModel user) async {
    try {
      final memberRef = membersRef.doc(user.uid);
      final memberDoc = await memberRef.get();
      if (memberDoc.exists) {
        // 이미 멤버인 경우
        return true;
      } else {
        // 멤버가 아닌 경우, 추가
        await memberRef.set(user.toMap());
        return true;
      }
    } catch (e) {
      throw FirebaseException(
          message: 'Error joining chat room: $e', code: 'join-room-error', plugin: '');
    }
  }

  Future<void> exitRoom(UserModel user, {UserModel? newHost}) async {
    try {
      final userDoc = await membersRef.doc(user.uid).get();
      if (!userDoc.exists) {
        simpleToast("해당 방에 내가 없습니다");
        return; // 해당 사용자가 채팅방 멤버가 아니면 삭제하지 않음
      }

      await userDoc.reference.delete();

      final membersSnapshot = await membersRef.get();
      final remainingMembers = membersSnapshot.docs
          .map((doc) => UserModel.fromFirebaseSnapshot(doc))
          .where((member) => member.uid != user.uid)
          .toList();

      if (remainingMembers.isEmpty) {
        await FirebaseFirestore.instance
            .collection(kChatRoomsKey)
            .doc(id)
            .delete();
      } else if (host.uid == user.uid) {
        UserModel newHostUser = newHost ?? remainingMembers.first;
        setHost(newHostUser);
      }

      return;
    } catch (e) {
      throw FirebaseException(
          message: 'Error exiting chat room: $e', code: 'exit-room-error', plugin: '');
    }
  }



}