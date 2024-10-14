import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego/src/config/theme/color_schemes.dart';
import 'package:zego/src/domain/entities/user_model.dart';
import 'package:zego/src/presentations/screens/home.dart';
import 'package:zego/src/presentations/widgets/user_image_widget.dart';

class ChatAppBarWidget extends StatelessWidget {
  final String friendId;

  const ChatAppBarWidget({
    super.key,
    required this.friendId,
  });

  @override
  Widget build(BuildContext context) {
    print("friendId: $friendId");
    return StreamBuilder(
      stream: _getUserStream(friendId: friendId),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const CircleLoadingWidget();
        // }
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data.data() ?? {});
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        //TODO: navigate to profile screen
                        // Navigator.pushNamed(
                        //   context,
                        //   Routes.profileScreen,
                        //   arguments: {"userId": user.uId},
                        // );
                      },
                      child: UserImageWidget(image: user.image),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.isOnline
                              ? "Online"
                              : timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(user.lastSeen)),
                                ),
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: user.isOnline
                                ? ColorSchemes.green
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //TODO: add back arrow
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      textDirection: TextDirection.rtl,
                      color: Theme.of(context).iconTheme.color,
                      // textDirection: TextDirection.rtl,
                    )),
                //icon video call
                IconButton(
                    onPressed: () {
                      //TODO: navigate to video call
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  HomePage(userId: friendId,),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call)),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Stream _getUserStream({required String friendId}) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(friendId)
          .snapshots();
    } catch (e) {
      return Stream.value({});
    }
  }
}
