part of 'directory_cubit.dart';

abstract class DirectoryState {
  List<String> directories = [];
  List<String> images = [];
  List<String> videos = [];
  DirectoryState(this.directories, this.images, this.videos);
}

class DirectoryInitial extends DirectoryState {
  DirectoryInitial(super.directories, super.images, super.videos);
}

class DirectoryRefresh extends DirectoryState {
  DirectoryRefresh(super.directories, super.images, super.videos);
}

class DirectoryViewingImages extends DirectoryState {
  int selectedImageIndex;

  DirectoryViewingImages(
      this.selectedImageIndex, super.directories, super.images, super.videos);
}
