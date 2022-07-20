// Counting pointers (number of user fingers on screen)
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

int pointers = 0;

double currentScale = 1.0;
double baseScale = 1.0;

void handleScaleStart(ScaleStartDetails details) {
  baseScale = currentScale;
}

// loading
bool saveLoading = false;
double savingProgress = 0.0;
bool isLoading = true;
bool isRecordingInProgress = false;
bool isCameraInitialized = false;

bool isCameraPermissionGranted = false;
// flashmode
FlashMode? currentFlashMode;
bool onFlashClick = true;

//rear camera
bool isRearCameraSelected = true;

final resolutionPresets = ResolutionPreset.values;

ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

// zoom

double minAvailableExposureOffset = 0.0;
double maxAvailableExposureOffset = 0.0;
double minAvailableZoom = 1.0;
double maxAvailableZoom = 1.0;
double currentZoomLevel = 1.0;
double currentExposureOffset = 0.0;

final isDialOpen = ValueNotifier(false);

Future<void> handleScaleUpdate(
    ScaleUpdateDetails details, CameraController _cameraController) async {
  // When there are not exactly two fingers on screen don't scale
  if (pointers != 2) {
    return;
  }

  currentScale =
      (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

  await _cameraController.setZoomLevel(currentScale);
}

class CustomTimeButton extends StatelessWidget {
  const CustomTimeButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);
  final String label;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          color: Colors.white,
          size: 50,
        ),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.white,
              shape: CircleBorder(),
              side: BorderSide(color: Colors.black, width: 2)),
        )
      ],
    );
  }
}

void showInSnackBar(String message) {
  // ignore: deprecated_member_use
  scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

void resetCameraValues() async {
  currentZoomLevel = 1.0;
  currentExposureOffset = 0.0;
}

void showCameraException(CameraException e) {
  logError(e.code, e.description);
  showInSnackBar('Error: ${e.code}\n${e.description}');
}
