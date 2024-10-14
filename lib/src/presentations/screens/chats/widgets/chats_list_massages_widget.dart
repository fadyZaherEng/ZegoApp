import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';
import 'package:zego/src/domain/entities/chat/massage.dart';
import 'package:zego/src/domain/entities/chat/massage_reply.dart';
import 'package:zego/src/domain/entities/user_model.dart';
import 'package:zego/src/presentations/blocs/chats/chats_bloc.dart';
import 'package:zego/src/presentations/screens/chats/skeleton/chats_skeleton.dart';
import 'package:zego/src/presentations/screens/chats/utils/show_reactions_dialog.dart';
import 'package:zego/src/presentations/screens/chats/widgets/massage_widget.dart';
import 'package:zego/src/presentations/widgets/build_date_widget.dart';
import 'package:grouped_list/grouped_list.dart';

class ChatsListMassagesWidget extends StatefulWidget {
  final Stream<List<Massage>> massagesStream;
  final ScrollController massagesScrollController;
  final UserModel currentUser;
  final String friendId;
  final void Function(MassageReply massageReply) onRightSwipe;
  final void Function(String, Massage) onEmojiSelected;
  final void Function(String, Massage) onContextMenuSelected;
  final void Function(Massage) showEmojiKeyword;
  final void Function({
  required Massage message,
  required String currentUserId,
  required bool isSenderOrAdmin,
  }) deleteMessage;
  final String groupId;
  final void Function() setMassageReplyNull;

  const ChatsListMassagesWidget({
    super.key,
    required this.massagesStream,
    required this.massagesScrollController,
    required this.currentUser,
    required this.onRightSwipe,
    required this.friendId,
    required this.onEmojiSelected,
    required this.onContextMenuSelected,
    required this.showEmojiKeyword,
    required this.groupId,
    required this.setMassageReplyNull,
    required this.deleteMessage,
  });

  @override
  State<ChatsListMassagesWidget> createState() =>
      _ChatsListMassagesWidgetState();
}

class _ChatsListMassagesWidgetState extends State<ChatsListMassagesWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Massage>>(
          stream: widget.massagesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("Get massages error: ${snapshot.error}");
              return const ChatsSkeleton();
            }
            if (!snapshot.hasData ||
                snapshot.data != null && snapshot.data!.isEmpty) {
              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Start Conversation",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                );
              }
              return const ChatsSkeleton();
            }
            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Start Conversation",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final massages = snapshot.data ?? [];
              return GroupedListView<Massage, DateTime>(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                reverse: true,
                elements: massages,
                controller: widget.massagesScrollController,
                groupBy: (Massage massage) => DateTime(
                  massage.timeSent.year,
                  massage.timeSent.month,
                  massage.timeSent.day,
                ),
                groupHeaderBuilder: (Massage massage) => buildDateWidget(
                  context: context,
                  dateTime: massage.timeSent,
                ),
                useStickyGroupSeparators: true,
                floatingHeader: true,
                order: GroupedListOrder.DESC,
                itemBuilder: (BuildContext context, Massage massage) {
                  // //add list view scroll to bottom
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   widget.massagesScrollController.animateTo(
                  //     widget.massagesScrollController.position.minScrollExtent,
                  //     duration: const Duration(milliseconds: 300),
                  //     curve: Curves.easeInOut,
                  //   );
                  // });

                  //set massage as seen in fireStore
                  if (widget.groupId.isNotEmpty) {
                    BlocProvider.of<ChatsBloc>(context).setMassageAsSeen(
                      senderId: widget.currentUser.uid,
                      receiverId: widget.friendId,
                      massageId: massage.messageId,
                      isGroupChat: widget.groupId.isNotEmpty,
                      isSeenByList: massage.isSeenBy,
                    );
                  } else {
                    if (massage.isSeen == false &&
                        massage.senderId != widget.currentUser.uid) {
                      BlocProvider.of<ChatsBloc>(context).setMassageAsSeen(
                        senderId: widget.currentUser.uid,
                        receiverId: widget.friendId,
                        massageId: massage.messageId,
                        isGroupChat: widget.groupId.isNotEmpty,
                        isSeenByList: massage.isSeenBy,
                      );
                    }
                  }
                  bool isMe = massage.senderId == widget.currentUser.uid;
                  //check if massage delete by current user
                  final deletedByCurrentUser =
                  massage.isDeletedBy.contains(widget.currentUser.uid);

                  return deletedByCurrentUser
                      ? _deletedMassageWidget(
                    context: context,
                    isMe: isMe,
                    massage: massage,
                  )
                      : GestureDetector(
                    onLongPress: () async {
                      //TODO: Chat Reactions By Myself
                      if (deletedByCurrentUser) return;
                      //TODO: Chat Reactions By Myself
                      _showReactionDialog(isMe, massage, context);
                      //TODO: Chat Reactions By Package
                      //using by package flutter_chat_reaction
                      // _showReactionDialogByPackage(
                      //   isMe: isMe,
                      //   massage: massage,
                      //   context: context,
                      // );
                    },
                    child: MessageWidget(
                      message: massage,
                      isMe: isMe,
                      uid: widget.currentUser.uid,
                      onRightSwipe: () {
                        final massageReply = MassageReply(
                          massage: massage.massage,
                          senderName: massage.senderName,
                          senderId: massage.senderId,
                          senderImage: massage.senderImage,
                          massageType: massage.massageType,
                          isMe: isMe,
                        );
                        // _bloc.setMassageReply(massageReply);
                        widget.onRightSwipe(massageReply);
                      },
                      setMassageReplyNull: () {
                        widget.setMassageReplyNull();
                      },
                    ),
                  );
                },
                itemComparator: (massage1, massage2) =>
                    massage1.timeSent.compareTo(massage2.timeSent),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  //reactions dialog
  void _showReactionDialog(bool isMe, massage, BuildContext context) {
    showReactionsDialog(
      context: context,
      massage: massage,
      isMe: isMe,
      currentUserId: widget.currentUser.uid,
      onContextMenuSelected: (emoji, massage) {
        widget.onContextMenuSelected(emoji, massage);
      },
      onEmojiSelected: (emoji, massage) {
        widget.onEmojiSelected(emoji, massage);
      },
      setMassageReplyNull: () {
        widget.setMassageReplyNull();
      },
    );
  }


  Widget _deletedMassageWidget({
    required BuildContext context,
    required bool isMe,
    required Massage massage,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 5, top: 5),
              child: InkWell(
                onTap: () {},
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.purple,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      massage.senderImage,
                      fit: BoxFit.fill,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Icon(Icons.cancel,
                              size: 40, color: Colors.grey.shade300),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SkeletonLine(
                            style: SkeletonLineStyle(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft:
                isMe ? const Radius.circular(15) : const Radius.circular(0),
                bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(15),
              ),
            ),
            color: Colors.grey,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "canceledSendingTheMessage",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
