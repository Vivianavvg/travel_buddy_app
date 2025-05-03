import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatelessWidget{
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('your chat rooms'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return const Center(child: Text('something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          final userChats = chats.where((chat){
            final chatRoomId = chat.id;
            return chatRoomId.contains(user!.email!);
          }).toList();
          if(userChats.isEmpty){
            return const Center(child: Text('NO active chats yet.'));
          }
          return ListView.builder(
            itemCount: userChats.length,
            itemBuilder: (context, index){
              final chat = userChats[index];
              final chatRoomId = chat.id;
              final participants = chatRoomId.split('_');
              final otherUserEmail = participants.firstWhere((email) => email != user!.email);

              return ListTile(
                title: Text(otherUserEmail),
                subtitle: const Text('tap to continue chat'),
                leading: const Icon(Icons.chat_bubble_outline),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(otherUserEmail: otherUserEmail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}