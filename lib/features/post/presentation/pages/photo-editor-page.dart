import 'dart:io';
import 'dart:typed_data';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:social_app/features/post/presentation/pages/upload-post-page.dart';

class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({super.key});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  Uint8List? editedImage;

  Future<void> pickAndEditImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      Uint8List? imageBytes;

      if (kIsWeb) {
        imageBytes = result.files.first.bytes;
      } else {
        final path = result.files.first.path!;

        if (path.toLowerCase().endsWith(".heic")) {
          final jpgPath = await HeicToJpg.convert(path);
          if (jpgPath != null) {
            imageBytes = await File(jpgPath).readAsBytes();
          } else {
            debugPrint("Не удалось конвертировать HEIC → JPG");
            return;
          }
        } else {
          imageBytes = await File(path).readAsBytes();
        }
      }

      if (imageBytes == null) {
        debugPrint("❌ Не удалось загрузить изображение");
        return;
      }

      final output = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: imageBytes,
          ),
        ),
      );

      if (output != null) {
        setState(() {
          editedImage = output;
        });
      }
    }
  }


  void goToUploadPage() {
    if (editedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadPostPage(
          editedImage: editedImage!,
          onPostUploaded: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text(
          'Editing',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (editedImage != null)
            IconButton(
              icon: const Icon(
                Icons.check_sharp,
                size: 30,
                color: Colors.blue,
              ),
              onPressed: goToUploadPage,
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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Center(
          child: editedImage == null
              ? GestureDetector(
                  onTap: pickAndEditImage,
                  child: const Text(
                      'Choose a photo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      )
                  ),
               )
              : Image.memory(editedImage!, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
