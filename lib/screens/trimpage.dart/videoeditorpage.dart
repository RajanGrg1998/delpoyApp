import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:provider/provider.dart';

import '../../controller/clip_controller.dart';
import '../../helpers/editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final double height = 60;

  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    // _isExporting.value = true;
    EasyLoading.show(status: 'Video Trimming...');
    await _controller.exportVideo(
      isFiltersEnabled: false,
      customInstruction: '-vb 20M',
      onCompleted: (file) async {
        // _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          Provider.of<ClipController>(context, listen: false)
              .addTrimmedSession(file.path);
          EasyLoading.showSuccess('Video Trimmed!');

          EasyLoading.dismiss();
        } else {}
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
              child: Icon(
                Icons.rotate_left,
                color: Colors.white,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.right),
              child: Icon(
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
            onPressed: () {
              _exportVideo();
            }),
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
                            children: _trimSlider(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(
                      Duration(
                        seconds: start.toInt(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatter(
                      Duration(
                        seconds: end.toInt(),
                      ),
                    ),
                  ),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            // child: TrimTimeline(
            //     controller: _controller,
            //     margin: const EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
  }
}
