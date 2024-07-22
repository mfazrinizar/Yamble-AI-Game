import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'dart:io';

import 'package:yamble_yap_to_gamble_ai_game/db/auth/logout_api.dart';

class RegisterApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> registerUser({
    required File profilePictureImage,
    required String userName,
    required String nameOfUser,
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      // Check if the username is already used
      QuerySnapshot userNameQuery = await _firestore
          .collection('users')
          .where('userName', isEqualTo: userName)
          .get();

      if (userNameQuery.docs.isNotEmpty) {
        return 'USERNAME_ALREADY_IN_USE';
      }

      // Register the user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Get file extension of the profilePictureImage
      String fileExtension = path.extension(profilePictureImage.path);

      // Upload the profile picture to Firebase Storage
      UploadTask uploadTask = _storage
          .ref('profile_pictures/${userCredential.user!.uid}$fileExtension')
          .putFile(profilePictureImage);

      // Get the download URL of the profile picture
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = (await downloadUrl.ref.getDownloadURL());

      // Update the user's profile with the name and profile picture URL
      await userCredential.user!.updateDisplayName(nameOfUser);
      await userCredential.user!.updatePhotoURL(url);

      // Create a document in Firestore with the user's ID
      Map<String, dynamic> userData = {
        'name': nameOfUser,
        'userName': userName,
        'uid': userCredential.user!.uid,
        'profilePictureUrl': url,
        'registeredAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Create a document in the leaderboard collection with the same user data and additional fields
      Map<String, dynamic> leaderboardData = {
        ...userData,
        'rank': 0,
        'totalWin': 0,
        'hardWin': 0,
        'mediumWin': 0,
        'easyWin': 0,
        'totalLost': 0,
        'totalGames': 0,
      };

      await _firestore
          .collection('leaderboard')
          .doc(userCredential.user!.uid)
          .set(leaderboardData);

      // Make sure it's not logged in before verifying email
      await LogoutAPI().logout(isFromRegisterPage: true);

      // Return a success message
      return 'SUCCESSFUL_SIR';
    } on FirebaseAuthException catch (e) {
      // Return the error code
      return e.code;
    } catch (e) {
      // Return a generic error message
      return 'An error occurred';
    }
  }
}
