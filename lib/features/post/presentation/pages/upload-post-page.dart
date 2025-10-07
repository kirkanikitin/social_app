import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app-user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post-states.dart';
import 'package:social_app/features/profile/presentation/components/text-field-edit.dart';
import '../../../profile/presentation/cubits/profile-cubit.dart';
import '../../../profile/presentation/cubits/profile-states.dart';

class UploadPostPage extends StatefulWidget {
  final Uint8List editedImage;
  final VoidCallback? onPostUploaded;

  const UploadPostPage({
    super.key,
    required this.editedImage,
    required this.onPostUploaded,
  });

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final textController = TextEditingController();
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    setState(() {
      currentUser = authCubit.currentUser;
    });
  }

  void uploadPost() async {
    getCurrentUser();

    final profileState = context.read<ProfileCubit>().state;
    String profileImageUrl = '';

    if (profileState is ProfileLoaded) {
      profileImageUrl = profileState.profileUser.profileImageUrl;
    }

    final ui.Image decodedImage = await decodeImageFromList(widget.editedImage);
    final int imageWidth = decodedImage.width;
    final int imageHeight = decodedImage.height;

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    final postCubit = context.read<PostCubit>();
    postCubit.createPost(newPost, imageBytes: widget.editedImage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          if (widget.onPostUploaded != null) {
            widget.onPostUploaded!();
          }
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // закрываем клавиатуру
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          centerTitle: true,
          title: const Text(
            'New publication',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          actions: [
            IconButton(
              onPressed: uploadPost,
              icon: const Icon(
                Icons.check_sharp,
                size: 30,
                color: Colors.blue,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.memory(widget.editedImage, height: 400, fit: BoxFit.cover),
                const SizedBox(height: 50),
                MyTextFieldEdit(
                  controller: textController,
                  textCatapilization: TextCapitalization.sentences,
                  hintText: 'Add a description',
                  obcureText: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
