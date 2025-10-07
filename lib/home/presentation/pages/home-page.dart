import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post-states.dart';
import 'package:social_app/features/post/presentation/components/post-tile.dart';
import '../../../features/auth/presentation/cubits/auth_cubit.dart';

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
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          );
        } else if (state is PostsLoaded) {
          final currentUserId = context.read<AuthCubit>().currentUser!.uid;
          final posts =
          context.read<PostCubit>().getPostsExcludingUser(currentUserId);

          if (posts.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('No post available'),
              ),
            );
          }

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                  SliverAppBar(
                  floating: true,  // появляется при скролле вверх
                  snap: false,      // "прилипает", а не остаётся наполовину
                  pinned: true,    // всегда остаётся белая полоска
                  toolbarHeight: 5,
                  expandedHeight: 60,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              'Instagrym',
                              style: TextStyle(
                                fontFamily: 'Billabong',
                                fontSize: 40,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.matrix(
                                      Matrix4.diagonal3Values(1.5, 1.5, 1).storage,
                                    ),
                                    child: Image.asset(
                                        'lib/assets/icons/heart2.png',
                                        height: 16,
                                        color: Theme.of(context).colorScheme.secondaryContainer
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8, bottom: 2),
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.matrix(
                                      Matrix4.diagonal3Values(1.5, 1.5, 1).storage,
                                    ),
                                    child: Image.asset(
                                        'lib/assets/icons/chat.png',
                                        height: 16,
                                        color: Theme.of(context).colorScheme.secondaryContainer
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // список постов
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = posts[index];
                      return PostTile(
                        post: post,
                        onDeletePressed: () => deletePost(post.id),
                        goToOwnProfile: () {
                          widget.controller.index = 3;
                        },
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
              ],
            ),
          );
        } else if (state is PostsError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
