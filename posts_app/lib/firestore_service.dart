import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:posts_app/post_model.dart';

class FirestoreService {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  static const int pageSize = 5;
  Future<void> addSamplePosts() async {
    final samplePosts = [
      {
        'title': 'Getting Started with Flutter',
        'content':
            'Flutter is Google\'s UI toolkit for building beautiful apps...',
        'category': 'Flutter',
        'author': 'Alice',
        'likes': 45,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'title': 'Firebase Firestore Deep Dive',
        'content': 'Firestore is a NoSQL database that scales automatically...',
        'category': 'Firebase',
        'author': 'Bob',
        'likes': 78,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'title': 'Dart Null Safety Explained',
        'content': 'Null safety helps you avoid null reference errors...',
        'category': 'Dart',
        'author': 'Charlie',
        'likes': 32,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3))),
      },
      {
        'title': 'Flutter State Management Guide',
        'content': 'Managing state in Flutter can be done in many ways...',
        'category': 'Flutter',
        'author': 'Diana',
        'likes': 91,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 4))),
      },
      {
        'title': 'Firebase Authentication Tutorial',
        'content': 'Firebase Auth makes it easy to add login to your app...',
        'category': 'Firebase',
        'author': 'Eve',
        'likes': 55,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 5))),
      },
      {
        'title': 'Dart Async/Await Made Simple',
        'content':
            'Async programming in Dart is powerful and easy once understood...',
        'category': 'Dart',
        'author': 'Frank',
        'likes': 67,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 6))),
      },
      {
        'title': 'Building Beautiful Flutter UIs',
        'content':
            'Flutter provides many widgets to create stunning user interfaces...',
        'category': 'Flutter',
        'author': 'Grace',
        'likes': 23,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7))),
      },
      {
        'title': 'Firestore Security Rules',
        'content': 'Secure your Firestore database with proper rules...',
        'category': 'Firebase',
        'author': 'Henry',
        'likes': 44,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 8))),
      },
      {
        'title': 'Dart Collections & Generics',
        'content':
            'Lists, Maps, and Sets are essential Dart data structures...',
        'category': 'Dart',
        'author': 'Iris',
        'likes': 88,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 9))),
      },
      {
        'title': 'Flutter Navigation & Routing',
        'content':
            'Navigate between screens easily with Flutter\'s Navigator...',
        'category': 'Flutter',
        'author': 'Jack',
        'likes': 72,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 10))),
      },
      {
        'title': 'Cloud Functions for Firebase',
        'content':
            'Run backend code without managing servers using Cloud Functions...',
        'category': 'Firebase',
        'author': 'Karen',
        'likes': 39,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 11))),
      },
      {
        'title': 'Dart Object-Oriented Programming',
        'content': 'Learn classes, inheritance and polymorphism in Dart...',
        'category': 'Dart',
        'author': 'Leo',
        'likes': 51,
        'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 12))),
      },
    ];

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var postData in samplePosts) {
      DocumentReference docRef = _postsCollection.doc();
      batch.set(docRef, postData);
    }

    await batch.commit();
    print('Sample posts added successfully!');
  }

  Future<QuerySnapshot> getFirstPage({
    String? category,
    String sortBy = 'timestamp',
  }) async {
    Query query = _postsCollection;
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    query = query.orderBy(sortBy, descending: true);
    query = query.limit(pageSize);
    return await query.get();
  }

  Future<QuerySnapshot> getNextPage({
    required DocumentSnapshot lastDocument,
    String? category,
    String sortBy = 'timestamp',
  }) async {
    Query query = _postsCollection;

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    query = query.orderBy(sortBy, descending: true);
    query = query.startAfterDocument(lastDocument);
    query = query.limit(pageSize);

    return await query.get();
  }

  Future<QuerySnapshot> searchPosts(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return await getFirstPage();
    }

    String searchEnd = searchTerm + '\uf8ff';

    return await _postsCollection
        .orderBy('title')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: searchEnd)
        .limit(pageSize)
        .get();
  }

  Future<QuerySnapshot> getPostsByCategories({
    required List<String> categories,
    String sortBy = 'timestamp',
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _postsCollection
        .where('category', whereIn: categories)
        .orderBy(sortBy, descending: true)
        .limit(pageSize);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  List<Post> convertToPosts(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }
}
