import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final int likes;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.likes,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      content: data['content'] ?? 'No Content',
      category: data['category'] ?? 'General',
      author: data['author'] ?? 'Unknown',
      likes: data['likes'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'likes': likes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
