part of 'directory_cubit.dart';

abstract class DirectoryState {
  List<String> directories = [];
  List<FileModel> files = [];
  DirectoryState(this.directories, this.files);
}

class DirectoryInitial extends DirectoryState {
  DirectoryInitial(List<String> directories, List<FileModel> files)
      : super(directories, files);
}

class DirectoryRefresh extends DirectoryState {
  DirectoryRefresh(List<String> directories, List<FileModel> files)
      : super(directories, files);
}
