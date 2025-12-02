import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:instagrym/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:instagrym/features/post/domain/entities/post.dart';
import 'package:instagrym/features/post/presentation/cubits/post-cubit.dart';
import 'package:instagrym/features/profile/domain/entities/profile-user.dart';
import 'package:instagrym/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:instagrym/features/profile/presentation/pages/profile-page.dart';
import 'package:instagrym/home/presentation/components/more-menu.dart';
import 'package:instagrym/features/post/presentation/components/comment-bottom-sheet.dart';
import '../../../auth/domain/entities/app-user.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../profile/presentation/components/safe-image.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int charLimit;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.charLimit = 150, // лимит символов
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String shortText;
  bool isExpanded = false;
  bool shouldTrim = false;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > widget.charLimit) {
      shouldTrim = true;
      shortText = widget.text.substring(0, widget.charLimit) + "…";
    } else {
      shortText = widget.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? widget.text : shortText,
          style: widget.style,
        ),
        if (shouldTrim)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? "скрыть" : "ещё",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: widget.style?.fontSize ?? 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
      ],
    );
  }
}

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

        if (height > maxHeight) height = maxHeight;

        return SizedBox(
          width: width,
          height: height,

          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,

            // 🔥 SHIMMER placeholder
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
              ),
            ),

            // ошибка загрузки
            errorWidget: (context, url, error) => Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
        );
      },
    );

    return useHero ? Hero(tag: heroTag, child: image) : image;
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

class _PostTileState extends State<PostTile> with TickerProviderStateMixin {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late AnimationController _controller;
  late Animation<double> _scale;
  bool showBigHeart = false;
  late AnimationController _bigHeartController;
  late Animation<double> _bigHeartScale;
  late Animation<double> _bigHeartOpacity;


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
    _bigHeartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bigHeartScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _bigHeartController, curve: Curves.easeOutBack),
    );

    _bigHeartOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _bigHeartController, curve: Curves.easeOut),
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

  void handleDoubleTapLike() {
    if (!widget.post.likes.contains(currentUser!.uid)) {
      toggleLikePost();
    }

    setState(() => showBigHeart = true);
    HapticFeedback.mediumImpact();

    _bigHeartController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => showBigHeart = false);
      }
    });
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        _controller.forward().then((_) => _controller.reverse());
        widget.post.likes.add(currentUser!.uid);
        HapticFeedback.mediumImpact();
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
    _bigHeartController.dispose();
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
        GestureDetector(
          onDoubleTap: handleDoubleTapLike,
          child: Stack(
            alignment: Alignment.center,
            children: [
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

              if (showBigHeart)
                AnimatedBuilder(
                  animation: _bigHeartController,
                  builder: (_, __) {
                    return Opacity(
                      opacity: _bigHeartOpacity.value,
                      child: Transform.scale(
                        scale: _bigHeartScale.value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 120,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExpandableText(
              text: widget.post.text,
              charLimit: 80,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondaryFixed,
              ),
            ),

          ),
        ),
      ],
    );
  }
}
