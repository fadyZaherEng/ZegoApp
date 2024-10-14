// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/domain/usecase/get_user_use_case.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatefulWidget {
  final String conferenceID;
  final String userID;

  const VideoConferencePage({
    super.key,
    required this.conferenceID,
    required this.userID,
  });

  @override
  State<StatefulWidget> createState() => VideoConferencePageState();
}

class VideoConferencePageState extends State<VideoConferencePage> {
  String localUserID = "";

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    localUserID = widget.userID;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
          appID: 332255309,
          /*input your AppID*/
          appSign:
              "695d51aa7bbe13d50a1d6a3225bbf1a7be887f32ed0af34ca67015227b5c47f5",
          /*input your AppSign*/
          userID: localUserID,
          userName: 'user_$localUserID',
          conferenceID: widget.conferenceID,
          config: ZegoUIKitPrebuiltVideoConferenceConfig()),
    );
  }
}
