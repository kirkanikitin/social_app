import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
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
  final VoidCallback? onPostUploaded;
  const UploadPostPage({
    super.key,
    required this.onPostUploaded,
  });

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  PlatformFile? imagePickedFile;
  Uint8List? webImage;
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

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadPost() async {
    getCurrentUser();

    if (imagePickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Both image and caption are required'),
        ),
      );
      return;
    }

    final profileState = context.read<ProfileCubit>().state;
    String profileImageUrl = '';

    if (profileState is ProfileLoaded) {
      profileImageUrl = profileState.profileUser.profileImageUrl;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    final postCubit = context.read<PostCubit>();
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit,PostState>(
      builder: (context, state) {
        print(state);
        if (state is PostsLoading || state is PostUploading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          print(state);
          if (widget.onPostUploaded != null) {
            widget.onPostUploaded!();
          }
          Navigator.pop(context);
        }
      },
    );
  }
  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'New publication',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: uploadPost,
                icon: const Icon(
                  Icons.check_sharp,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
          ]
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (kIsWeb && webImage != null)
                Image.memory(webImage!),
              if (!kIsWeb && imagePickedFile != null)
                Image.file(
                  height: 400,
                  width: 500,
                  File(imagePickedFile!.path!)),
              const Spacer(),
              GestureDetector(
                onTap: pickImage,
                child: const Text(
                  'Select Images',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyTextFieldEdit(
                controller: textController,
                textCatapilization: TextCapitalization.sentences,
                hintText: 'Add descriptions',
                obcureText: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
