import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/domain/entities/profile-user.dart';
import 'package:social_app/features/profile/presentation/components/text-field-edit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final bioTextController = TextEditingController();

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

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    final String uid = widget.user.uid;
    final String? newBio =
    bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    if (newBio != null || imageMobilePath != null || imageWebBytes != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
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
        } else if (state is ProfileError) {}
        return buildEditPage();
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          print('UI: Профиль успешно обновлен, закрываем страницу');
          Navigator.pop(context);
        }
      }
    );
  }
  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: updateProfile,
              icon: const Icon(
                Icons.check_sharp,
                size: 30,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  clipBehavior: Clip.hardEdge,
                  child:
                    (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                      File(imagePickedFile!.path!),
                      fit: BoxFit.cover,
                      )
                      :
                    (kIsWeb && webImage != null)
                      ? Image.memory(webImage!,
                        fit: BoxFit.cover,

                    )
                      :
                    CachedNetworkImage(
                      imageUrl: widget.user.profileImageUrl,
                      placeholder: (context, url) =>
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.inverseSurface
                        ),
                      errorWidget: (context, url, error) =>
                          Icon(
                            Icons.person,
                            size: 54,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                      imageBuilder: (context, imageProvider) => 
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                    ),
              ),
            const SizedBox(height: 15),
            GestureDetector(
                onTap: pickImage,
                child: const Text(
                    'Change your avatar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue
                  ),
                ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(right: 165),
              child: Text(
                  'Add a short description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.inverseSurface
                ),
              ),
            ),
            const SizedBox(height: 5),
            MyTextFieldEdit(
              controller: bioTextController,
              textCatapilization: TextCapitalization.sentences,
              hintText: widget.user.bio,
              obcureText: false,
            )
          ],
        ),
      ),
    );
  }
}
