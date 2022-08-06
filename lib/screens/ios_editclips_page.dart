import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/clip_controller.dart';
import 'editor/finale.dart';

class IOSEditClipPage extends StatelessWidget {
  const IOSEditClipPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 2),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog(context);
                        },
                        child: Icon(
                          CupertinoIcons.back,
                          color: CupertinoColors.white,
                        ),
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
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                        clipCon.selectedItem.clear();
                        clipCon.isMultiSelectionValue(false);
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
                        'Delete Clips',
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
            // Visibility(
            //     //visible: selectedItem.isNotEmpty,
            //     child: IconButton(
            //   icon: Icon(Icons.delete),
            //   onPressed: () {
            //     // selectedItem.forEach((nature) {
            //     //   natureList.remove(nature);
            //     // });
            //     // selectedItem.clear();
            //     // setState(() {});
            //   },
            // )),
            clipCon.timmedSessionList.isNotEmpty
                ? Visibility(
                    visible: clipCon.isMultiSelectionEnabled == false,
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
                        clipCon.mergeRequest();
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
        // trailing: clipCon.timmedSessionList.isNotEmpty
        // ? CupertinoButton(
        //     padding: EdgeInsets.only(right: 15),
        //     child: Text('Merge'),
        //     onPressed: () {
        //       clipCon.mergeRequest();
        //     },
        //   )
        //     : null,
      ),
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
              onLongPress: () {
                clipCon.isMultiSelectionValue(true);
                clipCon.doMultiSelection(clipCon.clippedSessionList[index]);
              },
              onTap: clipCon.isMultiSelectionEnabled
                  ? () {
                      clipCon
                          .doMultiSelection(clipCon.clippedSessionList[index]);
                    }
                  : () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => FinalVideoEditor(
                                index: index,
                                file: File(clipCon
                                    .clippedSessionList[index].videoPath)),
                          ));
                      //  clipCon.rotateVideo(clipCon.clippedSessionList[index].videoPath);
                    },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Rotation(
                            videoFileModel: clipCon.clippedSessionList[index])),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, top: 5.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Visibility(
                        visible: clipCon.isMultiSelectionEnabled &&
                            clipCon.selectedItem.isNotEmpty,
                        child: Icon(
                          clipCon.selectedItem
                                  .contains(clipCon.clippedSessionList[index])
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
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Clear Recorded Session'),
          content: Text('Do you want to clear Recorded Session and go back'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                Provider.of<ClipController>(context, listen: false)
                    .onFinished();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class Rotation extends StatelessWidget {
  const Rotation({Key? key, required this.videoFileModel}) : super(key: key);
  final VideoFileModel videoFileModel;

  @override
  Widget build(BuildContext context) {
    var clupCon = Provider.of<ClipController>(context);
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return RotatedBox(
      quarterTurns: clupCon.isLandscapeRecordingClicked ? 2 : 0,
      child: Image.memory(
        videoFileModel.thumbnailFile,
        filterQuality: FilterQuality.high,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        fit: BoxFit.cover,
      ),
    );
  }
}

// class VideoPlayerScreen extends StatefulWidget {
//   VideoPlayerScreen({Key? key, required this.filePath}) : super(key: key);
//   final String filePath;

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;

//   @override
//   void initState() {
//     // Create and store the VideoPlayerController. The VideoPlayerController
//     // offers several different constructors to play videos from assets, files,
//     // or the internet.
//     _controller = VideoPlayerController.file(
//       File(widget.filePath),
//     );

//     // Initialize the controller and store the Future for later use.
//     _initializeVideoPlayerFuture = _controller.initialize();

//     // Use the controller to loop the video.
//     _controller.setLooping(true);

//     super.initState();
//   }

//   @override
//   void dispose() {
//     // Ensure disposing of the VideoPlayerController to free up resources.
//     _controller.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var clipCon = Provider.of<ClipController>(context);
//     return FutureBuilder(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           // If the VideoPlayerController has finished initialization, use
//           // the data it provides to limit the aspect ratio of the video.
//           return GestureDetector(
//             onLongPress: () {
//               clipCon.isMultiSelectionValue(true);
//               clipCon.doMultiSelection(widget.filePath);
//             },
//             onTap: clipCon.isMultiSelectionEnabled
//                 ? () {
//                     clipCon.doMultiSelection(widget.filePath);
//                   }
//                 : () {
//                     // Navigator.push(
//                     //   context,
//                     //   CupertinoPageRoute(
//                     //     builder: (context) => VideoEditorDemo(
//                     //       file: File(widget.filePath),
//                     //     ),
//                     //   ),
//                     // );
//                   },
//             child: FittedBox(
//               fit: BoxFit.cover,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: 500,
//                   minHeight: 200,
//                   maxWidth: 500,
//                   minWidth: 200,
//                 ),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                   width: MediaQuery.of(context).size.width,
//                   height: 350,
//                   child: Stack(
//                     children: [
//                       VideoPlayer(_controller),
//                       Align(
//                         alignment: Alignment.center,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 15,
//                           child: Icon(
//                             Icons.play_arrow,
//                             color: Colors.black,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 5, right: 5),
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: Visibility(
//                             visible: clipCon.isMultiSelectionEnabled &&
//                                 clipCon.selectedItem.isNotEmpty,
//                             child: Icon(
//                               clipCon.selectedItem.contains(widget.filePath)
//                                   ? Icons.check_circle
//                                   : Icons.radio_button_unchecked,
//                               size: 25,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // child: ClipRRect(
//             //   borderRadius: BorderRadius.circular(10),
//             //   child: AspectRatio(
//             //     aspectRatio: 21 / 10,
//             //     // Use the VideoPlayer widget to display the video.
//             //     child: Stack(
//             //       children: [
//             //         VideoPlayer(_controller),
//             // Align(
//             //   alignment: Alignment.center,
//             //   child: CircleAvatar(
//             //     backgroundColor: Colors.white,
//             //     radius: 15,
//             //     child: Icon(
//             //       Icons.play_arrow,
//             //       color: Colors.black,
//             //       size: 20,
//             //     ),
//             //   ),
//             // ),
//             //         Padding(
//             //           padding: const EdgeInsets.only(left: 5, right: 5),
//             //           child: Align(
//             //             alignment: Alignment.centerRight,
//             // child: Visibility(
//             //   visible: clipCon.isMultiSelectionEnabled &&
//             //       clipCon.selectedItem.isNotEmpty,
//             //   child: Icon(
//             //     clipCon.selectedItem.contains(widget.filePath)
//             //         ? Icons.check_circle
//             //         : Icons.radio_button_unchecked,
//             //     size: 25,
//             //     color: Colors.white,
//             //   ),
//             // ),
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//           );
//         } else {
//           // If the VideoPlayerController is still initializing, show a
//           // loading spinner.
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

// class CustomSliders extends StatefulWidget {
//   const CustomSliders({Key? key, required this.customSlidersPath})
//       : super(key: key);
//   final String customSlidersPath;

//   @override
//   State<CustomSliders> createState() => _CustomSlidersState();
// }

// class _CustomSlidersState extends State<CustomSliders> {
//   final Trimmer _trimmer = Trimmer();
//   Timer? _timer;

//   @override
//   void initState() {
//     _loadVideo();
//     super.initState();
//     EasyLoading.addStatusCallback((status) {
//       print('EasyLoading Status $status');
//       if (status == EasyLoadingStatus.dismiss) {
//         _timer?.cancel();
//       }
//     });
//   }

//   Future<void> _loadVideo() async {
//     await _trimmer.loadVideo(videoFile: File(widget.customSlidersPath));
//   }

//   void dispose() {
//     _trimmer.dispose();
//     super.dispose();
//   }

//   // Future<void> _remove(BuildContext context, String path) async {
//   //   return showDialog<void>(
//   //     context: context,
//   //     barrierDismissible: true, // user must tap button!
//   //     builder: (BuildContext context) {
//   //       return CupertinoAlertDialog(
//   //         title: const Text('Recorder'),
//   //         content: Text('Do you want to Save Recorded Video'),
//   //         actions: <Widget>[
//   //           CupertinoDialogAction(
//   //               child: const Text('No'),
//   //               onPressed: () {
//   //                 Navigator.pop(context);
//   //               }),
//   //           CupertinoDialogAction(
//   //             child: const Text('Yes'),
//   //             onPressed: () async {
//   //               Provider.of<ClipController>(context, listen: false)
//   //                   .remove(path);
//   //               Navigator.pop(context);
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var clipCon = Provider.of<ClipController>(context);
//     return GestureDetector(
//       onLongPress: () {
//         clipCon.isMultiSelectionValue(true);
//         clipCon.doMultiSelection(widget.customSlidersPath);
//       },
//       onTap: clipCon.isMultiSelectionEnabled
//           ? () {
//               clipCon.doMultiSelection(widget.customSlidersPath);
//             }
//           : () {
//               Navigator.push(
//                 context,
//                 CupertinoPageRoute(
//                   builder: (context) => VideoEditor(
//                     file: File(widget.customSlidersPath),
//                   ),
//                 ),
//               );
//             },
//       child: Stack(
//         children: [
//           TrimEditor(
//             trimmer: _trimmer,
//             circlePaintColor: Colors.transparent,
//             borderPaintColor: Colors.transparent,
//             viewerHeight: 50.0,
//             showDuration: false,
//             thumbnailQuality: 25,
//             viewerWidth: MediaQuery.of(context).size.width,
//             maxVideoLength: const Duration(hours: 10),
//             onChangeStart: (value) {},
//             onChangeEnd: (value) {},
//             onChangePlaybackState: (value) {},
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 5, top: 10, right: 5),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Visibility(
//                 visible: clipCon.isMultiSelectionEnabled &&
//                     clipCon.selectedItem.isNotEmpty,
//                 child: Icon(
//                   clipCon.selectedItem.contains(widget.customSlidersPath)
//                       ? Icons.check_circle
//                       : Icons.radio_button_unchecked,
//                   size: 25,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
