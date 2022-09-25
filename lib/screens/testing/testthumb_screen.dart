import 'dart:io';

import 'package:clip_test/screens/demoeditpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../controller/clip_controller.dart';
import '../editor/finale.dart';

class TestThumbScreen extends StatelessWidget {
  const TestThumbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        // backgroundColor: CupertinoColors.black,
        padding: EdgeInsetsDirectional.zero,
        leading:
            clipCon.isMultiSelectionEnabled || clipCon.selectedItem.isNotEmpty
                ? CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      clipCon.selectedItem.clear();
                      clipCon.isMultiSelectionValue(false);
                    },
                  )
                : GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.back,
                          color: CupertinoColors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Edit Clips',
                          style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onTap: () {
                      // _showMyDialog(context);
                    },
                  ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            clipCon.isMultiSelectionEnabled
                ? Visibility(
                    visible: clipCon.selectedItem.isNotEmpty,
                    child: CupertinoButton(
                      padding: EdgeInsets.only(right: 15),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        clipCon.removeClip();
                      },
                    ),
                  )
                : Container(),
            clipCon.isMultiSelectionEnabled
                ? Visibility(
                    visible: clipCon.selectedItem.isNotEmpty,
                    child: CupertinoButton(
                      padding: EdgeInsets.only(right: 15),
                      child: Text(
                        'Merge',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        clipCon.mergeSelectedClips();
                        //clipCon.selectedItem.clear();
                        clipCon.isMultiSelectionValue(false);
                      },
                    ),
                  )
                : Container(),
            !clipCon.isMultiSelectionEnabled &&
                    clipCon.timmedSessionList.isEmpty
                ? CupertinoButton(
                    padding: EdgeInsets.only(right: 15),
                    child: Text(
                      'Merge Clips',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      clipCon.isMultiSelectionValue(true);
                      clipCon
                          .doMultiSelection(clipCon.clippedSessionList.first);
                    },
                  )
                : SizedBox.shrink(),
            clipCon.timmedSessionList.isNotEmpty
                ? Visibility(
                    visible: clipCon.isMultiSelectionEnabled == false,
                    child: CupertinoButton(
                      padding: EdgeInsets.only(right: 15),
                      child: Text(
                        'Merge Edits',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        clipCon.mergeRequest();
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
      child: Column(
        children: [
          CupertinoButton(
            child: Text('data'),
            onPressed: () {
              print(clipCon.clippedSessionList.length);
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => MyWidget(),
                  ));
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: clipCon.clippedSessionList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    // onLongPress: () {
                    //   clipCon.isMultiSelectionValue(true);
                    //   clipCon.doMultiSelection(clipCon.clippedSessionList[index]);
                    // },
                    onTap: clipCon.isMultiSelectionEnabled
                        ? () {
                            clipCon.doMultiSelection(
                                clipCon.clippedSessionList[index]);
                          }
                        : () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => FinalVideoEditor(
                                      index: index,
                                      file: File(clipCon
                                          .clippedSessionList[index]
                                          .videoPath)),
                                ));
                            //  clipCon.rotateVideo(clipCon.clippedSessionList[index].videoPath);
                          },
                    // child: Stack(
                    //   children: [
                    //     // DemoDDD(path: clipCon.clippedSessionList[index].videoPath),
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(5),
                    //       ),
                    //       child: ClipRRect(
                    //           borderRadius: BorderRadius.circular(5),
                    //           child: Rotation(
                    //               videoFileModel: clipCon.clippedSessionList[index])),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                    //       child: Align(
                    //         alignment: Alignment.topRight,
                    //         child: Visibility(
                    //           visible: clipCon.isMultiSelectionEnabled &&
                    //               clipCon.selectedItem.isNotEmpty,
                    //           child: Icon(
                    //             clipCon.selectedItem
                    //                     .contains(clipCon.clippedSessionList[index])
                    //                 ? Icons.check_circle
                    //                 : Icons.radio_button_unchecked,
                    //             size: 25,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: DemoDDD(
                                  path: clipCon
                                      .clippedSessionList[index].videoPath)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Visibility(
                              visible: clipCon.isMultiSelectionEnabled &&
                                  clipCon.selectedItem.isNotEmpty,
                              child: Icon(
                                clipCon.selectedItem.contains(
                                        clipCon.clippedSessionList[index])
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: clipCon.clippedSessionList.length,
        itemBuilder: (context, index) {
          return VideoThumbnail(
              file: File(clipCon.clippedSessionList[index].videoPath));
        },
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({Key? key, required this.file}) : super(key: key);
  final File file;
  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController controller;

  @override
  void initState() {
    controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return Container(
        width: 50.0,
        height: 56.0,
        child: VideoPlayer(controller),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
