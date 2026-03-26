import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_profile_app/Post/create_post.dart';
import 'package:social_profile_app/Post/user_post_screen.dart';
import 'package:social_profile_app/Profile/profile_page.dart';
import 'package:social_profile_app/Profile/profile_provider.dart';
import 'package:social_profile_app/User%20Authentication/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load current user's profile when home screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final List<Widget> pages = [
      const _FeedPlaceholder(), // Tab 0: Feed
      const _SearchPlaceholder(), // Tab 1: Search
      const UserPostsScreen(), // Tab 2: Add Post
      const ProfilePage(), // Tab 3: My Profile
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D14),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFE94560),
          unselectedItemColor: Colors.white.withOpacity(0.3),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedPlaceholder extends StatelessWidget {
  const _FeedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'SocialSnap',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 56, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(
              'Feed coming soon!',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 56, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(
              'Search coming soon!',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

// class _AddPostPlaceholder extends StatelessWidget {
//   const _AddPostPlaceholder();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0F),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.add_circle_outline,
//               size: 56,
//               color: Colors.white.withOpacity(0.15),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Add Post coming soon!',
//               style: TextStyle(color: Colors.white.withOpacity(0.3)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
