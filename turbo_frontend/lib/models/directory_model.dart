import 'dart:convert';

import 'package:turbo/models/media_file.dart';

class DirectoryModel {
  String path;
  List<String> directories;
  List<MediaFile> images;
  List<MediaFile> videos;

  DirectoryModel.fromJson(Map<String, dynamic> json)
      : path = json['media_path'],
        directories = (json['directories'] as List)
            .map((directory) => directory as String)
            .toList(),
        images = (json['images'] as List)
            .map((file) => MediaFile.fromJson(file))
            .toList(),
        videos = (json['videos'] as List)
            .map((file) => MediaFile.fromJson(file))
            .toList();
}
