import 'package:flutter/material.dart';
import '../../../post/presentation/components/post-tile.dart';
import '../../../post/domain/entities/post.dart';

class PostPageView extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;

  const PostPageView({super.key, required this.posts, required this.initialIndex});

  @override
  State<PostPageView> createState() => _PostPageViewState();
}

class _PostPageViewState extends State<PostPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return SafeArea(
            child: PostTile(
              post: post,
              showHero: true,
              onDeletePressed: () {
                setState(() {
                  widget.posts.removeAt(index);
                });
                if (widget.posts.isEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
    );
  }
}