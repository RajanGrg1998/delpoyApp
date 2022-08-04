import 'dart:io';

import 'package:clip_app/controller/clip_controller.dart';
import 'package:clip_app/helpers/editor/video_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:provider/provider.dart';

class FinalVideoEditor extends StatefulWidget {
  const FinalVideoEditor({Key? key, required this.file}) : super(key: key);
  final File file;

  @override
  State<FinalVideoEditor> createState() => _FinalVideoEditorState();
}

class _FinalVideoEditorState extends State<FinalVideoEditor> {
  final double height = 60;

  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(
      widget.file,
      maxDuration: const Duration(minutes: 5),
    )..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    EasyLoading.show(status: 'Video Trimming...');
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
      // onProgress: (stats, value) => _exportingProgress.value = value,

      onCompleted: (file) async {
        // _isExporting.value = false;
        // await GallerySaver.saveVideo(file.path);
        if (!mounted) return;
        Provider.of<ClipController>(context, listen: false)
            .addTrimmedSession(file.path);
        EasyLoading.showSuccess('Video Trimmed!');

        EasyLoading.dismiss();

        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        padding: EdgeInsetsDirectional.only(start: 5, end: 16),
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.left),
              child: const Icon(
                Icons.rotate_left,
                color: Colors.white,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.right),
              child: const Icon(
                Icons.rotate_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
        trailing: CupertinoButton(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Trim',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            onPressed: _exportVideo),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      child: _controller.initialized
          ? SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Expanded(
                              child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Stack(alignment: Alignment.center, children: [
                                CropGridViewer(
                                  controller: _controller,
                                  showGrid: false,
                                ),
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) => OpacityTransition(
                                    visible: !_controller.isPlaying,
                                    child: GestureDetector(
                                      onTap: _controller.video.play,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              CoverViewer(controller: _controller)
                            ],
                          )),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _trimSlider()),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  List<Widget> _trimSlider() {
    return [
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          // child: TrimTimeline(
          //   controller: _controller,
          //   margin: const EdgeInsets.only(top: 10),
          // ),
        ),
      )
    ];
  }
}