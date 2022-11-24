import 'dart:async';
import 'dart:io';
import 'package:clip_test/screens/demo/demo_home.dart';
import 'package:clip_test/screens/testing/testthumb_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/clip_controller.dart';
import '../controller/notification_controller.dart';
import '../model/videofile.dart';
import 'editor/finale.dart';

class DemoIOSEditClipPage extends StatefulWidget {
  const DemoIOSEditClipPage({Key? key}) : super(key: key);

  @override
  State<DemoIOSEditClipPage> createState() => _DemoIOSEditClipPageState();
}

class _DemoIOSEditClipPageState extends State<DemoIOSEditClipPage> {
  @override
  void initState() {
    Provider.of<NotificationController>(context, listen: false).initialize();
    // TODO: implement initState
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    super.initState();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose\
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]);
  //   super.dispose();
  // }

  Future<void> _delteAllPopBox(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete'),
          content: Text('Do you want to delete all Clips?'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                // EasyLoading.show(status: 'Session Saving...');
                // // await GallerySaver.saveVideo(path);
                // //  showInSnackBar('Recording saved to gallery');
                // EasyLoading.showSuccess('Session saved to Gallery');
                final box = await Hive.openBox<VideoFileModel>('clipedvideo');
                await box.deleteAll(box.keys);

                // EasyLoading.dismiss();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var notificationController = Provider.of<NotificationController>(context);
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
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                      clipCon.changeLastSecondButtonPressed(false);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeDemoApp(),
                          ),
                          (route) => false);
                      // _showMyDialog(context);
                    },
                  ),
        // : Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       SizedBox(width: 2),
        //       GestureDetector(
        //         onTap: () {
        //           _showMyDialog(context);
        //         },
        //         child: Icon(
        //           CupertinoIcons.back,
        //           color: CupertinoColors.white,
        //         ),
        //       ),
        // SizedBox(width: 5),
        // Text(
        //   'Edit Clips',
        //   style: TextStyle(
        //       color: CupertinoColors.white,
        //       fontSize: 15,
        //       fontWeight: FontWeight.bold),
        // )
        //     ],
        //   ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: clipCon.selectedItem.isEmpty,
              child: CupertinoButton(
                padding: EdgeInsets.only(right: 15),
                child: Text(
                  'Delete All',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  _delteAllPopBox(context);
                },
              ),
            ),
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
                        clipCon.mergeSelectedClips(notificationController);
                        // Provider.of<NotificationController>(context,
                        //         listen: false)
                        //     .showNotication();
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
                    onPressed: () async {
                      final box =
                          await Hive.openBox<VideoFileModel>('clipedvideo');
                      final clipList =
                          box.values.toList().cast<VideoFileModel>();
                      clipCon.isMultiSelectionValue(true);
                      clipCon.doMultiSelection(clipList.first);
                    },
                  )
                : SizedBox.shrink(),
            clipCon.timmedSessionList.isNotEmpty
                ? Visibility(
                    visible: clipCon.isMultiSelectionEnabled == false,
                    child: CupertinoButton(
                      padding: EdgeInsets.only(right: 15),
                      child: Text(
                        'Merge Trims',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        clipCon.mergeRequest(notificationController);
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
      child: FutureBuilder(
          future: Hive.openBox<VideoFileModel>('clipedvideo'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ValueListenableBuilder(
                valueListenable:
                    Hive.box<VideoFileModel>('clipedvideo').listenable(),
                builder: (BuildContext context, Box box, Widget? child) {
                  final clippedVideos =
                      box.values.toList().cast<VideoFileModel>();
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    itemCount: clippedVideos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      final clipIndex = clippedVideos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: GestureDetector(
                          onLongPress: () {
                            _showMyDialog(context, clipIndex);
                          },
                          onTap: clipCon.isMultiSelectionEnabled
                              ? () {
                                  clipCon.multi2(clipIndex);
                                }
                              : () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => FinalVideoEditor(
                                        videoFileModel: clipIndex,
                                      ),
                                    ),
                                  );
                                  //  clipCon.rotateVideo(clipIndex.videoPath);
                                },
                          child: Stack(
                            children: [
                              VideoOSIOS(path: clipIndex.videoPath),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 5.0, top: 5.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Visibility(
                                    visible: clipCon.isMultiSelectionEnabled &&
                                        clipCon.selectedItem.isNotEmpty,
                                    child: Icon(
                                      clipCon.selectedItem.contains(clipIndex)
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
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.hasError.toString());
            } else
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
          }),
    );
  }
}

Future<void> _showMyDialog(
    BuildContext context, VideoFileModel videoFileModel) async {
  return showDialog<void>(
    context: context,
    // user must tap button!
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Delete Clip?'),
        content: Text('Do you want to delete this Cliped Video'),
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
                  .deleteVideoClipped(videoFileModel);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

// class Rotation extends StatelessWidget {
//   const Rotation({Key? key, required this.videoFileModel}) : super(key: key);
//   final VideoFileModel videoFileModel;

//   @override
//   Widget build(BuildContext context) {
//     var clupCon = Provider.of<ClipController>(context);
//     return RotatedBox(
//       quarterTurns: clupCon.isLandscapeRecordingClicked ? 2 : 0,
//       child: Image.memory(
//         videoFileModel.thumbnailFile,
//         filterQuality: FilterQuality.high,
//         width: double.infinity,
//         height: double.infinity,
//         alignment: Alignment.center,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
// }

// ksdkjhsadkj

class DemoDDD extends StatefulWidget {
  const DemoDDD({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<DemoDDD> createState() => _DemoDDDState();
}

class _DemoDDDState extends State<DemoDDD> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: VideoPlayer(_controller)),
          )
        : CircularProgressIndicator();
  }
}
