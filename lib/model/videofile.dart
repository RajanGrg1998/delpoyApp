import 'package:hive/hive.dart';
part 'videofile.g.dart';

@HiveType(typeId: 0)
class VideoFileModel extends HiveObject {
  @HiveField(0)
  final String videoPath;
  // final Uint8List thumbnailFile;
  @HiveField(1)
  final bool isNewThumnailCreated;

  VideoFileModel({
    required this.videoPath,
    // required this.thumbnailFile,
    this.isNewThumnailCreated = false,
  });
}
