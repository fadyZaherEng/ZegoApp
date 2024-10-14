// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zego/src/core/utils/enum/massage_type.dart';
import 'package:zego/src/domain/entities/chat/last_massage.dart';
import 'package:zego/src/domain/entities/chat/massage.dart';
import 'package:zego/src/domain/entities/chat/massage_reply.dart';
import 'package:zego/src/domain/entities/user_model.dart';

part 'chats_event.dart';

part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<GetAllUsersEvent>(_onGetAllUsersEvent);
    on<GetCurrentUserEvent>(_onGetCurrentUserEvent);
    on<SendTextMessageEvent>(_onSendTextMessageEvent);
    on<SendFileMessageEvent>(_onSendFileMessageEvent);
    on<SelectImageEvent>(_onSelectImageEvent);
    on<SelectVideoFromGalleryEvent>(_onSelectVideoFromGalleryEvent);
    on<SelectReactionEvent>(_onSelectReactionEven);
    on<DeleteMassageEvent>(_onDeleteMassageEvent);
  }

  //search query
  String _searchQuery = '';

  // getters
  String get searchQuery => _searchQuery;

  void setSearchQuery(String value) {
    _searchQuery = value;
    emit(SearchQueryState());
  }

  //replay message
  MassageReply? _massageReply;

  MassageReply? get massageReply => _massageReply;

  void setMassageReply(MassageReply? massageReply) {
    _massageReply = massageReply;
    emit(SetMassageReplyState(massageReply: massageReply));
  }

  FutureOr<void> _onGetAllUsersEvent(
      GetAllUsersEvent event, Emitter<ChatsState> emit) async {
    emit(GetUserChatsLoading());
    try {
      List<UserModel> users = [];
      await FirebaseFirestore.instance
          .collection("users")
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
        }
      });
      emit(GetUserChatsSuccess(users: users));
    } catch (e) {
      emit(GetUserChatsError(message: e.toString()));
    }
  }

  FutureOr<void> _onGetCurrentUserEvent(
      GetCurrentUserEvent event, Emitter<ChatsState> emit) async {
    emit(GetCurrentUserChatsLoading());
    try {
      UserModel user = UserModel();
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(event.uid)
          .get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      emit(GetCurrentUserChatsSuccess(user: user));
    } catch (e) {
      emit(GetCurrentUserChatsError(message: e.toString()));
    }
  }

  FutureOr<void> _onSendTextMessageEvent(
      SendTextMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendTextMessageLoading());
    //generate id to massage
    var massageId = const Uuid().v4();
    //check if massage is reply then add replied message to massage
    String repliedMessage = _massageReply?.massage ?? "";
    String repliedTo = _massageReply == null
        ? ""
        : _massageReply!.isMe
            ? "You"
            : _massageReply!.senderName;
    MassageType repliedMessageType =
        _massageReply?.massageType ?? MassageType.text;
    //update massage model with replied message
    final massage = Massage(
      senderId: event.sender.uid,
      senderName: event.sender.name,
      senderImage: event.sender.image,
      receiverId: event.receiverId,
      massage: event.message,
      massageType: event.massageType,
      timeSent: DateTime.now(),
      messageId: massageId,
      isSeen: false,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactions: [],
      isSeenBy: [event.sender.uid],
      isDeletedBy: [],
    );
    //check if group massage and send to group else send to contact
    if (event.groupId.isNotEmpty) {
      //handle group massage
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(event.groupId)
          .collection("messages")
          .doc(massageId)
          .set(massage.toJson());
      //update last massage for group
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(event.groupId)
          .update({
        "lastMessage": event.message,
        "timeSent": DateTime.now().millisecondsSinceEpoch,
        "senderId": event.sender.uid,
        "massageType": event.massageType.name,
      });
      //set massage reply to null
      setMassageReply(null);
      emit(SendTextMessageSuccess());
    } else {
      //handle contact massage
      await _handleContactMassage(
        massage: massage,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImage: event.receiverImage,
        success: () {
          emit(SendTextMessageSuccess());
        },
        failure: (String message) {
          emit(SendTextMessageError(message: message));
        },
      );
      //set massage reply to null
      setMassageReply(null);
    }
  }

  Future<void> _handleContactMassage({
    required Massage massage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    // try {
      final receiverMassage = massage.copyWith(receiverId: massage.senderId);
      //1-initialize last massage for sender
      final senderLastMassage = LastMassage(
        massage: massage.massage,
        senderId: massage.senderId,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        massageType: massage.massageType,
        timeSent: massage.timeSent,
        isSeen: false,
      );
      //2-initialize last massage for receiver
      final receiverLastMassage = senderLastMassage.copyWith(
        receiverId: massage.senderId,
        receiverName: massage.senderName,
        receiverImage: massage.senderImage,
      );
      //3-send massage to receiver
      //4-send massage to sender
      //5-send last massage to receiver
      //6-send last massage to sender
        print("receiverId: $receiverId");
        print("senderId: ${massage.senderId}");
      //1-send massage to receiver
      await FirebaseFirestore.instance
          .collection("users")
          .doc(receiverId)
          .collection("chats")
          .doc(massage.senderId)
          .collection("messages")
          .doc(massage.messageId)
          .set(receiverMassage.toJson());
      //2-send massage to sender
      await FirebaseFirestore.instance
          .collection("users")
          .doc(massage.senderId)
          .collection("chats")
          .doc(receiverId)
          .collection("messages")
          .doc(massage.messageId)
          .set(massage.toJson());
      success();
      //3-send last massage to receiver
      await FirebaseFirestore.instance
          .collection("users")
          .doc(receiverId)
          .collection("chats")
          .doc(massage.senderId)
          .set(receiverLastMassage.toJson());
      //4-send last massage to sender
      await FirebaseFirestore.instance
          .collection("users")
          .doc(massage.senderId)
          .collection("chats")
          .doc(receiverId)
          .set(senderLastMassage.toJson());
    // } catch (e) {
    //   failure(e.toString());
    // }
  }

  //get chats last massages stream
  Stream<List<LastMassage>> getChatsLastMassagesStream({
    required String userId,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("chats")
          .orderBy("timeSent", descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => LastMassage.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  //get massages stream
  Stream<List<Massage>> getMessagesStream({
    required String userId,
    required String receiverId,
    required String isGroup,
  }) {
    try {
      if (isGroup.isNotEmpty) {
        return FirebaseFirestore.instance
            .collection("groups")
            .doc(receiverId)
            .collection("messages")
            .orderBy("timeSent", descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => Massage.fromJson(doc.data()))
              .toList();
        });
      } else {
        //handle contact massage
        return FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("chats")
            .doc(receiverId)
            .collection("messages")
            .orderBy("timeSent", descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => Massage.fromJson(doc.data()))
              .toList();
        });
      }
    }catch (e) {
      return Stream.value([]);
    }
  }

  //set massage as seen
  Future<void> setMassageAsSeen({
    required String senderId,
    required String receiverId,
    required String massageId,
    required bool isGroupChat,
    required List<String> isSeenByList,
  }) async {
    try {
      //check if group
      if (isGroupChat) {
        //handle group massage as seen
        if (isSeenByList.contains(senderId)) {
          return;
        } else {
          //add the current user to isSeenByList in all massages
          await FirebaseFirestore.instance
              .collection("groups")
              .doc(receiverId)
              .collection("messages")
              .doc(massageId)
              .update({
            "isSeenBy": FieldValue.arrayUnion([senderId])
          });
        }
        emit(SetMassageAsSeenSuccess());
      } else {
        //check if contact
        //set massage as seen for sender
        await FirebaseFirestore.instance
            .collection("users")
            .doc(senderId)
            .collection("chats")
            .doc(receiverId)
            .collection("messages")
            .doc(massageId)
            .update({"isSeen": true});

        //set massage as seen for receiver
        await FirebaseFirestore.instance
            .collection("users")
            .doc(receiverId)
            .collection("chats")
            .doc(senderId)
            .collection("messages")
            .doc(massageId)
            .update({"isSeen": true});

        //set last massage as seen for sender
        await FirebaseFirestore.instance
            .collection("users")
            .doc(senderId)
            .collection("chats")
            .doc(receiverId)
            .update({"isSeen": true});

        //set last massage as seen for receiver
        await FirebaseFirestore.instance
            .collection("users")
            .doc(receiverId)
            .collection("chats")
            .doc(senderId)
            .update({"isSeen": true});
        emit(SetMassageAsSeenSuccess());
      }
    } catch (e) {
      print(e.toString());
      emit(SetMassageAsSeenError(message: e.toString()));
    }
  }

  //sent file massage
  Future<void> sentFileMessage({
    required UserModel sender,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String groupId,
    required File file,
    required BuildContext context,
    required MassageType massageType,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    //1-generate id to massage
    var massageId = const Uuid().v4();
    //2-check if massage is reply then add replied message to massage
    String repliedMessage = _massageReply?.massage ?? "";
    String repliedTo = _massageReply == null
        ? ""
        : _massageReply!.isMe
            ? "You"
            : _massageReply!.senderName;
    MassageType repliedMessageType =
        _massageReply?.massageType ?? MassageType.text;
    //3-upload file to storage
    String fileUrl = await saveImageToStorage(
      file,
      "chatFiles/${massageType.name}/${sender.uid}/$receiverId/$massageId.jpg",
    );
    //4-update massage model with replied message
    final massage = Massage(
      senderId: sender.uid,
      senderName: sender.name,
      senderImage: sender.image,
      receiverId: receiverId,
      massage: fileUrl,
      massageType: massageType,
      timeSent: DateTime.now(),
      messageId: massageId,
      isSeen: false,
      repliedMessage: repliedMessage,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      reactions: [],
      isDeletedBy: [],
      isSeenBy: [sender.uid],
    );
    //check if group massage and send to group else send to contact
    if (groupId.isNotEmpty) {
      //handle group massage
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .collection("messages")
          .doc(massageId)
          .set(massage.toJson());
      //update last massage for group
      await FirebaseFirestore.instance.collection("groups").doc(groupId).update(
        {
          "lastMessage": fileUrl,
          "timeSent": DateTime.now().millisecondsSinceEpoch,
          "senderId": sender.uid,
          "massageType": massageType.name,
        },
      );
      //set massage reply to null
      setMassageReply(null);
      emit(SendFileMessageSuccess());
    } else {
      //handle contact massage
      await _handleContactMassage(
        massage: massage,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        success: () {
          success();
        },
        failure: (String error) {
          failure(error);
        },
      );
    }
    //set reply to null
    setMassageReply(null);
  }

  FutureOr<void> _onSendFileMessageEvent(
      SendFileMessageEvent event, Emitter<ChatsState> emit) async {
    emit(SendFileMessageLoading());
    try {
      await sentFileMessage(
        sender: event.sender,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImage: event.receiverImage,
        groupId: event.groupId,
        file: event.file,
        context: event.context,
        massageType: event.massageType,
        success: () {
          emit(SendFileMessageSuccess());
        },
        failure: (String error) {
          emit(SendFileMessageError(message: error));
        },
      );
    } catch (e) {
      emit(SendFileMessageError(message: e.toString()));
    }
  }

  FutureOr<void> _onSelectImageEvent(
      SelectImageEvent event, Emitter<ChatsState> emit) {
    emit(SelectImageState(file: event.file));
  }

  FutureOr<void> _onSelectVideoFromGalleryEvent(
      SelectVideoFromGalleryEvent event, Emitter<ChatsState> emit) {
    emit(SelectVideoFromGalleryState(file: event.file));
  }

  //send reactions to massage
  Future<void> _sendReactionsToMassage({
    required String massageId,
    required String senderId,
    required String receiverId,
    required String reaction,
    required bool groupId,
    required void Function() success,
    required void Function(String message) failure,
  }) async {
    try {
      //save reaction as $senderId=$reaction
      final String reactionToAdd = "$senderId=$reaction";
      //check if group massage and send to group else send to contact
      if (groupId) {
        //handle group massage

        //get reactions of massage list from firestore
        final massageData = await FirebaseFirestore.instance
            .collection("groups")
            .doc(receiverId)
            .collection("messages")
            .doc(massageId)
            .get();
        //add the massage data to massage
        final massage = Massage.fromJson(massageData.data()!);
        //check if reactions list empty
        if (massage.reactions.isEmpty) {
          //add reaction to massage
          await FirebaseFirestore.instance
              .collection("groups")
              .doc(receiverId)
              .collection("messages")
              .doc(massageId)
              .update({
            "reactions": FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          //get UIDS list from reactions
          final List<String> UIDS =
              massage.reactions.map((e) => e.split("=")[0]).toList();
          //check if reaction already added
          if (UIDS.contains(senderId)) {
            //get index of reaction
            final int index = UIDS.indexOf(senderId);
            //replace reaction
            massage.reactions[index] = reactionToAdd;
          } else {
            //add reaction
            massage.reactions.add(reactionToAdd);
          }
          //update massage
          await FirebaseFirestore.instance
              .collection("groups")
              .doc(receiverId)
              .collection("messages")
              .doc(massageId)
              .update({"reactions": massage.reactions});
        }
      } else {
        //handle contact massage
        print("$senderId $receiverId $massageId");
        //get reactions from firestore
        DocumentSnapshot<Map<String, dynamic>> massageData =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(senderId)
                .collection("chats")
                .doc(receiverId)
                .collection("messages")
                .doc(massageId)
                .get();
        //add the massage data to massage
        final massage = Massage.fromJson(massageData.data()!);
        //check if reactions list empty
        if (massage.reactions.isEmpty) {
          //add reaction to massage
          await FirebaseFirestore.instance
              .collection("users")
              .doc(senderId)
              .collection("chats")
              .doc(receiverId)
              .collection("messages")
              .doc(massageId)
              .update({
            "reactions": FieldValue.arrayUnion([reactionToAdd])
          });
        } else {
          //get UIDS list from reactions
          final List<String> UIDS =
              massage.reactions.map((e) => e.split("=")[0]).toList();
          //check if reaction already added
          if (UIDS.contains(senderId)) {
            //get index of reaction
            final int index = UIDS.indexOf(senderId);
            //replace reaction
            massage.reactions[index] = reactionToAdd;
          } else {
            //add reaction
            massage.reactions.add(reactionToAdd);
          }
          //update massage to sender
          await FirebaseFirestore.instance
              .collection("users")
              .doc(senderId)
              .collection("chats")
              .doc(receiverId)
              .collection("messages")
              .doc(massageId)
              .update({"reactions": massage.reactions});
          //update massage to receiver
          await FirebaseFirestore.instance
              .collection("users")
              .doc(receiverId)
              .collection("chats")
              .doc(senderId)
              .collection("messages")
              .doc(massageId)
              .update({"reactions": massage.reactions});
        }
      }
      print("sent");
      success();
    } catch (e) {
      print("ddddddddddddddddddddddddddddddddd${e.toString()}");
      failure(e.toString());
    }
  }

  FutureOr<void> _onSelectReactionEven(
      SelectReactionEvent event, Emitter<ChatsState> emit) async {
    emit(SendReactionsToMassageLoading());
    await _sendReactionsToMassage(
      massageId: event.massageId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      reaction: event.reaction,
      groupId: event.groupId,
      success: () {
        emit(SendReactionsToMassageSuccess());
      },
      failure: (String message) {
        emit(SendReactionsToMassageError(message: message));
      },
    );
  }

  //get unread massages stream
  Stream<int> getUnreadMassagesStream({
    required String userId,
    required String receiverId,
    required bool isGroup,
  }) {
    if (isGroup) {
      return FirebaseFirestore.instance
          .collection("groups")
          .doc(receiverId)
          .collection("messages")
          .snapshots()
          .asyncMap((event) {
        int count = 0;
        for (var element in event.docs) {
          final massage = Massage.fromJson(element.data());
          if (!massage.isSeenBy.contains(userId)) {
            count++;
          }
        }
        return count;
      });
    } else {
      //handle contact massage
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("chats")
          .doc(receiverId)
          .collection("messages")
          .where("isSeen", isEqualTo: false)
          .where("senderId", isNotEqualTo: userId)
          .snapshots()
          .map((event) {
        return event.docs.length;
      });
    }
  }

  FutureOr<void> _onDeleteMassageEvent(
      DeleteMassageEvent event, Emitter<ChatsState> emit) async {
    await deleteMessage(
      currentUserId: event.currentUserId,
      contactUID: event.contactUID,
      messageId: event.messageId,
      messageType: event.messageType,
      isGroupChat: event.isGroupChat,
      deleteForEveryone: event.deleteForEveryone,
      success: (message) {
        emit(DeleteMassageSuccess(massage: message));
      },
      failure: (message) {
        emit(DeleteMassageError(message: message));
      },
      setLoading: (isLoading) {
        emit(DeleteMassageLoading());
      },
    );
  }

  //delete massage
  // delete message
  Future<void> deleteMessage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
    required bool isGroupChat,
    required bool deleteForEveryone,
    required void Function(String message) success,
    required void Function(String message) failure,
    required void Function(bool isLoading) setLoading,
  }) async {
    // set loading
    setLoading(true);
    try {
      // check if its group chat
      if (isGroupChat) {
        // handle group message
        await FirebaseFirestore.instance
            .collection("groups")
            .doc(contactUID)
            .collection("messages")
            .doc(messageId)
            .update({
          "isDeletedBy": FieldValue.arrayUnion([currentUserId])
        });
        // is is delete for everyone and message type is not text, we also dele the file from storage
        if (deleteForEveryone) {
          // get all group members uids and put them in deletedBy list
          final groupData = await FirebaseFirestore.instance
              .collection("groups")
              .doc(contactUID)
              .get();

          final List<String> groupMembers =
              List<String>.from(groupData.data()!["membersUIDS"]);

          // update the message as deleted for everyone
          await FirebaseFirestore.instance
              .collection("groups")
              .doc(contactUID)
              .collection("messages")
              .doc(messageId)
              .update({"isDeletedBy": FieldValue.arrayUnion(groupMembers)});

          if (messageType != MassageType.text.name) {
            // delete the file from storage
            await deleteFileFromStorage(
              currentUserId: currentUserId,
              contactUID: contactUID,
              messageId: messageId,
              messageType: messageType,
            );
          }
        }
        // set loading to false
        setLoading(false);
        success("Message deleted successfully");
      } else {
        // handle contact message
        // 1. update the current message as deleted
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId)
            .collection("chats")
            .doc(contactUID)
            .collection("messages")
            .doc(messageId)
            .update({
          "isDeletedBy": FieldValue.arrayUnion([currentUserId])
        });
        // 2. check if delete for everyone then return if false
        if (!deleteForEveryone) {
          // set loading to false
          setLoading(false);
          return;
        }

        // 3. update the contact message as deleted
        await FirebaseFirestore.instance
            .collection("users")
            .doc(contactUID)
            .collection("chats")
            .doc(currentUserId)
            .collection("messages")
            .doc(messageId)
            .update({
          "isDeletedBy": FieldValue.arrayUnion([currentUserId])
        });
        // 4. delete the file from storage
        if (messageType != MassageType.text.name) {
          await deleteFileFromStorage(
            currentUserId: currentUserId,
            contactUID: contactUID,
            messageId: messageId,
            messageType: messageType,
          );
        }
        // set loading to false
        setLoading(false);
        success("Message deleted successfully");
      }
    } catch (e) {
      // set loading to false
      setLoading(false);
      // return error
      failure(e.toString());
    }
  }

  Future<void> deleteFileFromStorage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
  }) async {
    final firebaseStorage = FirebaseStorage.instance;
    // delete the file from storage
    await firebaseStorage
        .ref('chatFiles/$messageType/$currentUserId/$contactUID/$messageId.jpg')
        .delete();
  }

  // stream the last message collection
  Stream<QuerySnapshot> getLastMessageStream({
    required String userId,
    required String groupId,
  }) {
    return groupId.isNotEmpty
        ? FirebaseFirestore.instance
            .collection("groups")
            .where("membersUIDS", arrayContains: userId)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("chats")
            .snapshots();
  }

  Future<String> saveImageToStorage(File file, reference) async {
    Reference ref = FirebaseStorage.instance.ref(reference);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
