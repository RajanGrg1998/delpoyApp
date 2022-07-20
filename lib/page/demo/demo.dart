import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/clip_controller.dart';
import '../editor/videoeditorpage.dart';
import '../singletrim/single_trimm_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        // leadingWidth: clipCon.isMultiSelectionEnabled ? 60 : 100,
        // leading:
        //     clipCon.isMultiSelectionEnabled || clipCon.selectedItem.isNotEmpty
        //         ? CupertinoButton(
        //             padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        //             child: Text(
        //               'Done',
        //               style: TextStyle(
        //                 color: CupertinoColors.white,
        //                 fontSize: 15,
        //               ),
        //             ),
        //             onPressed: () {

        //             },
        //           )
        //         : null,
        title: clipCon.isMultiSelectionEnabled ? null : Text('Trimmer One'),
        actions: [
          // clipCon.isMultiSelectionEnabled
          //     ? Visibility(
          //         visible: clipCon.selectedItem.isNotEmpty,
          //         child: CupertinoButton(
          //           padding: EdgeInsets.only(right: 15),
          //           child: Text(
          //             'Merge',
          //             style: TextStyle(
          //               color: CupertinoColors.white,
          //               fontSize: 15,
          //             ),
          //           ),
          //           onPressed: () {
          //             clipCon.mergeSelectedClips();
          //           },
          //         ),
          //       )
          //     : Container(),
          // clipCon.isMultiSelectionEnabled
          //     ? Visibility(
          //         visible: clipCon.selectedItem.isNotEmpty,
          //         child: CupertinoButton(
          //           padding: EdgeInsets.only(right: 15),
          //           child: Text(
          //             'Delete Clips',
          //             style: TextStyle(
          //               color: CupertinoColors.white,
          //               fontSize: 15,
          //             ),
          //           ),
          //           onPressed: () {
          //             clipCon.removeClip();
          //           },
          //         ),
          //       )
          //     : Container(),

          clipCon.timmedSessionList.isNotEmpty
              ? Visibility(
                  visible: clipCon.isMultiSelectionEnabled == false,
                  child: CupertinoButton(
                    padding: EdgeInsets.only(right: 15),
                    child: Text(
                      'Merge',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      clipCon.mergeRequest();
                    },
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: clipCon.pickVideoFromCamera,
            child: Text('Record Video'),
          ),
          SizedBox(height: 20),
          clipCon.clipVideosList.isEmpty
              ? Center(
                  child: Text(
                    'Video not clips not recorded....',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: clipCon.clipVideosList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onLongPress: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SingleTrimPage(
                                    path: clipCon.clipVideosList[index]),
                              ),
                            );
                            // clipCon.isMultiSelectionValue(true);
                            // clipCon.doMultiSelection(
                            //     clipCon.clipVideosList[index]);
                          },
                          onTap:
                              // clipCon.isMultiSelectionEnabled
                              //     ? () {
                              //         clipCon.doMultiSelection(
                              //             clipCon.clipVideosList[index]);
                              //       }
                              //     :
                              () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => VideoEditor(
                                    file: File(clipCon.clipVideosList[index])),
                              ),
                            );
                          },
                          // onTap: () {
                          // Navigator.push(
                          //   context,
                          //   CupertinoPageRoute(
                          //     builder: (context) => SingleTrimPage(
                          //         path: clipCon.clipVideosList[index]),
                          //   ),
                          // );
                          //   // print(clipCon.file);
                          // },
                          tileColor: Colors.white,
                          title: Text('Video number ${index + 1}'),
                          // trailing: Visibility(
                          //   visible: clipCon.isMultiSelectionEnabled &&
                          //       clipCon.selectedItem.isNotEmpty,
                          //   child: Icon(
                          //     clipCon.selectedItem
                          //             .contains(clipCon.clipVideosList[index])
                          //         ? Icons.check_circle
                          //         : Icons.radio_button_unchecked,
                          //     size: 25,
                          //     color: Colors.red,
                          //   ),
                          // ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Clear Recorded Session'),
          content: Text('Do you want to clear Recorded Session and go back'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                Provider.of<ClipController>(context, listen: false)
                    .onFinished();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void showInSnackBar(String message) {
  // ignore: deprecated_member_use
  scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
}
