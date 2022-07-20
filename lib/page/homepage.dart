import 'dart:io';

import 'package:camera/camera.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:video_player/video_player.dart';

import '../main.dart';
import '../utils/constants.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

/// Returns a suitable camera icon for [direction].

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  // VideoPlayerController? videoController;

  XFile? videoFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onNewCameraSelected(cameras[0]);
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
    final previousCameraController = _cameraController;

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : currentResolutionPreset,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();
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
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SafeArea(
        child: WillPopScope(
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: DropdownButton<ResolutionPreset>(
                    dropdownColor: Colors.black87,
                    alignment: AlignmentDirectional.centerEnd,
                    underline: Container(),
                    value: currentResolutionPreset,
                    items: [
                      for (ResolutionPreset preset in resolutionPresets)
                        DropdownMenuItem(
                          child: Text(
                            preset.toString().split('.')[1].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                          value: preset,
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        currentResolutionPreset = value!;
                      });
                      onNewCameraSelected(_cameraController!.description);
                    },
                    hint: Text("Select item"),
                  ),
                )
              ],
              leading: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        if (isRearCameraSelected) {
                          setState(() {
                            currentFlashMode =
                                onFlashClick ? FlashMode.torch : FlashMode.off;
                          });

                          setState(() {
                            onFlashClick = !onFlashClick;
                          });

                          await _cameraController!
                              .setFlashMode(currentFlashMode!);
                        }
                      },
                      icon: Icon(
                        onFlashClick ? Icons.flash_off : Icons.flash_on,
                        size: 20,
                        color: onFlashClick ? Colors.white : Colors.yellow,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        onNewCameraSelected(
                          cameras[isRearCameraSelected ? 1 : 0],
                        );
                        setState(() {
                          isRearCameraSelected = !isRearCameraSelected;
                        });
                      },
                      icon: Icon(
                        Icons.change_circle_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Center(
              child: Listener(
                onPointerDown: (_) => _pointers++,
                onPointerUp: (_) => _pointers--,
                child: CameraPreview(
                  _cameraController!,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        onTapDown: (TapDownDetails details) =>
                            onViewFinderTap(details, constraints),
                        child: Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isRecordingInProgress
                                      ? Text(
                                          'Stop \n Session',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      : Text(
                                          'Start \n Session',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 8.0, left: 4),
                                    child: SpeedDial(
                                      overlayColor: Colors.transparent,
                                      backgroundColor: Colors.black,
                                      overlayOpacity: 0,
                                      buttonSize: Size(50, 50),
                                      openCloseDial: isDialOpen,
                                      shape: StadiumBorder(
                                          side: BorderSide(
                                              color: Colors.white, width: 4)),
                                      elevation: 1.5,
                                      child: Icon(
                                        Icons.circle,
                                        size: 50,
                                        color: Colors.red,
                                      ),

                                      // icon: Icons.share,
                                      children: [
                                        SpeedDialChild(
                                          child: Icon(Icons.play_arrow_sharp),
                                          onTap: () {
                                            onVideoRecordButtonPressed();
                                          },
                                        ),
                                        SpeedDialChild(
                                          child: Icon(isRecordingInProgress
                                              ? Icons.pause_sharp
                                              : Icons.pause_sharp),
                                          onTap: () async {},
                                        ),
                                        SpeedDialChild(
                                          child: Icon(Icons.stop_sharp),
                                          onTap: () {
                                            onStopButtonPressed();
                                            // if (videoFile == null) {
                                            //   return;
                                            // }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, 2),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 80, right: 25, top: 10),
                                  child: Divider(
                                    height: 126,
                                    thickness: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.translate(
                                offset: Offset(10, -70),
                                child: Text(
                                  'Add Last',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.translate(
                                offset: Offset(-15, -6),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomTimeButton(
                                          label: ':10',
                                          onPressed: () {
                                            List<String> tenSec = [];
                                            tenSec.add(videoFile!.path);
                                            print('asdfasdf: $tenSec');
                                          }),
                                      CustomTimeButton(
                                          label: ':30', onPressed: () {}),
                                      CustomTimeButton(
                                          label: '1:00', onPressed: () {}),
                                      CustomTimeButton(
                                          label: '3:00', onPressed: () {}),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            if (isDialOpen.value) {
              isDialOpen.value = false;
              return false;
            } else {
              return true;
            }
          },
        ),
      );
    }
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

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
      setState(() => isRecordingInProgress = true);
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

// stop recording
  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      setState(() => isRecordingInProgress = false);

      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) async {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        await GallerySaver.saveVideo(file.path);
      }
    });
  }

  // pause

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  //save

  Future<bool> saveFile(String filepath, String fileName) async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        if (await _requestPermisson(Permission.storage) &&
            await _requestPermisson(Permission.accessMediaLocation) &&
            // manage external storage needed for android 11/R
            await _requestPermisson(Permission.manageExternalStorage)) {
          directory = await getExternalStorageDirectory();
          print(directory!.path);
          String newPath = '';

          // /storage/emulated/0/Android/data/com.example.recorder_video/files

          List<String> folders = directory.path.split('/');

          for (int i = 1; i < folders.length; i++) {
            String folder = folders[i];
            if (folder != 'Android') {
              newPath += '/' + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/RecorderAppS";
          directory = Directory(newPath);
          print(directory.path);
        } else {
          return false;
        }
      } else {
        if (await _requestPermisson(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        // var dio = Dio();
        File savedFile = File(directory.path + '/$fileName');
        print(savedFile.path);
        // await dio.download(
        //   filepath,
        //   savedFile.path,
        //   onReceiveProgress: (count, total) {
        //     setState(() {
        //       savingProgress = count / total;
        //     });
        //   },
        // );
        // Uint8List bytes = await savedFile.readAsBytes();
        // await savedFile.writeAsBytes(bytes);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> _requestPermisson(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // save file

  downloadFile() async {
    File file = File(videoFile!.path);
    print(file);
    // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    // _flutterFFmpeg
    //     .execute('-i ${videoFile!.name} -f null /dev/null')
    //     .then((value) {
    //   print('Got value ');
    // }).catchError((error) {
    //   print('Error');
    // });
    Directory appDocumentDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDocumentDir.path;
    String outputPath = "$rawDocumentPath/output.mp4";
    print('object: $outputPath');
    // setState(() {
    //   saveLoading = true;
    // });
    // if (videoFile == null) {
    //   return;
    // }
    // await GallerySaver.saveVideo(videoFile!.path);

    // setState(() {
    //   saveLoading = false;
    // });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Recorder'),
          content: Text('Do you want to Trim Recorded Video'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: videoFile == null
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : () async {
                      await GallerySaver.saveVideo(videoFile!.path);
                      File(videoFile!.path).deleteSync();

                      Navigator.of(context).pop();
                    },
            ),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: videoFile == null
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : () {
                      print('object');
                    },
            ),
          ],
        );
      },
    );
  }
}
