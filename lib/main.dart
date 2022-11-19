import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clip_test/controller/camera_con.dart';
import 'package:clip_test/controller/notification_controller.dart';
import 'package:clip_test/controller/rotate_controller.dart';
import 'package:clip_test/model/videofile.dart';
import 'package:clip_test/screens/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'package:path_provider/path_provider.dart' as pathProvider;
import 'controller/clip_controller.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    Hive.registerAdapter(VideoFileModelAdapter());

    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationController(),
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
        home: const SplashScreen(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class DDD extends StatefulWidget {
  const DDD({Key? key}) : super(key: key);

  @override
  State<DDD> createState() => _DDDState();
}

class _DDDState extends State<DDD> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<NotificationController>(context, listen: false).initialize();
    Provider.of<NotificationController>(context, listen: false)
        .checkforNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Provider.of<NotificationController>(context, listen: false)
                .showNotication();
          },
          child: Text('Notification'),
        ),
      ),
    );
  }
}
