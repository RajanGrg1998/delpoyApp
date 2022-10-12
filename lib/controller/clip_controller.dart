import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ClipController extends ChangeNotifier {



  //camera
  List<VideoFileModel> clippedSessionList = [];

  List<String> fullSessionList = [];

  List<String> timmedSessionList = [];

  List<VideoFileModel> selectedItem = [];
  bool isMultiSelectionEnabled = false;
  bool isRotationVideoEditorPressed = false;

  // File? videofile;

//to change camera recording view from landscape to potrait

  bool isLandscapeRecordingClicked = false;

  bool isPotraitRecordingClicked = false;

  bool isCameraLoadingIndicator = false;

  bool isLandscapeRecordingStartedLeft = false;
  bool isLandscapeRecordingStartedRight = false;
  bool isPotraitRecordingStarted = false;

  leftLadnscapeChnage(bool va) {
    isLandscapeRecordingStartedLeft = va;
    notifyListeners();
  }

  changeCameraLoadingIndicatodValue(bool value) {
    isCameraLoadingIndicator = value;
    notifyListeners();
    print('object: $isLandscapeRecordingClicked');
  }

  changeRotationButtonPressed(bool value) {
    isRotationVideoEditorPressed = value;
    notifyListeners();
  }

  //for change view from landscape to potrait
  changeIsLandscapeRecordingClickedValue(bool value) {
    isLandscapeRecordingClicked = value;
    notifyListeners();
    print('object: $isLandscapeRecordingClicked');
  }

  //for change view from potrait to landscape
  changeIsPotraitRecordingClickedValue(bool value) {
    isPotraitRecordingClicked = value;
    notifyListeners();
    print('object: $isLandscapeRecordingClicked');
  }

  //for clipped list session
  addFullSessiom(String filepath) async {
    fullSessionList.add(filepath);
    notifyListeners();
  }

  //for clipped list session
  clipedLastSecond(String filepath) async {
    // final uint8list = await VideoThumbnail.thumbnailData(
    //   timeMs: 100,
    //   video: filepath,
    //   imageFormat: ImageFormat.JPEG,
    //   quality: 100,
    // );
    // if (uint8list != null) {
    //   clippedSessionList
    //       .add(VideoFileModel(videoPath: filepath, thumbnailFile: uint8list));
    //   print('woooooo');
    // } else {
    //   print('object');
    // }
    clippedSessionList.add(VideoFileModel(
      videoPath: filepath,
    ));
    notifyListeners();
  }

  updateLastSecondClipped(String filepath) async {
    // final uint8list = await VideoThumbnail.thumbnailData(
    //   video: filepath,
    //   imageFormat: ImageFormat.JPEG,
    //   quality: 100,
    // );
    // if (uint8list != null) {
    //   clippedSessionList.add(VideoFileModel(
    //     videoPath: filepath,
    //     thumbnailFile: uint8list,
    //   ));
    //   print('woooooo');
    // } else {
    //   print('object');
    // }
    clippedSessionList.add(VideoFileModel(
      videoPath: filepath,
      // thumbnailFile: uint8list,
    ));
    notifyListeners();
  }

  //for adding trimmed session list
  addTrimmedSession(String filepath) {
    timmedSessionList.add(filepath);
    notifyListeners();
  }

  Future<void> mergeRequest() async {
    final appDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath = '$rawDocumentPath/output.mp4';

    List<String> mergedList = [];
    // for (int i = 0; i < timmedSessionList.length; i++) {
    //   mergedList.add('-i ${timmedSessionList[i]}');
    // }
    // mergedList.add('-filter_complex');
    // mergedList.add('"');
    // for (int i = 0; i < timmedSessionList.length; i++) {
    //   mergedList.add('[$i:v] [$i:a]');
    // }
    // mergedList.add(
    //     'concat=n=${timmedSessionList.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]"');
    // String result = mergedList.join(' ');
    // String commandToExecute = '$result -y $outputPath';
    // print(commandToExecute);
    for (int i = 0; i < timmedSessionList.length; i++) {
      mergedList.add('-i ${timmedSessionList[i]} ');
    }
    mergedList.add('-filter_complex ');
    mergedList.add('"');
    for (int i = 0; i < timmedSessionList.length; i++) {
      mergedList.add(
          '[$i:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1,fps=60 [v$i]; ');
    }
    for (int i = 0; i < timmedSessionList.length; i++) {
      mergedList.add('[v$i][$i:a] ');
    }
    mergedList.add(
        'concat=n=${timmedSessionList.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]"');
    String result = mergedList.join('');
    String commandToExecute = '$result -vb 20M -y $outputPath';
    print(commandToExecute);
    EasyLoading.show(status: 'Video Merging...');
    FFmpegKit.executeAsync(commandToExecute, (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Video successfuly saved');
        EasyLoading.showSuccess('Video Merged!');
        onSave(outputPath);
        timmedSessionList = [];
        notifyListeners();
        EasyLoading.dismiss();
      } else {
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the video');
        EasyLoading.showError('Failed to Merge');
        // onSave(null);
      }
    });
  }

  void onSave(String filepath) async {
    await GallerySaver.saveVideo(filepath);
  }

  isMultiSelectionValue(bool value) {
    isMultiSelectionEnabled = value;
    notifyListeners();
  }

  void onFinished() {
    clippedSessionList = [];

    notifyListeners();
  }

  void doMultiSelection(VideoFileModel clippedPath) {
    if (isMultiSelectionEnabled) {
      if (selectedItem.contains(clippedPath)) {
        selectedItem.remove(clippedPath);
      } else {
        selectedItem.add(clippedPath);
      }
      notifyListeners();
    } else {
      //Other logic
    }
  }
  // void doMultiSelection(String clippedPath) {
  //   if (isMultiSelectionEnabled) {
  //     if (selectedItem.contains(clippedPath)) {
  //       selectedItem.remove(clippedPath);
  //     } else {
  //       selectedItem.add(clippedPath);
  //     }
  //     notifyListeners();
  //   } else {
  //     //Other logic
  //   }
  // }

  removeClip() {
    selectedItem.forEach((nature) {
      clippedSessionList.remove(nature);
    });
    selectedItem.clear();
    notifyListeners();
  }

