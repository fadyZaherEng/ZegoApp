import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/domain/entities/chat/last_massage.dart';
import 'package:zego/src/domain/usecase/get_user_use_case.dart';
import 'package:zego/src/presentations/screens/chats/widgets/massage_to_show_widget.dart';
import 'package:zego/src/presentations/screens/my_chats/widgets/unread_massage_counter_widget.dart';
import 'package:zego/src/presentations/widgets/user_image_widget.dart';

class LastMassageChatWidget extends StatelessWidget {
  final LastMassage? chats;
  final bool isGroup;
  final void Function() onTap;

  const LastMassageChatWidget({
    super.key,
    this.chats,
    required this.isGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //get uid
    final uid = GetUserUseCase(injector())().uid;
    //get the last massage
    final lastMassage = chats?.massage;
    //get sender uid
    final senderId = chats?.senderId;
    //get date and time
    final dateTime = chats?.timeSent;
    final time = DateFormat("hh:mm a").format(dateTime ?? DateTime.now());
    //get image url
    final imageUrl = chats?.receiverImage;
    //get the name
    final name = chats?.receiverName;
    //get receiver id
    final receiverId = chats?.receiverId;
    //get the massage type
    final massageType = chats?.massageType;
    return ListTile(
      titleAlignment: ListTileTitleAlignment.bottom,
      title: Text(
        name ?? "",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            uid == senderId
                ? const Text(
                    "You: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 5),
            Expanded(
              child: MassageToShowWidget(
                massageType: massageType!,
                massage: lastMassage!,
              ),
            ),
          ],
        ),
      ),
      leading: UserImageWidget(
        image: imageUrl!,
        width: 50,
        height: 50,
        isBorder: false,
      ),
      trailing: Column(
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          UnReadMassageCounterWidget(
            uid: uid,
            receiverId: receiverId!,
            isGroup: isGroup,
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
