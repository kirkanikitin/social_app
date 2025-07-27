import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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


class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
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
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.userId)
                )
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  postUser?.profileImageUrl != null ? CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(color: Theme.of(context).colorScheme.inverseSurface),
                    errorWidget: (context, url, error) =>
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.inversePrimary
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 37,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  ) : Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 37,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.post.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
        Hero(
          tag: 'post_${widget.post.id}',
          child: CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 510,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 520),
            errorWidget: (context, url, error) => const Icon(Icons.error_outline),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 15),
            SizedBox(
              width: 50,
              child: Row(
                children: [
                  GestureDetector(
                      onTap: toggleLikePost,
                      child: Icon(
                        widget.post.likes.contains(currentUser!.uid)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        size: 32,
                        color: widget.post.likes.contains(currentUser!.uid)
                         ? Colors.red
                         : Colors.black
                      )
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.post.likes.length.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: openNewCommentBox,
              child: const Icon(
                Icons.mode_comment_outlined,
                  size: 30
              ),
            ),
            const SizedBox(width: 5),
            Text(
              widget.post.comments.length.toString(),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
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
