import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeLineWidget extends StatefulWidget {
  final String postId;
  const TimeLineWidget({super.key, required this.postId,});

  @override
  State<TimeLineWidget> createState() => _TimeLineWidgetState();
}

class _TimeLineWidgetState extends State<TimeLineWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
      FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
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
