import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlannerStorage {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Save a place into the user's planner
  static Future<void> saveToPlanner(Map<String, dynamic> place) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc(place['place_id']);

    await docRef.set(place, SetOptions(merge: true));
  }

  /// Retrieve all saved places for the current user
  static Future<List<Map<String, dynamic>>> getSavedItems() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Save notes to a specific place
  static Future<void> saveNotes(String placeId, String notes) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc(placeId)
        .update({'notes': notes});
  }

  /// Retrieve notes for a specific place
  static Future<String> getNotes(String placeId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return '';

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc(placeId)
        .get();

    return doc.data()?['notes'] ?? '';
  }
}
