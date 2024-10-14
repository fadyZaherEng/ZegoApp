import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:zego/src/presentations/widgets/bottom_sheet_widget.dart';

class UploadMediaWidget extends StatefulWidget {
  final Function() onTapCamera;
  final Function() onTapGallery;
  final Function() onTapVideo;
  bool isShowVideo = false;

  UploadMediaWidget({
    Key? key,
    required this.onTapCamera,
    required this.onTapGallery,
    this.isShowVideo = false,
    required this.onTapVideo,
  }) : super(key: key);

  @override
  State<UploadMediaWidget> createState() => _UploadMediaWidgetState();
}

class _UploadMediaWidgetState extends State<UploadMediaWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomSheetWidget(
      height: 219,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: widget.onTapGallery,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 16),
                Text(
                  "Gallery",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 13, letterSpacing: -0.24, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 71,
          ),
          GestureDetector(
            onTap: widget.onTapCamera,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 16),
                Text(
                  "Camera",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 13, letterSpacing: -0.24, color: Colors.black),
                ),
              ],
            ),
          ),
          if (widget.isShowVideo)
            const SizedBox(
              width: 71,
            ),
          if (widget.isShowVideo) ...[
            GestureDetector(
              onTap: widget.onTapVideo,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 4),
                              color: Theme.of(context).cardColor,
                              blurRadius: 24,
                              blurStyle: BlurStyle.normal,
                              spreadRadius: 5),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.transparent,
                          width: 0,
                        ),
                      ),
                      child: Icon(
                        Icons.video_library,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      )),
                  const SizedBox(height: 16),
                  Text(
                    "Video",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 13,
                        letterSpacing: -0.24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
      titleLabel: "Upload Media",
    );
  }
}
