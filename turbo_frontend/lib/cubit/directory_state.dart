part of 'directory_cubit.dart';

abstract class DirectoryState {
  List<String> directories = [];
  List<String> images = [];
  List<String> videos = [];
  DirectoryState(this.directories, this.images, this.videos);
}

class DirectoryInitial extends DirectoryState {
  DirectoryInitial(
      List<String> directories, List<String> images, List<String> videos)
      : super(directories, images, videos);
}

class DirectoryRefresh extends DirectoryState {
  DirectoryRefresh(
      List<String> directories, List<String> images, List<String> videos)
      : super(directories, images, videos);
}
