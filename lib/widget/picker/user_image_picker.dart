import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(XFile pickedImage) imagePickFn;
  const UserImagePicker({Key? key, required this.imagePickFn})
      : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedImage;

  Future getImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 150,
      );

      if (image == null) return;

      _pickedImage = XFile(image.path);
      setState(() {
        _pickedImage = image;
      });
      widget.imagePickFn(image);
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future getImageFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
      );

      if (image == null) return;
      _pickedImage = XFile(image.path);

      setState(() {
        _pickedImage = image;
      });
      widget.imagePickFn(image);
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showPicker(context);
          },
          child: _pickedImage != null
              ? CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 40,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: Image.file(
                      io.File(_pickedImage!.path),
                      fit: BoxFit.cover,
                    ).image,
                  ),
                )
              : Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
        ),
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      getImageFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    getImageFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
