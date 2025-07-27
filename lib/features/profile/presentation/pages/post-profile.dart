import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/presentation/pages/post-profile-view.dart';
import '../../../post/presentation/cubits/post-cubit.dart';
import '../../../post/presentation/cubits/post-states.dart';

class MyPost extends StatefulWidget {
  final String uid;
  const MyPost({super.key, required this.uid});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoaded) {
          final userPosts = state.posts
              .where((post) => post.userId == widget.uid)
              .toList();

          return GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              final post = userPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostPageView(
                        posts: userPosts,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'post_${post.id}',
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          );
        } else if (state is PostsLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          );
        } else {
          return const Center(
            child: Text('No posts...'),
          );
        }
      },
    );
  }
}
