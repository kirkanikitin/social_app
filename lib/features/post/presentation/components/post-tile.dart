import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:social_app/features/profile/presentation/pages/profile-page.dart';
import 'package:social_app/home/presentation/components/more-menu.dart';
import 'package:social_app/features/post/presentation/components/comment-bottom-sheet.dart';
import '../../../auth/domain/entities/app-user.dart';
import 'dart:ui';
import '../../../profile/presentation/components/safe-image.dart';

class PostImage extends StatelessWidget {
  final String imageUrl;
  final bool useHero;
  final String heroTag;
  final double aspectRatio;

  const PostImage({
    super.key,
    required this.imageUrl,
    required this.aspectRatio,
    this.useHero = false,
    this.heroTag = '',
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    Widget image = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double height = width / aspectRatio;

        if (height > maxHeight) {
          height = maxHeight;
        }

        return SizedBox(
          width: width,
          height: height,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );

    if (useHero) {
      return Hero(tag: heroTag, child: image);
    }
    return image;
  }
}

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  final bool showHero;
  final VoidCallback? goToOwnProfile;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
    this.showHero = false,
    this.goToOwnProfile,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with SingleTickerProviderStateMixin {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AnimationController _controller;
  late Animation<double> _scale;

  bool isOwnPost = false;

  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (!mounted) return; // <== добавь вот это
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        _controller.forward().then((_) => _controller.reverse());
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentController = TextEditingController();

  void openNewCommentBox() {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierLabel: "CommentSheet",
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                type: MaterialType.transparency,
                child: CommentBottomSheet(
                  post: widget.post,
                  currentUser: currentUser!,
                  commentController: TextEditingController(),
                  addComment: (comment) {
                    postCubit.addComment(widget.post.id, comment);
                  },
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Delete post?',
          style: TextStyle(

          ),
        ),
        actions: [
          CupertinoDialogAction(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue
                ),
              ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red
              ),
            ),
            onPressed: () {
              widget.onDeletePressed!();
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(widget.post.timestamp);
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (isOwnPost) {
                  widget.goToOwnProfile?.call();
                } else {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ProfilePage(uid: widget.post.userId),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                }
              },
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  avatarFromUrl(
                    context: context,
                    url: postUser?.profileImageUrl,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondaryContainer
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isOwnPost)
                  MoreMenu(
                    onDeletePressed: showOptions,
                    icons: const Icon(Icons.more_horiz, color: Colors.black54),
                  ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        widget.showHero
            ? PostImage(
          imageUrl: widget.post.imageUrl,
          aspectRatio: widget.post.aspectRatio,
          useHero: true,
          heroTag: 'post_${widget.post.id}',
        )
            : PostImage(
          imageUrl: widget.post.imageUrl,
          aspectRatio: widget.post.aspectRatio,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 10),
            SizedBox(
              width: 50,
              child: Row(
                children: [
                  GestureDetector(
                      onTap: toggleLikePost,
                      child: ScaleTransition(
                        scale: _scale,
                        child: widget.post.likes.contains(currentUser!.uid)
                          ?
                          const Image(
                            image: AssetImage('lib/assets/icons/red-heart.png'),
                            height: 25,
                            color: Colors.redAccent,
                          ) :
                          Padding(
                            padding: const EdgeInsets.only(bottom: 9, right: 8),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.matrix(
                                Matrix4.diagonal3Values(1.5, 1.5, 1).storage,
                              ),
                              child: Image.asset(
                                  'lib/assets/icons/heart2.png',
                                  height: 17,
                                  color: Theme.of(context).colorScheme.secondaryContainer
                              ),
                            ),
                          )
                      )
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.post.likes.length.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(bottom: 9, right: 8),
              child: GestureDetector(
                onTap: openNewCommentBox,
                child: ImageFiltered(
                  imageFilter: ImageFilter.matrix(
                    Matrix4.diagonal3Values(1.5, 1.5, 1).storage,
                  ),
                  child: Image.asset(
                      'lib/assets/icons/comment.png',
                      height: 20,
                      color: Theme.of(context).colorScheme.secondaryContainer
                  ),
                )

              ),
            ),
            const SizedBox(width: 5),
            Text(
              widget.post.comments.length.toString(),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.inversePrimary
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.post.text),
          ),
        ),
      ],
    );
  }
}
