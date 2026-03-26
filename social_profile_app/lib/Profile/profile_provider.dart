import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_profile_app/Post/post_model.dart';
import 'package:social_profile_app/Profile/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  UserProfile? _currentUserProfile; // The logged-in user's profile
  UserProfile? _viewedProfile; // Profile we're currently viewing
  List<Post> _userPosts = []; // Posts of the viewed user
  bool _isLoading = false; // Are we loading data?
  bool _isFollowing = false; // Does current user follow viewed user?
  String _errorMessage = ''; // Any error messages

  UserProfile? get currentUserProfile => _currentUserProfile;
  UserProfile? get viewedProfile => _viewedProfile;
  List<Post> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  bool get isFollowing => _isFollowing;
  String get errorMessage => _errorMessage;

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      _setLoading(true);
      final username = email.split('@')[0].toLowerCase();
      final newProfile = UserProfile(
        uid: uid,
        name: name,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).set(newProfile.toMap());

      _currentUserProfile = newProfile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to create profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      _setLoading(true);

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentUserProfile = UserProfile.fromMap(doc.data()!, uid);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserProfile(String uid) async {
    try {
      _setLoading(true);
      _viewedProfile = null;
      _userPosts = [];
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _viewedProfile = UserProfile.fromMap(doc.data()!, uid);
      }

      await Future.wait([loadUserPosts(uid), checkIfFollowing(uid)]);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load user: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String name,
    required String bio,
    File? imageFile,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      _setLoading(true);

      String photoUrl = _currentUserProfile?.photoUrl ?? '';

      if (imageFile != null) {
        photoUrl = await _uploadProfileImage(uid, imageFile);
      }
      final updateData = {'name': name, 'bio': bio, 'photoUrl': photoUrl};

      await _firestore.collection('users').doc(uid).update(updateData);
      _currentUserProfile = _currentUserProfile?.copyWith(
        name: name,
        bio: bio,
        photoUrl: photoUrl,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }

  Future<File?> pickImage({bool fromCamera = false}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<void> followUser(String targetUid) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || currentUid == targetUid) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore.collection('users').doc(currentUid);
        final targetUserRef = _firestore.collection('users').doc(targetUid);
        final followingRef = currentUserRef
            .collection('following')
            .doc(targetUid);
        final followerRef = targetUserRef
            .collection('followers')
            .doc(currentUid);
        final currentUserDoc = await transaction.get(currentUserRef);
        final targetUserDoc = await transaction.get(targetUserRef);
        final currentFollowing =
            (currentUserDoc.data()?['followingCount'] ?? 0) as int;
        final targetFollowers =
            (targetUserDoc.data()?['followersCount'] ?? 0) as int;
        transaction.set(followingRef, {
          'uid': targetUid,
          'followedAt': FieldValue.serverTimestamp(),
        });

        // 2. Add to target user's "followers" subcollection
        transaction.set(followerRef, {
          'uid': currentUid,
          'followedAt': FieldValue.serverTimestamp(),
        });

        // 3. Increment current user's followingCount
        transaction.update(currentUserRef, {
          'followingCount': currentFollowing + 1,
        });

        // 4. Increment target user's followersCount
        transaction.update(targetUserRef, {
          'followersCount': targetFollowers + 1,
        });
      });

      // Update local state
      _isFollowing = true;
      _viewedProfile = _viewedProfile?.copyWith(
        followersCount: (_viewedProfile?.followersCount ?? 0) + 1,
      );
      _currentUserProfile = _currentUserProfile?.copyWith(
        followingCount: (_currentUserProfile?.followingCount ?? 0) + 1,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to follow user: $e');
    }
  }

  // Unfollow a user (reverse of follow)
  Future<void> unfollowUser(String targetUid) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore.collection('users').doc(currentUid);
        final targetUserRef = _firestore.collection('users').doc(targetUid);

        final followingRef = currentUserRef
            .collection('following')
            .doc(targetUid);

        final followerRef = targetUserRef
            .collection('followers')
            .doc(currentUid);

        // Read current data
        final currentUserDoc = await transaction.get(currentUserRef);
        final targetUserDoc = await transaction.get(targetUserRef);

        final currentFollowing =
            (currentUserDoc.data()?['followingCount'] ?? 0) as int;
        final targetFollowers =
            (targetUserDoc.data()?['followersCount'] ?? 0) as int;

        // Delete from both subcollections
        transaction.delete(followingRef);
        transaction.delete(followerRef);

        // Decrement counts (minimum 0)
        transaction.update(currentUserRef, {
          'followingCount': currentFollowing > 0 ? currentFollowing - 1 : 0,
        });
        transaction.update(targetUserRef, {
          'followersCount': targetFollowers > 0 ? targetFollowers - 1 : 0,
        });
      });

      // Update local state
      _isFollowing = false;
      _viewedProfile = _viewedProfile?.copyWith(
        followersCount: ((_viewedProfile?.followersCount ?? 1) - 1).clamp(
          0,
          999999,
        ),
      );
      _currentUserProfile = _currentUserProfile?.copyWith(
        followingCount: ((_currentUserProfile?.followingCount ?? 1) - 1).clamp(
          0,
          999999,
        ),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to unfollow user: $e');
    }
  }
  // Check if current user follows someone

  Future<void> checkIfFollowing(String targetUid) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    // Check if the document exists in "following" subcollection
    final doc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();

    _isFollowing = doc.exists;
    notifyListeners();
  }

  // Query posts where userId == uid
  Future<void> loadUserPosts(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userPosts = querySnapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load posts: $e');
    }
  }

  // Create a New Post
  Future<void> createPost({
    required File imageFile,
    required String caption,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentUserProfile == null) return;

    try {
      _setLoading(true);

      // 1. Upload image to Storage
      final postId = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('posts').child('$uid\_$postId.jpg');
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      // 2. Create post document in Firestore
      await _firestore.collection('posts').add({
        'userId': uid,
        'username': _currentUserProfile!.username,
        'userPhotoUrl': _currentUserProfile!.photoUrl,
        'imageUrl': imageUrl,
        'caption': caption,
        'likesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Increment posts count in user profile
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

  static String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
