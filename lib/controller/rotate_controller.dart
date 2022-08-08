import 'package:flutter/cupertino.dart';

class RotateController extends ChangeNotifier {
  bool isRotateStartLandscapeLeft = false;
  bool isRotateStartLandscapeRight = false;
  bool isRotateStartPotarit = false;

  changeRotateStartLandscapeLeft(bool value) {
    isRotateStartLandscapeLeft = value;
    notifyListeners();
  }

  changeRotateStartLandscapeRight(bool value) {
    isRotateStartLandscapeRight = value;
    notifyListeners();
  }

  changeRotateStartPotrait(bool value) {
    isRotateStartPotarit = value;
    notifyListeners();
  }
}
