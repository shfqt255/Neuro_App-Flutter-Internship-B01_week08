import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_profile_app/Profile/profile_provider.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required ProfileProvider profileProvider,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final u = cred.user;
      if (u != null) {
        await u.updateDisplayName(name);
        await profileProvider.createProfile(
          uid: u.uid,
          name: name,
          email: email,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        default:
          return 'Sign up failed. Please try again.';
      }
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Please enter a valid email.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'Login failed. Please try again.';
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
