import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego/src/presentations/screens/home/widgets/post_widget.dart';
import 'package:zego/src/presentations/screens/home/widgets/time_line_stream_widget.dart';

class HomeContentWidget extends StatefulWidget {
  const HomeContentWidget({super.key});

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> {
  final TextEditingController _postTextController = TextEditingController();
  String _imageUrl = '';
  bool _postIsText = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Welcome to Zego',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PostWidget(
            onImagePicked: (url) {
              _imageUrl = url;
              setState(() {});
            },
            imageUrl: _imageUrl,
            onPostIsTextChange: (value) {
              setState(() {
                _postIsText = value;
              });
            },
            postIsText: _postIsText,
            postTextController: _postTextController,
            uploadPost: (type) {
              _uploadPost(type);
            },
          ),
          //ToDo List For TimeLine
          const TimeLineStreamWidget(),
        ],
      ),
    );
  }
  void _uploadPost(String type) {
    var postData = {
      "type": type == "image" ? "image" : "text",
      "time": DateTime.now(),
      "brefForImage": type == "image" ? _postTextController.text : '',
      "content": type == "image" ? _imageUrl : _postTextController.text,
      "userId": FirebaseAuth.instance.currentUser!.uid,
    };
    FirebaseFirestore.instance.collection('posts').add(postData).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("timeline")
          .doc(value.id)
          .set({
        "postId": value.id,
        "time": DateTime.now(),
      });
      _postTextController.clear();
      _imageUrl = '';
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post Successful'),
        ),
      );
    }).catchError((error) {
      _imageUrl = '';
      _postTextController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    });
  }

}
