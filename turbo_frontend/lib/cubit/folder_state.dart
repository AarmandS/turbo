part of 'folder_cubit.dart';

abstract class FolderState {
  List<String> folders = [];
  List<FileModel> files = [];
  FolderState(this.folders, this.files);
}

class FolderInitial extends FolderState {
  FolderInitial(List<String> folders, List<FileModel> files)
      : super(folders, files);
}

class FolderRefresh extends FolderState {
  FolderRefresh(List<String> folders, List<FileModel> files)
      : super(folders, files);
}