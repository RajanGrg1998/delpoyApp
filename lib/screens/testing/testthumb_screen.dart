import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoOSIOS extends StatefulWidget {
  const VideoOSIOS({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<VideoOSIOS> createState() => _VideoOSIOSState();
}

class _VideoOSIOSState extends State<VideoOSIOS> {
  late VideoPlayerController controller;

  void _playvideo() {
    controller = VideoPlayerController.file(File(widget.path))
      ..addListener(() => setState(() {}))
      ..setLooping(false)
      ..initialize().then((value) {
        controller.play();
        controller.setVolume(0);
        // Future.delayed(Duration(seconds: 2))
        //     .then((value) => controller.pause());

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    _playvideo();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: VideoPlayer(controller),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
