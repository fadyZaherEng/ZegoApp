import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zego/src/presentations/screens/chat/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {});
                    } else {
                      _searchController.text = value;
                      setState(() {});
                    }
                  }),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .orderBy("name")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No user found'),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          bool isMatch = snapshot.data!.docs[index]['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());
                          if (isMatch) {
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: IconButton(
                                onPressed: () {
                                  //TODO: chat screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                              ),
                              title: Text(
                                snapshot.data!.docs[index]['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: StreamBuilder<DocumentSnapshot>(
                                stream: doc.reference
                                    .collection("followers")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data?.exists ?? false) {
                                      return TextButton(
                                        onPressed: () {
                                          doc.reference
                                              .collection("followers")
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .delete();
                                        },
                                        child: const Text('Un Follow'),
                                      );
                                    }
                                    return TextButton(
                                      onPressed: () {
                                        doc.reference
                                            .collection("followers")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .set({
                                          "time": DateTime.now(),
                                        });
                                      },
                                      child: const Text('Follow'),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
