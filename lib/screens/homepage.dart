import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clip_test/screens/demoeditpage.dart';
import 'package:clip_test/screens/ios_editclips_page.dart';
import 'package:clip_test/screens/testing/testthumb_screen.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:video_player/video_player.dart';

import '../../main.dart';
import '../controller/clip_controller.dart';
import '../controller/lastclip_controller.dart';
import '../utils/constant.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

/// Returns a suitable camera icon for [direction].

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  VideoPlayerController? videoController;

  String stopTimeDisplay = "00:00:00";
  var swatch = Stopwatch();

  var extend = false;
  var rmicons = false;

  bool isRecordButtonVissible = true;

  bool isChangeColor = false;

  XFile? imageFile;
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    onNewCameraSelected(cameras[0]);
    // WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  void resetCameraValues() async {
    currentZoomLevel = 1.0;
    currentExposureOffset = 0.0;
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    // if (_cameraController != null) {
    //   await _cameraController!.dispose();
    // }

    // final previousCameraController = _cameraController;

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.veryHigh,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // await previousCameraController?.dispose();
    resetCameraValues();

    if (mounted) {
      setState(() {
        _cameraController = cameraController;
      });
    }
    // _cameraController = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await cameraController.lockCaptureOrientation();
      await cameraController.prepareForVideoRecording();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController
                    .getMinExposureOffset()
                    .then((double value) => minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => minAvailableZoom = value),
      ]);
      currentFlashMode = _cameraController!.value.flashMode;
      setState(() => isLoading = false);
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.black,
          padding: EdgeInsetsDirectional.only(start: 5, end: 16),
          middle: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: isChangeColor == false
                      ? Colors.transparent
                      : Colors.red[400],
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                '$stopTimeDisplay',
                style: TextStyle(fontSize: 14, color: CupertinoColors.white),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          trailing: Text(
            '1080p',
            style: TextStyle(fontSize: 14, color: CupertinoColors.white),
          ),
          leading: CupertinoButton(
            onPressed: isRecordingInProgress
                ? () {
                    print('not available while recording');
                  }
                : () {
                    onNewCameraSelected(
                      cameras[isRearCameraSelected ? 1 : 0],
                    );
                    setState(() {
                      isRearCameraSelected = !isRearCameraSelected;
                    });
                  },
            child: Icon(
              CupertinoIcons.camera_rotate,
              size: 20,
              color: CupertinoColors.white,
            ),
          ),
        ),
        backgroundColor: CupertinoColors.black,
        child: Stack(
          children: [
            Platform.isIOS
                ? Center(
                    child: cameraPreview(),
                  )
                : cameraPreview(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isRecordButtonVissible
                      ? Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12.0, top: 8.0, left: 4),
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: RawMaterialButton(
                              onPressed: () async {
                                setState(() {
                                  isRecordButtonVissible = true;
                                });
                                resetWatch();
                                XFile? rawVideo = await stopVideoRecording();
                                File videoFile = File(rawVideo!.path);
                                int currentUnix =
                                    DateTime.now().millisecondsSinceEpoch;

                                final directory =
                                    await getApplicationDocumentsDirectory();

                                String fileFormat =
                                    videoFile.path.split('.').last;

                                _videoFile = await videoFile.copy(
                                  '${directory.path}/$currentUnix.$fileFormat',
                                );
                                print(_videoFile!.path);
                                setState(() {
                                  isChangeColor = false;
                                });
                                resetWatch();
                                if (_videoFile == null) {
                                  return;
                                }
                                // clipCon
                                //     .addFullSession(_videoFile!);

                                // print(
                                //     'session: ${clipCon.fullSessionList}');
                                if (clipCon.clippedSessionList.isEmpty) {
                                  return _showMyDialog(
                                      context, _videoFile!.path);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestThumbScreen(),
                                  ),
                                );
                              },
                              elevation: 2.0,
                              fillColor: Colors.white,
                              child: Icon(
                                Icons.stop,
                                size: 25.0,
                                color: Colors.red,
                              ),
                              shape: CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),

                  // _cameraController!.value.isRecordingVideo!
                  //     ? !_cameraController!.value.isRecordingPaused
                  !isRecordButtonVissible
                      ? !_cameraController!.value.isRecordingPaused
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12.0, top: 8.0, left: 4),
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    await pauseVideoRecording();
                                    showInSnackBar('Session Resume');
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  child: Icon(
                                    Icons.pause,
                                    size: 28.0,
                                    color: Colors.red,
                                  ),
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12.0, top: 8.0, left: 4),
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    await resumeVideoRecording();
                                    showInSnackBar('Session Resume');
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 28.0,
                                    color: Colors.red,
                                  ),
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            )
                      : SizedBox.shrink(),

                  isRecordButtonVissible
                      ? Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12.0, top: 8.0, left: 4),
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: RawMaterialButton(
                              onPressed: () async {
                                await startVideoRecording();
                                setState(() {
                                  isRecordButtonVissible = false;
                                });
                              },
                              elevation: 2.0,
                              fillColor: Colors.white,
                              child: Icon(
                                Icons.circle,
                                size: 20.0,
                                color: Colors.red,
                              ),
                              shape: CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(25, -70),
                child: Text(
                  'Save Last',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 80, right: 25, bottom: 5),
                child: Divider(
                  height: 126,
                  thickness: 2,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTimeButton(
                      label: ':10',
                      onPressed: () async {
                        if (isRecordingInProgress) {
                          // XFile? rawVideo = await stopVideoRecording();
                          XFile? rawVideo = await stopVideoRecording();
                          EasyLoading.show(status: 'Video Cliping...');
                          File videoFile = File(rawVideo!.path);
                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();

                          String fileFormat = videoFile.path.split('.').last;

                          _videoFile = await videoFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );
                          print(_videoFile!.path);
                          VideoPlayerController controller =
                              VideoPlayerController.file(
                                  File(_videoFile!.path));
                          await controller.initialize();
                          double duration =
                              controller.value.duration.inSeconds.toDouble();
                          double last10Sec = (duration - 10.0);
                          LastClipController().saveLastClipVideo(
                              startValue: last10Sec,
                              endValue: duration,
                              onSave: (outcome) async {
                                clipCon.clipedLastSecond(outcome);
                                //await GallerySaver.saveVideo(outcome);
                                EasyLoading.showSuccess('Video Clipped!');
                              },
                              videoFile: File(_videoFile!.path));
                          await controller.dispose();
                          EasyLoading.dismiss();
                          await startVideoRecording();
                        } else {
                          print('asd');
                        }
                      },
                    ),
                    CustomTimeButton(
                      label: ':30',
                      onPressed: () async {
                        if (isRecordingInProgress) {
                          XFile? rawVideo = await stopVideoRecording();
                          File videoFile = File(rawVideo!.path);
                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();

                          String fileFormat = videoFile.path.split('.').last;

                          _videoFile = await videoFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );
                          print(_videoFile!.path);
                          VideoPlayerController controller =
                              VideoPlayerController.file(
                                  File(_videoFile!.path));
                          await controller.initialize();
                          double duration =
                              controller.value.duration.inSeconds.toDouble();
                          double last10Sec = (duration - 30.0);
                          LastClipController().saveLastClipVideo(
                              startValue: last10Sec,
                              endValue: duration,
                              onSave: (outcome) async {
                                clipCon.clipedLastSecond(outcome);
                                //await GallerySaver.saveVideo(outcome);
                              },
                              videoFile: File(_videoFile!.path));
                          await controller.dispose();
                          await startVideoRecording();
                        } else {
                          print('asd');
                        }
                      },
                    ),
                    CustomTimeButton(
                      label: '1:00',
                      onPressed: () async {
                        if (isRecordingInProgress) {
                          XFile? rawVideo = await stopVideoRecording();
                          File videoFile = File(rawVideo!.path);
                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();

                          String fileFormat = videoFile.path.split('.').last;

                          _videoFile = await videoFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );
                          print(_videoFile!.path);
                          VideoPlayerController controller =
                              VideoPlayerController.file(
                                  File(_videoFile!.path));
                          await controller.initialize();
                          double duration =
                              controller.value.duration.inSeconds.toDouble();
                          double last10Sec = (duration - 60.0);
                          LastClipController().saveLastClipVideo(
                              startValue: last10Sec,
                              endValue: duration,
                              onSave: (outcome) async {
                                clipCon.clipedLastSecond(outcome);
                                //await GallerySaver.saveVideo(outcome);
                              },
                              videoFile: File(_videoFile!.path));
                          await controller.dispose();
                          await startVideoRecording();
                        } else {
                          print('asd');
                        }
                      },
                    ),
                    CustomTimeButton(
                      label: '3:00',
                      onPressed: () async {
                        if (isRecordingInProgress) {
                          XFile? rawVideo = await stopVideoRecording();
                          File videoFile = File(rawVideo!.path);

                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();

                          String fileFormat = videoFile.path.split('.').last;

                          _videoFile = await videoFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );
                          print(_videoFile!.path);
                          VideoPlayerController controller =
                              VideoPlayerController.file(
                                  File(_videoFile!.path));
                          await controller.initialize();
                          double duration =
                              controller.value.duration.inSeconds.toDouble();
                          double last10Sec = (duration - 180.0);
                          LastClipController().saveLastClipVideo(
                              startValue: last10Sec,
                              endValue: duration,
                              onSave: (outcome) async {
                                clipCon.clipedLastSecond(outcome);
                                //await GallerySaver.saveVideo(outcome);
                              },
                              videoFile: File(_videoFile!.path));
                          await controller.dispose();
                          await startVideoRecording();
                        } else {
                          print('asd');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  CameraPreview cameraPreview() {
    return CameraPreview(
      _cameraController!,
      child: Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          },
        ),
      ),
    );
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    print('Error: ${e.code}\n${e.description}');
  }

  // focus
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController? cameraController = _cameraController;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController!.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void startTimer() {
    Timer(dur, keepRunning);
  }

  void keepRunning() {
    if (swatch.isRunning) {
      startTimer();
    }
    setState(() {
      stopTimeDisplay = swatch.elapsed.inHours.toString().padLeft(2, '0') +
          ':' +
          (swatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
          ':' +
          (swatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
    });
  }

  void resetWatch() {
    setState(() {
      startPressed = true;
      resetPressed = true;
    });
    swatch.stop();
    swatch.reset();
    stopTimeDisplay = "00:00:00";
  }

  void startWatch() {
    setState(() {
      stopPressed = false;
      startPressed = false;
    });
    swatch.start();
    startTimer();
  }

  void pasueWatch() {
    setState(() {
      stopPressed = true;
      resetPressed = false;
    });
    swatch.stop();
  }

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale =
        (_baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

    await _cameraController!.setZoomLevel(_currentScale);
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Future<void> startVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (_cameraController!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      startWatch();
      setState(() {
        isRecordingInProgress = true;
        print(isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> _showMyDialog(BuildContext context, String path) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Recorder'),
          content: Text('Do you want to Save Recorded Video'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                EasyLoading.show(status: 'Session Saving...');
                await GallerySaver.saveVideo(path);
                showInSnackBar('Recording saved to gallery');
                EasyLoading.showSuccess('Session saved to Gallery');
                EasyLoading.dismiss();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pauseVideoRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await _cameraController!.pauseVideoRecording();
      pasueWatch();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await _cameraController!.resumeVideoRecording();
      startWatch();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }
}
