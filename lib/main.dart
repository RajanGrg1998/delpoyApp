import 'package:camera/camera.dart';
import 'package:clip_test/controller/camera_con.dart';
import 'package:clip_test/controller/rotate_controller.dart';
import 'package:clip_test/screens/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'controller/clip_controller.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ClipController(),
        ),
        ChangeNotifierProvider(
          create: (context) => RotateController(),
        ),
        ChangeNotifierProvider(
          create: (context) => CameraProviderController(),
        )
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
        home: const CameraPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
