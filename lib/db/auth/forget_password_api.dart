import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      // Send password reset request
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'status': 'success',
        'message': 'Password reset email sent. Please check your email.'
      };
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'auth/invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'auth/unauthorized-continue-uri') {
        message =
            'The domain of the continue URL is not whitelisted. Please contact developer.';
      } else if (e.code == 'auth/user-not-found') {
        message =
            'There is no user corresponding to the email address. Please check your email and try again.';
      } else {
        message =
            'Error: ${e.code}. Please do screenshot and contact developer.';
      }

      return {
        'status': 'error',
        'message': message,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Check internet connection or contact developer.'
      };
    }
  }
}
