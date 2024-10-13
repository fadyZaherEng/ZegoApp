import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego/src/presentations/screens/search/search_screen.dart';
import 'package:zego/src/presentations/screens/sing_in/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _postTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Center(child: Text('Dashboard')),
            ),
            ListTile(
              title: const Text('Sign out'),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    ));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(actions: [
        Container(
          padding: const EdgeInsets.all(2.0),
          margin: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black12,
          ),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
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
            _postWidget(),
          ],
        ),
      ),
    );
  }

  bool postIsText = true;

  Widget _postWidget() {
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
                value: postIsText,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (value) {
                  setState(() {
                    postIsText = value!;
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                postIsText ? 'Text' : 'Image',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
            ),
            controller: _postTextController,
          ),
          if (!postIsText) const SizedBox(height: 10),
          if (!postIsText) _imagePickerWidget(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _uploadPost(postIsText ? 'text' : 'image');
            },
            child: const Text('Post'),
          )
        ],
      ),
    );
  }

  String imageUrl = '';

  Widget _imagePickerWidget() {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageUrl != '')
            Image.file(
              File(imageUrl),
              height: 200,
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
              _pickImageFromGallery();
            },
            child: const Text('Upload'),
          )
        ],
      ),
    );
  }

  void _pickImageFromGallery() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        //upload to firebase storage
        FirebaseStorage.instance
            .ref()
            .child('images/${value.name}')
            .putFile(File(value.path))
            .then((value) {
          value.ref.getDownloadURL().then((value) {
            setState(() {
              imageUrl = value;
            });
          });
        });
      }
    });
  }

  void _uploadPost(String type) {
    var postData = {
      "type": type == "image" ? "image" : "text",
      "time": DateTime.now(),
      "brefForImage": type == "image" ? _postTextController.text : '',
      "content": type == "image" ? imageUrl : _postTextController.text,
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
      });
      _postTextController.clear();
      imageUrl = '';
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post Successful'),
        ),
      );
    }).catchError((error) {
      imageUrl = '';
      _postTextController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    });
  }
}
