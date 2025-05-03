import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();


}

class _ProfileScreenState extends State<ProfileScreen>{
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _pastTripsController = TextEditingController();
  final TextEditingController _favoriteDestinationsController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person, size:100),
            const SizedBox(height: 20),
            Text(
              'Email : ${user?.email ?? 'Not logged in'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _interestsController,
              decoration: const InputDecoration(
                labelText: 'Travel interests (seperate with commas)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pastTripsController,
              decoration: const InputDecoration(
                labelText: 'past trips (seperate with commas)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _favoriteDestinationsController,
              decoration: const InputDecoration(
                labelText: 'favorite destinations',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _savedProfile,
              child: const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _savedProfile() async{
    if(user == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged in user')),
      );
      return;
    }
  
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': user!.email,
        'interests': _interestsController.text.trim().split(','),
        'pastTrips': _pastTripsController.text.trim(),
        'favoriteDestinations': _favoriteDestinationsController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to saved profile: $e')),
      );
    }
  }
}
