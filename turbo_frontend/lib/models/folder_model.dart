class FolderModel {
  String path;
  List<String> containedFolders;
  List<String> containedFiles;

  FolderModel.fromJson(Map<String, dynamic> json)
      : path = json['media_path'],
        containedFolders = (json['contents']['directories'] as List)
            .map((folder) => folder as String)
            .toList(),
        containedFiles = (json['contents']['files'] as List)
            .map((file) => file as String)
            .toList();
}
