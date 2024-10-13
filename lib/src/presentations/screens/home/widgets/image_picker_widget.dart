import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final String imageUrl;
  final Function(String imageUrl) onImagePicked;

  const ImagePickerWidget({
    super.key,
    required this.onImagePicked,
    required this.imageUrl,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  bool isLoading = false;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
  }
  @override
  void didUpdateWidget(covariant ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    imageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black38.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != '')
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('No image found');
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                if (imageUrl == '')
                  IconButton(
                    icon: const Icon(
                      Icons.image,
                      size: 50,
                    ),
                    onPressed: () {},
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (imageUrl != '') {
                      imageUrl = '';
                      widget.onImagePicked(imageUrl);
                      setState(() {});
                    } else {
                      _pickImageFromGallery();
                    }
                  },
                  child: imageUrl != ''
                      ? const Icon(
                          Icons.delete,
                          size: 20,
                        )
                      : const Text('Upload'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickImageFromGallery() {
    setState(() {
      isLoading = true;
    });
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        //upload to firebase storage
        FirebaseStorage.instance
            .ref()
            .child('images/${value.name}')
            .putFile(File(value.path))
            .then((value) {
          value.ref.getDownloadURL().then((value) {
              imageUrl = value;
              widget.onImagePicked(value);
              isLoading = false;
          });
        });
      }
    });
  }
}
