class DirectoryModel {
  String path;
  List<String> containedDirectorys;
  List<String> containedFiles;

  DirectoryModel.fromJson(Map<String, dynamic> json)
      : path = json['media_path'],
        containedDirectorys = (json['contents']['directories'] as List)
            .map((directory) => directory as String)
            .toList(),
        containedFiles = (json['contents']['files'] as List)
            .map((file) => file as String)
            .toList();
}
