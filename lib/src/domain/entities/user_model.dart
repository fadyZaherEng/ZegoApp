import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  String uid;
  String name;
  String email;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isOnline;
  List<dynamic> friendsUIds;
  List<dynamic> friendsRequestsUIds;
  List<dynamic> sendFriendRequestsUIds;

  UserModel({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.image = '',
    this.token = '',
    this.aboutMe = '',
    this.lastSeen = '',
    this.createdAt = '',
    this.isOnline = false,
    this.friendsUIds = const [],
    this.friendsRequestsUIds = const [],
    this.sendFriendRequestsUIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']??'',
      name: json['name']??'',
      email: json['email']??'',
      image: json['image']??'',
      token: json['token']??'',
      aboutMe: json['aboutMe']??'',
      lastSeen: json['lastSeen']??'',
      createdAt: json['createdAt']??'',
      isOnline: json['isOnline'] ?? false,
      friendsUIds: json['friendsUIds']??[],
      friendsRequestsUIds: json['friendsRequestsUIds']??[],
      sendFriendRequestsUIds: json['sendFriendRequestsUIds']??[],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'image': image,
        'token': token,
        'aboutMe': aboutMe,
        'lastSeen': lastSeen,
        'createdAt': createdAt,
        'isOnline': isOnline,
        'friendsUIds': friendsUIds,
        'friendsRequestsUIds': friendsRequestsUIds,
        'sendFriendRequestsUIds': sendFriendRequestsUIds,
      };

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        image,
        token,
        aboutMe,
        lastSeen,
        createdAt,
        isOnline,
        friendsUIds,
        friendsRequestsUIds,
        sendFriendRequestsUIds,
      ];

//copy with
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? image,
    String? token,
    String? aboutMe,
    String? lastSeen,
    String? createdAt,
    bool? isOnline,
    List<String>? friendsUIds,
    List<String>? friendsRequestsUIds,
    List<String>? sentFriendsRequestsUIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      token: token ?? this.token,
      aboutMe: aboutMe ?? this.aboutMe,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      friendsUIds: friendsUIds ?? this.friendsUIds,
      friendsRequestsUIds: friendsRequestsUIds ?? this.friendsRequestsUIds,
      sendFriendRequestsUIds:
          sentFriendsRequestsUIds ?? this.sendFriendRequestsUIds,
    );
  }

  //deep copy equatable deep clone
  UserModel deepClone() {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      image: image,
      token: token,
      aboutMe: aboutMe,
      lastSeen: lastSeen,
      createdAt: createdAt,
      isOnline: isOnline,
      friendsUIds: friendsUIds,
      friendsRequestsUIds: friendsRequestsUIds,
      sendFriendRequestsUIds: sendFriendRequestsUIds,
    );
  }
}
