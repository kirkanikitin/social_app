import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post-states.dart';
import 'package:social_app/features/post/presentation/components/post-tile.dart';

class HomePage extends StatefulWidget {
  final PersistentTabController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPost();
  }

  void fetchAllPost() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Padding(
          padding: EdgeInsets.only(right: 230),
          child: Text(
            'Instagrym',
            style: TextStyle(
              fontFamily: 'Billabong',
              fontSize: 40,
            ),
          ),
        ),
      ),
      body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostsLoading || state is PostUploading) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .inverseSurface,
                  ),
                ),
              );
            } else if (state is PostsLoaded) {
              final allPosts = state.posts;
              if (allPosts.isEmpty) {
                return const Center(
                  child: Text('No post available'),
                );
              }
              return ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                    final post = allPosts[index];
                    return PostTile(
                      post: post,
                      onDeletePressed: () => deletePost(post.id),
                      goToOwnProfile: () {
                        widget.controller.index = 3;
                      },
                    );
                  },
              );
            } else if (state is PostsError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const SizedBox();
            }
          },
      ),
    );
  }
}
