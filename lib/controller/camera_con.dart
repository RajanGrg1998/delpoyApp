import 'package:camera/camera.dart';
import 'package:clip_test/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class CameraProviderController extends ChangeNotifier {
  CameraController? oneCameraController;

  VideoPlayerController? videoController;

  String stopTimeDisplay = "00:00:00";
  var swatch = Stopwatch();

  var extend = false;
  var rmicons = false;

  bool isRecordButtonVissible = true;

  bool isChangeColor = false;

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    // if (oneCameraController != null) {
    //   await oneCameraController!.dispose();
    // }

    // final previousCameraController = oneCameraController;

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.veryHigh,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // await previousCameraController?.dispose();
    resetCameraValues();

    // oneCameraController = cameraController;

    // If the controller is updated then update the UI.

    try {
      await cameraController.initialize();
      await cameraController.unlockCaptureOrientation();
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
      currentFlashMode = oneCameraController!.value.flashMode;
      isLoading = false;
      notifyListeners();
    } on CameraException catch (e) {
      showCameraException(e);
    }
  }

  void resetCameraValues() async {
    currentZoomLevel = 1.0;
    currentExposureOffset = 0.0;
  }
}
