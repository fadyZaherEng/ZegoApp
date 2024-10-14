import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zego/src/domain/entities/chat/last_massage.dart';
import 'package:zego/src/presentations/screens/chats/chat_screen.dart';
import 'package:zego/src/presentations/screens/my_chats/widgets/last_massage_chat_widget.dart';
import 'package:zego/src/presentations/widgets/cricle_loading_widget.dart';

class MyChatsStream extends StatelessWidget {
  final Stream<List<LastMassage>> myChatsStream;

  const MyChatsStream({
    super.key,
    required this.myChatsStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LastMassage>>(
      stream: myChatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleLoadingWidget();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Something Went Wrong",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data!.isEmpty ||
            snapshot.data == null) {
          return Center(
            child: Text(
              "No Found Chats Until Now",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
          );
        }
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView.separated(
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                final chats = snapshot.data![index];
                return LastMassageChatWidget(
                  chats: chats,
                  isGroup: false,
                  onTap: () {
                    //TODO: navigate to chat screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          friendId: chats.receiverId,
                          friendName: chats.receiverName,
                          friendImage: chats.receiverImage,
                          groupId: "",
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
          );
        } else {
          return const Center(
            child: Text("No Chats Found"),
          );
        }
      },
    );
  }
}
