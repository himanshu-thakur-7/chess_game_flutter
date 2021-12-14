import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  const UserImagePicker({Key? key, required this.imagePickFn})
      : super(key: key);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    ImagePicker ip = ImagePicker();
    final XFile? image = await ip.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = File(image!.path);
    });
    widget.imagePickFn(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pickedImage == null
            ? CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                radius: 40,
                backgroundImage: const AssetImage("graphics/face.webp"),
              )
            : CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                radius: 40,
                backgroundImage: FileImage(_pickedImage!),
              ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              Icons.image,
              color: Theme.of(context).accentColor,
            ),
            label: Text(
              'Add Image',
              style: TextStyle(
                color: Theme.of(context).accentColor,
              ),
            )),
      ],
    );
  }
}
