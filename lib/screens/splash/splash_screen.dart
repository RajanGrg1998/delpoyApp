// ignore_for_file: avoid_print

import 'dart:async';

import 'package:clip_test/model/videofile.dart';
import 'package:clip_test/screens/demo/demo_home.dart';
import 'package:clip_test/screens/demoeditpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../controller/notification_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAsycCompleted = false;

  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  startTime() async {
    var _duration = const Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    var box = await Hive.openBox<VideoFileModel>('clipedvideo');
    if (box.values.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => DemoIOSEditClipPage(),
          ),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => HomeDemoApp(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isAsycCompleted,
        child: SafeArea(
          child: Container(
            color: CupertinoColors.black,
            child: Center(
              child: Image.asset(
                'assets/app_splash.png',
                color: CupertinoColors.white,
                filterQuality: FilterQuality.high,
                height: MediaQuery.of(context).size.height / 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
