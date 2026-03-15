import 'package:chat_app/model/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHandling {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String text,
    String chatId,
  ) async {
    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: Timestamp.now(),
    );

    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots();
  }
}
