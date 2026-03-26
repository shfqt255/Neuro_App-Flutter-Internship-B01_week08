import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_model.dart';
import '../Profile/user_profile_model.dart';

class CreatePostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _currentUserProfile;
  List<Post> _userPosts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  UserProfile? get currentUserProfile => _currentUserProfile;
  List<Post> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUserProfile = UserProfile.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPost({required String caption}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentUserProfile == null) return;

    _setLoading(true);
    try {
      await _firestore.collection('posts').add({
        'userId': uid,
        'username': _currentUserProfile!.username,
        'userPhotoUrl': _currentUserProfile!.photoUrl,
        'caption': caption,
        'likesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(uid).update({
        'postsCount': FieldValue.increment(1),
      });

      await loadUserPosts(uid);
    } catch (e) {
      _setError('Failed to create post: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserPosts(String uid) async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userPosts = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _setError('Failed to load posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
