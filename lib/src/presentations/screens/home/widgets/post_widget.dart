import 'package:flutter/material.dart';
import 'package:zego/src/presentations/screens/home/widgets/image_picker_widget.dart';

class PostWidget extends StatefulWidget {
  final Function(String imageUrl) onImagePicked;
  final String imageUrl;
  bool postIsText;
  final Function(bool) onPostIsTextChange;
  TextEditingController postTextController;
  final Function(String) uploadPost;

  PostWidget({
    super.key,
    required this.onImagePicked,
    required this.postIsText,
    required this.onPostIsTextChange,
    required this.postTextController,
    required this.uploadPost,
    required this.imageUrl,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //change post type here image or text
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: widget.postIsText,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (value) {
                  bool newValue = !widget.postIsText;
                  widget.onPostIsTextChange(newValue);
                  widget.postIsText = newValue;
                  setState(() {});
                },
              ),
              const SizedBox(width: 10),
              Text(
                widget.postIsText ? 'Text' : 'Image',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
            ),
            controller: widget.postTextController,
          ),
          if (!widget.postIsText) const SizedBox(height: 10),
          if (!widget.postIsText)
            ImagePickerWidget(
              imageUrl: widget.imageUrl,
              onImagePicked: (url) {
                widget.onImagePicked(url);
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.uploadPost(widget.postIsText ? 'text' : 'image');
            },
            child: const Text('Post'),
          )
        ],
      ),
    );
  }
}
