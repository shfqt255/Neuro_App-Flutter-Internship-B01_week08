import 'package:chat_app/cloud_firestore_service.dart/message_handling.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatPage({super.key, required this.senderId, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final MessageHandling messageService = MessageHandling();

  final String chatId = "chat_1";

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    messageService.sendMessage(
      widget.senderId,
      widget.receiverId,
      messageController.text,
      chatId,
    );

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat (${widget.senderId})"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // MESSAGE LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messageService.getMessages(chatId),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;

                    bool isMe = data["senderId"] == widget.senderId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.grey.shade300,

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Text(
                          data["text"],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(hintText: "Message"),
                ),
              ),

              IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
