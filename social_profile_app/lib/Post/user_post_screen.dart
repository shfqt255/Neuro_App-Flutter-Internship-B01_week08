import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_profile_app/Post/create_post.dart';
import 'create_post_provider.dart';

class UserPostsScreen extends StatelessWidget {
  const UserPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreatePostProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.userPosts.isEmpty
          ? Center(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePostScreen()),
                ),
                icon: const Icon(Icons.add_box_outlined),
              ),
            )
          : ListView.builder(
              itemCount: provider.userPosts.length,
              itemBuilder: (context, index) {
                final post = provider.userPosts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(post.userPhotoUrl),
                    ),
                    title: Text(post.username),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.caption),
                        Text(
                          post.createdAt.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
