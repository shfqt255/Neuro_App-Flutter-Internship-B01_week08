import 'package:flutter/material.dart';
import 'package:posts_app/posts_provider.dart';
import 'package:provider/provider.dart';
import 'package:posts_app/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<PostsProvider>();
      if (!provider.isLoadingMore &&
          provider.hasMorePosts &&
          !provider.isSearching) {
        provider.loadNextPage();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(provider),
      body: Column(
        children: [
          _buildSearchBar(provider),
          if (!provider.isSearching) _buildFilterBar(provider),
          Expanded(child: _buildPostList(provider)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(PostsProvider provider) {
    return AppBar(
      title: const Text(
        'Posts App',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add Sample Posts',
          onPressed: () async {
            if (provider.sampleDataAdded) {
              _showMessage('Sample data already added!');
              return;
            }
            _showMessage('Adding sample posts...');
            try {
              await context.read<PostsProvider>().addSamplePosts();
              _showMessage('12 sample posts added!');
            } catch (e) {
              _showError('Failed to add sample data: $e');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            _searchController.clear();
            context.read<PostsProvider>().loadFirstPage();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(PostsProvider provider) {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<PostsProvider>().searchPosts(value);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: ' Search posts by title...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PostsProvider>().clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFilterBar(PostsProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: provider.categories.map((category) {
                final isSelected = provider.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    checkmarkColor: Colors.deepPurple,
                    onSelected: (_) {
                      context.read<PostsProvider>().setCategory(category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Sort: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...provider.sortOptions.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: provider.sortBy == entry.key,
                      selectedColor: Colors.deepPurple.withOpacity(0.2),
                      onSelected: (selected) {
                        if (selected) {
                          context.read<PostsProvider>().setSortBy(entry.key);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Post count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${provider.posts.length} posts loaded'
              '${provider.hasMorePosts ? " (scroll for more)" : " (all loaded)"}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(PostsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text('Loading posts...'),
          ],
        ),
      );
    }

    if (provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              provider.isSearching
                  ? 'No posts found for your search'
                  : 'No posts yet!',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (!provider.isSearching) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  _showMessage('Adding sample posts...');
                  try {
                    await context.read<PostsProvider>().addSamplePosts();
                    _showMessage('12 sample posts added!');
                  } catch (e) {
                    _showError('Failed: $e');
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Sample Posts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PostsProvider>().loadFirstPage(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: provider.posts.length +
            (provider.isLoadingMore ? 1 : 0) +
            (provider.hasMorePosts && !provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Post card
          if (index < provider.posts.length) {
            return PostCard(post: provider.posts[index]);
          }

          if (provider.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.deepPurple),
                    SizedBox(height: 8),
                    Text('Loading more posts...'),
                  ],
                ),
              ),
            );
          }

          if (provider.hasMorePosts) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => context.read<PostsProvider>().loadNextPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Load More Posts'),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('All posts loaded!',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}
