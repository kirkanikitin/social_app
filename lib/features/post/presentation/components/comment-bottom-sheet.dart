import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/components/text-field-comment.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post-states.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/domain/entities/app-user.dart';

class CommentBottomSheet extends StatefulWidget {
  final Post post;
  final AppUser currentUser;
  final Comment? comment;
  final TextEditingController commentController;
  final void Function(Comment) addComment;

  const CommentBottomSheet({
    super.key,
    required this.post,
    this.comment,
    required this.currentUser,
    required this.commentController,
    required this.addComment,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  AppUser? currentUser;
  bool isOwnPost = false;

  String timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн назад';
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentUser(); // ← ВЫЗОВ ТУТ

    if (widget.comment != null) {
      widget.commentController.text = widget.comment!.text;
    }
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;

    if (widget.comment != null && currentUser != null) {
      isOwnPost = widget.comment!.userId == currentUser!.uid;
    } else {
      isOwnPost = false;
    }
  }

  void showDeleteMenu(Comment comment) {
    final profileCubit = context.read<ProfileCubit>();
    final formattedDate = timeAgo(comment.timestamp);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Comment',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Сам комментарий
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FutureBuilder<ProfileUser?>(
                          future: profileCubit.getUserProfile(comment.userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child:  CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.inverseSurface
                                ),
                              );
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final user = snapshot.data!;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Аватар
                                CachedNetworkImage(
                                  imageUrl: user.profileImageUrl,
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const CircleAvatar(radius: 25),
                                  errorWidget: (context, url, error) => Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(Icons.person, size: 30),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Текст комментария и дата
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300,
                                          color: Theme.of(context).colorScheme.inversePrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        comment.text,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Кнопка удаления
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<PostCubit>().deleteComment(comment.postId, comment.id);
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text(
                                      'Удалить',
                                      style: TextStyle(color: Colors.red, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Container(
              padding: MediaQuery.of(context).viewInsets,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Comments',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 400,
                        child: BlocBuilder<PostCubit, PostState>(
                          builder: (context, state) {
                            if (state is PostsLoading) {
                              return Center(
                                child:  CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.inverseSurface
                                ),
                              );
                            }
                            if (state is PostsError) {
                              return Center(child: Text(state.message));
                            }
                            if (state is PostsLoaded) {
                              final post = state.posts.firstWhere(
                                      (post) => (post.id == widget.post.id));

                              if (post.comments.isNotEmpty) {
                                int showCommentCount = post.comments.length;

                                return ListView.builder(
                                  itemCount: showCommentCount,
                                  itemBuilder: (context, index) {
                                    final comment = post.comments[index];
                                    final formattedDate = timeAgo(comment.timestamp);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                      child: FutureBuilder<ProfileUser?>(
                                        future: profileCubit.getUserProfile(comment.userId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Container(
                                              height: 40,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.grey.shade200,
                                              ),
                                            );
                                          }

                                          if (snapshot.hasError || !snapshot.hasData) {
                                            return const SizedBox.shrink();
                                          }

                                          final user = snapshot.data!;
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: user.profileImageUrl,
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
                                                placeholder: (context, url) => const CircleAvatar(radius: 25),
                                                errorWidget: (context, url, error) =>
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey[300],
                                                      ),
                                                      child: const Icon(Icons.person, size: 30),
                                                    ),
                                              ),
                                              const SizedBox(width: 15),
                                              if (comment.userId != widget.currentUser.uid)
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          comment.userName ?? 'null',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w700,
                                                            color: Theme
                                                                .of(context)
                                                                .colorScheme
                                                                .secondaryFixed,
                                                          ),
                                                      ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          formattedDate,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w300,
                                                            color: Theme
                                                                .of(context)
                                                                .colorScheme
                                                                .inversePrimary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      comment.text,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (comment.userId == widget.currentUser.uid)
                                                Expanded(
                                                  child: GestureDetector(
                                                    onLongPress: () {
                                                      showDeleteMenu(comment);
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                comment.userName ?? 'null',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Theme
                                                                      .of(context)
                                                                      .colorScheme
                                                                      .secondaryFixed,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Text(
                                                                formattedDate,
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w300,
                                                                  color: Theme.of(context).colorScheme.inversePrimary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 5),
                                                          Text(
                                                            comment.text,
                                                            style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      TextFieldComment(
                        controller: widget.commentController,
                        addComment: () {
                          if (widget.commentController.text.isEmpty) return;

                          final newComment = Comment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            postId: widget.post.id,
                            userId: widget.currentUser.uid,
                            userName: widget.currentUser.name,
                            text: widget.commentController.text,
                            timestamp: DateTime.now(),
                          );

                          if (mounted) {
                            context.read<PostCubit>().addComment(widget.post.id, newComment);
                          }

                          widget.commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
