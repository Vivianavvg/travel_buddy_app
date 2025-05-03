import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'profile/profile_detail_screen.dart'; // We'll make this next

class FindBuddyScreen extends StatelessWidget{
  const FindBuddyScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Find a travel buddy')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot){
        if(snapshot.hasError){
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index){
            final user = users[index];
            final email = user['email'] ?? 'No email';
            final destination = user['favoriteDestinations'] ?? 'No destination';
            final interests = (user['interests'] as List<dynamic>?)?.join(', ') ?? 'No interests';

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(email),
                subtitle: Text('Destination: $destination\nInterests: $interests'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailScreen(
                        userData: user.data() as Map<String, dynamic>),
                      ), //1
                    ); //2
                  },//3
               ), //4
              ); //5
            }, //6
          ); //7
        }, //8
      ), //9
    ); //10
  } //11
} //12                  