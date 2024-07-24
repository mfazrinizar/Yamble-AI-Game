import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserApi {
  // Fetch all users from the 'users' collection
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      return [];
    }
  }

  // Fetch a user based on the userId or uid
  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return docSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      return null;
    }
  }
}