//for merging selected clip
  Future<void> mergeSelectedClips() async {
    final appDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath = '$rawDocumentPath/output.mp4';

    List<String> mergedList = [];
    // for (int i = 0; i < timmedSessionList.length; i++) {
    //   mergedList.add('-i ${timmedSessionList[i]}');
    // }
    // mergedList.add('-filter_complex');
    // mergedList.add('"');
    // for (int i = 0; i < timmedSessionList.length; i++) {
    //   mergedList.add('[$i:v] [$i:a]');
    // }
    // mergedList.add(
    //     'concat=n=${timmedSessionList.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]"');
    // String result = mergedList.join(' ');
    // String commandToExecute = '$result -y $outputPath';
    // print(commandToExecute);
    for (int i = 0; i < selectedItem.length; i++) {
      mergedList.add('-i ${selectedItem[i].videoPath} ');
    }
    mergedList.add('-filter_complex ');
    mergedList.add('"');
    for (int i = 0; i < selectedItem.length; i++) {
      mergedList.add(
          '[$i:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1,fps=60 [v$i]; ');
    }
    for (int i = 0; i < selectedItem.length; i++) {
      mergedList.add('[v$i][$i:a] ');
    }
    mergedList.add(
        'concat=n=${selectedItem.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]"');
    String result = mergedList.join('');
    String commandToExecute = '$result -vb 20M -y $outputPath';
    print(commandToExecute);
    EasyLoading.show(status: 'Video Merging...');
    FFmpegKit.executeAsync(commandToExecute, (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Video successfuly saved');
        EasyLoading.showSuccess('Video Merged!');
        onSave(outputPath);
        selectedItem = [];
        notifyListeners();
        EasyLoading.dismiss();
      } else {
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the video');
        EasyLoading.showError('Failed to Merge');
        // onSave(null);
      }
    });
  }
}

// class VideoFileModel {
//   final String videoPath;
//   final Uint8List thumbnailFile;
//   final bool isNewThumnailCreated;

//   VideoFileModel({
//     required this.videoPath,
//     required this.thumbnailFile,
//     this.isNewThumnailCreated = false,
//   });
// }

class VideoFileModel {
  final String videoPath;
  // final Uint8List thumbnailFile;
  final bool isNewThumnailCreated;

  VideoFileModel({
    required this.videoPath,
    // required this.thumbnailFile,
    this.isNewThumnailCreated = false,
  });
}
