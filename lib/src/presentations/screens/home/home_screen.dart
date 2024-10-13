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
            //ToDo List For TimeLine
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('timeline')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No post found'),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    return _timeLineWidget(doc['postId']);
                  },
                );
              },
            ),
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
  bool isLoading = false;

  Widget _imagePickerWidget() {
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
            setState(() {
              imageUrl = value;
              isLoading = false;
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

  Widget _timeLineWidget(String data) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('posts').doc(data).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No post found'),
          );
        }
        if (snapshot.data!.data() == null) {
          return const Center(
            child: Text('No post found'),
          );
        }
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (snapshot.data!.data()!['type'] == 'image')
                Text(
                  snapshot.data!.data()!['brefForImage'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              if (snapshot.data!.data()!['type'] == 'image'&& snapshot.data!.data()!['content'] != '')
                const SizedBox(height: 20),
              if (snapshot.data!.data()!['type'] == 'image'&& snapshot.data!.data()!['content'] != '')
                Center(
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.network(snapshot.data!.data()!['content'],
                        height: 120, errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('No image found'),
                      );
                    }),
                  ),
                ),
              if (snapshot.data!.data()!['type'] == 'text')
                Text(
                  snapshot.data!.data()!['content'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
