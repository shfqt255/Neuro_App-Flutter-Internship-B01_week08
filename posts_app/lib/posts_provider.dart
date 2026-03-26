import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:posts_app/firestore_service.dart';
import 'package:posts_app/post_model.dart';

class PostsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Post> _posts = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  bool _sampleDataAdded = false;

  String _selectedCategory = 'All';
  String _sortBy = 'timestamp';

  bool _isSearching = false;
  String _searchQuery = '';

  final List<String> categories = ['All', 'Flutter', 'Firebase', 'Dart'];
  final Map<String, String> sortOptions = {
    'timestamp': 'Newest First',
    'likes': 'Most Liked',
  };
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePosts => _hasMorePosts;
  bool get isSearching => _isSearching;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get sampleDataAdded => _sampleDataAdded;

  Future<void> addSamplePosts() async {
    if (_sampleDataAdded) return;
    await _firestoreService.addSamplePosts();
    _sampleDataAdded = true;
    notifyListeners();
    await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    if (_isLoading) return;
    _isLoading = true;
    _posts = [];
    _lastDocument = null;
    _hasMorePosts = true;
    _isSearching = false;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestoreService.getFirstPage(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        sortBy: _sortBy,
      );

      _posts = _firestoreService.convertToPosts(snapshot);

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      _hasMorePosts = snapshot.docs.length == FirestoreService.pageSize;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadNextPage() async {
    if (_lastDocument == null || !_hasMorePosts || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestoreService.getNextPage(
        lastDocument: _lastDocument!,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        sortBy: _sortBy,
      );

      List<Post> newPosts = _firestoreService.convertToPosts(snapshot);
      _posts.addAll(newPosts);

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      _hasMorePosts = snapshot.docs.length == FirestoreService.pageSize;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchPosts(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _isSearching = false;
      notifyListeners();
      await loadFirstPage();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    _posts = [];
    _hasMorePosts = false;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestoreService.searchPosts(query);
      _posts = _firestoreService.convertToPosts(snapshot);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    await loadFirstPage();
  }

  Future<void> setSortBy(String field) async {
    if (_sortBy == field) return;
    _sortBy = field;
    notifyListeners();
    await loadFirstPage();
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
    await loadFirstPage();
  }
}
