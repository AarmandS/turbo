class DirectoryModel {
  String path;
  List<String> directories;
  List<String> images;
  List<String> videos;

  DirectoryModel.fromJson(Map<String, dynamic> json)
      : path = json['media_path'],
        directories = (json['directories'] as List)
            .map((directory) => directory as String)
            .toList(),
        images =
            (json['images'] as List).map((file) => file as String).toList(),
        videos =
            (json['videos'] as List).map((file) => file as String).toList();
}
