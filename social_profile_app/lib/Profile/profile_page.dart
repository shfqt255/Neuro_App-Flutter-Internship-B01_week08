import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_profile_app/Profile/edit_profile.dart';
import 'package:social_profile_app/Profile/profile_provider.dart';
import 'package:social_profile_app/Profile/user_profile_model.dart';
import 'package:social_profile_app/User%20Authentication/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  final String? uid;
  const ProfilePage({super.key, this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final p = context.read<ProfileProvider>();
    final a = context.read<AuthProvider>();
    final uid = widget.uid ?? a.currentUser?.uid;
    if (uid != null) p.loadUserProfile(uid);
  }

  bool get _own {
    final a = context.read<AuthProvider>();
    return widget.uid == null || widget.uid == a.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Consumer<ProfileProvider>(
        builder: (_, p, __) {
          if (p.isLoading && p.viewedProfile == null) {
            return const _LoadingView();
          }
          final pr = p.viewedProfile;
          if (pr == null) return const _ErrorView();

          return _ProfileContent(
            profile: pr,
            posts: p.userPosts,
            isOwnProfile: _own,
            isFollowing: p.isFollowing,
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile profile;
  final List posts;
  final bool isOwnProfile;
  final bool isFollowing;

  const _ProfileContent({
    required this.profile,
    required this.posts,
    required this.isOwnProfile,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ProfileAppBar(profile: profile, isOwnProfile: isOwnProfile),
        SliverToBoxAdapter(
          child: _ProfileInfo(
            profile: profile,
            isOwnProfile: isOwnProfile,
            isFollowing: isFollowing,
          ),
        ),
        _PostsGrid(posts: posts),
      ],
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;

  const _ProfileAppBar({required this.profile, required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        if (isOwnProfile)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFE94560).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE94560), Color(0xFF0f3460)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFE94560).withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1a1a2e),
                      backgroundImage: profile.photoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(profile.photoUrl)
                          : null,
                      child: profile.photoUrl.isEmpty
                          ? Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      color: const Color(0xFFE94560).withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;
  final bool isFollowing;

  const _ProfileInfo({
    required this.profile,
    required this.isOwnProfile,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (profile.bio.isNotEmpty) ...[
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.75)),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                ProfileProvider.formatCount(profile.postsCount),
                'Posts',
              ),
              _StatItem(
                ProfileProvider.formatCount(profile.followersCount),
                'Followers',
              ),
              _StatItem(
                ProfileProvider.formatCount(profile.followingCount),
                'Following',
              ),
            ],
          ),
          const SizedBox(height: 16),
          isOwnProfile
              ? OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text('Edit Profile'),
                )
              : ElevatedButton(
                  onPressed: () {
                    final p = context.read<ProfileProvider>();
                    isFollowing
                        ? p.unfollowUser(profile.uid)
                        : p.followUser(profile.uid);
                  },
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count, label;
  const _StatItem(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }
}

class _PostsGrid extends StatelessWidget {
  final List posts;
  const _PostsGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text('No posts')));
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) =>
            CachedNetworkImage(imageUrl: posts[i].imageUrl, fit: BoxFit.cover),
        childCount: posts.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFE94560)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile not found', style: TextStyle(color: Colors.white)),
    );
  }
}
