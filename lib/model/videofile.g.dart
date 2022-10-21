// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videofile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoFileModelAdapter extends TypeAdapter<VideoFileModel> {
  @override
  final int typeId = 0;

  @override
  VideoFileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoFileModel(
      videoPath: fields[0] as String,
      isNewThumnailCreated: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VideoFileModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.videoPath)
      ..writeByte(1)
      ..write(obj.isNewThumnailCreated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
