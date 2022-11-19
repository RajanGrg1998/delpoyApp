import 'dart:io';

import 'package:clip_test/controller/clip_controller.dart';
import 'package:clip_test/helpers/editor/video_editor.dart';
import 'package:clip_test/model/videofile.dart';
import 'package:clip_test/screens/demoeditpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:provider/provider.dart';

class FinalVideoEditor extends StatefulWidget {
  const FinalVideoEditor({
    Key? key,
    required this.videoFileModel,
  }) : super(key: key);

  final VideoFileModel videoFileModel;

  @override
  State<FinalVideoEditor> createState() => _FinalVideoEditorState();
}

enum MenuValues {
  trim,
  delete,
}

class _FinalVideoEditorState extends State<FinalVideoEditor> {
  final double height = 60;

  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(
      File(widget.videoFileModel.videoPath),
      maxDuration: const Duration(minutes: 5),
    )..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo(ClipController clipController) async {
    EasyLoading.show(status: 'Video Trimming...');
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      // isFiltersEnabled: false,

      // preset: VideoExportPreset.medium,
      customInstruction: "-vb 20M",
      // onProgress: (stats, value) => _exportingProgress.value = value,

      onCompleted: (file) async {
        // _isExporting.value = false;
        // await GallerySaver.saveVideo(file.path);
        if (!mounted) return;
        // final uint8list = await VideoThumbnail.thumbnailData(
        //   video: file.path,
        //   imageFormat: ImageFormat.JPEG,
        //   quality: 100,
        // );
        // if (clipController.isRotationVideoEditorPressed && uint8list != null) {
        //   clipController.addTrimmedSession(file.path);
        //   clipController.clippedSessionList.removeAt(widget.index);
        //   clipController.clippedSessionList.insert(
        //       widget.index,
        //       VideoFileModel(
        //         videoPath: widget.file.path,
        //         // thumbnailFile: uint8list,
        //       ));
        //   clipController.changeRotationButtonPressed(false);
        // } else {
        clipController.addTrimmedSession(file.path);
        // await GallerySaver.saveVideo(file.path);
        // }

        EasyLoading.showSuccess('Video Trimmed!');

        EasyLoading.dismiss();

        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.black,
          padding: EdgeInsetsDirectional.only(start: 5, end: 16),
          middle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 5),
                onPressed: () {
                  _controller.rotate90Degrees(RotateDirection.left);
                  // clipCon.changeRotationButtonPressed(true);
                },
                child: const Icon(
                  Icons.rotate_left,
                  color: Colors.white,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 5),
                onPressed: () {
                  _controller.rotate90Degrees(RotateDirection.right);
                  // clipCon.changeRotationButtonPressed(true);
                },
                child: const Icon(
                  Icons.rotate_right,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          trailing: Transform.translate(
            offset: Offset(10, 0),
            child: PopupMenuButton<MenuValues>(
              iconSize: 30,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Trim'),
                  value: MenuValues.trim,
                ),
                PopupMenuItem(
                  child: Text('Delete'),
                  value: MenuValues.delete,
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case MenuValues.trim:
                    _exportVideo(clipCon);
                    break;
                  case MenuValues.delete:
                    Provider.of<ClipController>(context, listen: false)
                        .deleteVideoClipped(widget.videoFileModel);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DemoIOSEditClipPage(),
                        ),
                        (route) => false);
                    break;
                }
              },
            ),
          ),
          //  CupertinoButton(
          //   padding: EdgeInsets.only(left: 20),
          //   child: Text(
          //     'Trim',
          //     style: TextStyle(
          //       fontSize: 15,
          //       color: Colors.white,
          //     ),
          //   ),
          //   onPressed: () {
          //     _exportVideo(clipCon);
          //   },
          // ),
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
      ),
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
