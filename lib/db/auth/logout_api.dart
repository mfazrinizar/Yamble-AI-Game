import 'package:firebase_auth/firebase_auth.dart';
import 'package:yamble_yap_to_gamble_ai_game/encrypted/secure_storage.dart';

class LogoutAPI {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout({bool? isFromRegisterPage}) async {
    if (isFromRegisterPage == null) {
      await UserSecureStorage.clearAll();
    }

    await _auth.signOut();
  }
}
