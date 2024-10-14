import 'package:flutter/material.dart';
import 'package:zego/src/presentations/widgets/upload_media_widget.dart';

Future showBottomSheetUploadMedia({
  required BuildContext context,
  required Function() onTapCamera,
  required Function() onTapVideo,
  required Function() onTapGallery,
  bool isVideo = false,
}) async {
  return await showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: UploadMediaWidget(
        onTapCamera: onTapCamera,
        onTapGallery: onTapGallery,
        onTapVideo: onTapVideo,
        isShowVideo: isVideo,
      ),
    ),
  );
}
