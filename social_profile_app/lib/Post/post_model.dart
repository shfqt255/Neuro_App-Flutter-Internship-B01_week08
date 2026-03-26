class Post {
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String caption;
  final int likesCount;
  final DateTime createdAt;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    this.caption = '',
    this.likesCount = 0,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map, String postId) {
    return Post(
      postId: postId,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      caption: map['caption'] ?? '',
      likesCount: map['likesCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'caption': caption,
      'likesCount': likesCount,
      'createdAt': createdAt,
    };
  }
}
