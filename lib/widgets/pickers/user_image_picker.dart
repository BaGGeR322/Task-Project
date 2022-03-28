import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final _picker = ImagePicker();
    final imageFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 300,
    );
    if (imageFile == null) {
      return;
    }
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage =
        await File(imageFile.path).copy('${appDir.path}/$fileName');
    setState(() {
      _pickedImage = savedImage;
    });
    widget.imagePickFn(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        IconButton(
          iconSize: _pickedImage == null ? 30 : 0,
          onPressed: _pickImage,
          icon: const Icon(Icons.add),
        ),
        if (_pickedImage != null)
          const Positioned(
            bottom: -10,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.camera_alt_rounded,
                size: 16,
              ),
            ),
          ),
      ],
      clipBehavior: Clip.none,
    );
  }
}
