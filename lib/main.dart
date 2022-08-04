import 'package:camera/camera.dart';
import 'package:clip_app/controller/clip_controller.dart';
import 'package:clip_app/screens/fds.dart';
import 'package:clip_app/screens/final.dart';
import 'package:clip_app/screens/homepage.dart';
import 'package:clip_app/screens/recording_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'demo/canmera.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }

  // SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
  //   SystemUiOverlay.bottom,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClipController()),
      ],
      child: CupertinoApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
          barBackgroundColor: CupertinoColors.black,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'SF-Pro'),
          ),
        ),
        // theme: ThemeData(fontFamily: 'SF-Pro'),
        home: const FinalRecordingPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

void _logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.

