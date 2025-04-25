import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  /// Sign in with email and password
  static Future<User?> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Login failed");
    }
  }

  /// Register a new user with email and password
  static Future<User?> register(String email, String password) async {
    try {
      // Create the user using FirebaseAuth's createUserWithEmailAndPassword method
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Registration failed");
    }
  }

  /// Sign in with Google account
  static Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw AuthException("Google sign-in aborted");

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Google sign-in failed");
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut(); // For Google sign-in
    } catch (e) {
      throw AuthException("Sign-out failed: $e");
    }
  }

  /// Get the current logged-in user
  static User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
