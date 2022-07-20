import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/clip_controller.dart';
import '../../helpers/trimmer/src/trim_editor.dart';
import '../../helpers/trimmer/src/trimmer.dart';
import '../../helpers/trimmer/src/video_viewer.dart';

class SingleTrimPage extends StatefulWidget {
  const SingleTrimPage({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<SingleTrimPage> createState() => _SingleTrimPageState();
}

class _SingleTrimPageState extends State<SingleTrimPage> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    _loadVideo();
    super.initState();
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.path));
  }

  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    await _trimmer.saveTrimmedVideo(
      videoFileName: 'timmedvideo${DateTime.now().second}',
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) async {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
        Provider.of<ClipController>(context, listen: false)
            .addTrimmedSession(outputPath!);

        // await GallerySaver.saveVideo(outputPath);
        // File(outputPath).deleteSync();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.only(right: 15),
          child: Text('Trim'),
          onPressed: _saveVideo,
        ),
      ),
      // appBar: AppBar(
      //   actions: [
      //     ElevatedButton(
      //       onPressed: _saveVideo,
      //       child: Text('Save'),
      //     )
      //   ],
      // ),
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress) {
            return false;
          } else {
            return true;
          }
        },
        child: Column(
          children: [
            Visibility(
              visible: _progressVisibility,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.red,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: VideoViewer(trimmer: _trimmer),
            ),
            Center(
              child: TrimEditor(
                trimmer: _trimmer,
                durationTextStyle: TextStyle(color: Colors.black),
                viewerHeight: 50.0,
                viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: const Duration(hours: 10),
                onChangeStart: (value) {
                  _startValue = value;
                },
                onChangeEnd: (value) {
                  _endValue = value;
                },
                onChangePlaybackState: (value) {
                  setState(() {
                    isPlaying = value;
                  });
                },
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
