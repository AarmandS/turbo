part of 'media_cubit.dart';

abstract class MediaState {}

class MediaInitial extends MediaState {}

// rename to media video playing
class MediaVideoPlaying extends MediaState {
  final String mediaUrl;
  MediaVideoPlaying(this.mediaUrl) : super();
}

class MediaViewingPhotos extends MediaState {
  final List<String> photoMediaUrls;
  int selectedPhotoIndex;

  MediaViewingPhotos(this.photoMediaUrls, this.selectedPhotoIndex) : super();
}
