import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget{
  final String otherUserEmail;

  const ChatScreen({super.key, required this.otherUserEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
  final TextEditingController _messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  late final String chatRoomId;


  @override
  void initState(){
    super.initState();
    chatRoomId = _getChatRoomId(user!.email!, widget.otherUserEmail);
  }

  String _getChatRoomId(String user1, String user2){
    if(user1.compareTo(user2)<0){
      return '${user1}_$user2';
    }else{
      return '${user2}_$user1';
    }
  }
  Future<void> _sendMessage() async{
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatRoomId)
      .collection('messages')
      .add({
      'senderEmail' : user!.email,
      'messageText': messageText,
      'timestamp' : FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)

        .set({
        'participants': [user!.email, widget.otherUserEmail],
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        },SetOptions(merge: true));
        _messageController.clear();
        }

        @override
        Widget build(BuildContext context){
          return Scaffold(
            appBar: AppBar(
              title: Text('Chat with ${widget.otherUserEmail}'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasError){
                        return const Center(child: Text('SOmething went wrong'));
                      }
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      }
                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index){
                          final message = messages[index];
                          final sender = message['senderEmail'];
                          final text = message['messageText'];
                          final isMe = sender == user!.email;

                          return Container(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.lightBlueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isMe ? const Radius.circular(0) : const Radius.circular(12),
                                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMe ? 'You' : sender,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height:5),
                                  Text(
                                    text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
}