class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String bio;
  final String photoUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.bio = '',
    this.photoUrl = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt,
    };
  }

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? photoUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt,
    );
  }
}
