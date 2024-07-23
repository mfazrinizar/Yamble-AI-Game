import 'package:firebase_auth/firebase_auth.dart';

class SettingsApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null && currentUser.email != null) {
        AuthCredential currentCredential = EmailAuthProvider.credential(
            email: currentUser.email!, password: currentPassword);

        // Re-auth to make sure credential
        await currentUser.reauthenticateWithCredential(currentCredential);

        // Update password to Firebase Auth
        await currentUser.updatePassword(newPassword);

        return {
          'status': 'SUCCESS_SIR',
          'message': 'Password changed successfully.'
        };
      } else {
        return {
          'status': 'NO_USER',
          'message': 'No user is currently signed in.'
        };
      }
    } on FirebaseAuthException catch (e) {
      return {'status': 'error', 'message': e.code};
    } catch (e) {
      return {'status': 'error', 'message': 'An error occurred'};
    }
  }
}
