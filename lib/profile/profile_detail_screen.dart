import 'package:flutter/material.dart';
import '../chatting/chat_screen.dart'; // <-- Import your ChatScreen!

class ProfileDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileDetailScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final email = userData['email'] ?? 'No email';
    final destination = userData['favoriteDestinations'] ?? 'No destination';
    final interests = (userData['interests'] as List<dynamic>?)?.join(', ') ?? 'No interests';
    final pastTrips = userData['pastTrips'] ?? 'No past trips';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Destination: $destination', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Interests: $interests', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Past Trips: $pastTrips', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Simply go back to the list
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Not Interested'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          otherUserEmail: email,
                        ),
                      ),
                    );
                  },
                  child: const Text('Chat with User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
