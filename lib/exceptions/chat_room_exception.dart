class ChatRoomException implements Exception {
  final String message;
  ChatRoomException(this.message);

  @override
  String toString() => message;
}
