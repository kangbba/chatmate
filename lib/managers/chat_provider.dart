import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../classes/user_model.dart';
import '../classes/chat_room.dart';


class ChatProvider with ChangeNotifier {

  static final ChatProvider _instance = ChatProvider._internal();

  ChatProvider._internal();

  factory ChatProvider.getInstance() => _instance;

    static ChatProvider get instance => _instance;

  Future<ChatRoom?> createChatRoom(String chatRoomName, UserModel hostUserModel) async {
    try {
      debugPrint("createChatRoom: Generating new chat room ID...");
      final chatRoomRef = FirebaseFirestore.instance.collection(ChatRoom.kChatRoomsKey).doc();

      debugPrint("createChatRoom: Creating ChatRoom instance with ID: ${chatRoomRef.id}");
      final newChatRoom = ChatRoom(
        id: chatRoomRef.id,
        name: chatRoomName,
        host: hostUserModel,
        createdAt: DateTime.now(),
      );

      debugPrint("createChatRoom: Saving chat room data to Firestore...");
      await chatRoomRef.set(newChatRoom.toMap());
      debugPrint("createChatRoom: Chat room data saved successfully.");

      debugPrint("createChatRoom: Retrieving chat room data from Firestore...");
      final chatRoomSnapshot = await chatRoomRef.get();

      debugPrint("createChatRoom: Converting Firestore snapshot to ChatRoom object...");
      final chatRoom = ChatRoom.fromFirebaseSnapshot(chatRoomSnapshot);

      debugPrint("createChatRoom: Setting host for the chat room...");
      chatRoom.setHost(hostUserModel);
      debugPrint("createChatRoom: Host set successfully.");

      return chatRoom;
    } catch (e) {
      debugPrint("createChatRoom: Failed to create chat room: $e");
      return null;
    }
  }

  Stream<List<ChatRoom>> chatRoomsStream() {
    return FirebaseFirestore.instance
        .collection(ChatRoom.kChatRoomsKey)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      List<ChatRoom> chatRooms =
      querySnapshot.docs.map((doc) => ChatRoom.fromFirebaseSnapshot(doc)).toList();
      // 'createdAt' 필드가 있는 경우에만 정렬
      if (querySnapshot.docs.first.data().containsKey(ChatRoom.kCreatedAtKey)) {
        chatRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return chatRooms;
    });
  }










// Future<void> sendMessage(
  //     String chatRoomId,
  //     String message,
  //     UserCredential userCredential,
  //     ) async {
  //   final messageRef = FirebaseFirestore.instance
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .doc();
  //
  //   final newMessage = {
  //     'text': message,
  //     'senderId': userCredential.user!.uid,
  //     'senderEmail': userCredential.user!.email,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   };
  //
  //   await messageRef.set(newMessage);
  // }
  //
  // Stream<List<Message>> getRecentMessages(String chatRoomId) {
  //   final messagesRef = FirebaseFirestore.instance
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('createdAt', descending: true)
  //       .limit(20);
  //
  //   return messagesRef.snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  //   });
  // }


}
