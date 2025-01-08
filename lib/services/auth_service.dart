import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _persistUserSession(userCredential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error signing in with email and password: ${e.message}');
      throw e;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _persistUserSession(userCredential);
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isUserLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && _auth.currentUser != null;
  }

  Future<bool> isFirstLogin() async {
    final firstLoginFlag = await _storage.read(key: 'first_login');
    if (firstLoginFlag == null) {
      await _storage.write(key: 'first_login', value: 'false');
      return true;
    }
    return false;
  }

  Future<void> _persistUserSession(UserCredential userCredential) async {
    final token = await userCredential.user?.getIdToken();
    if (token != null) {
      await _storage.write(key: 'auth_token', value: token);
    }
  }
}

