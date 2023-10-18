import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  MediaCubit() : super(MediaInitial());

  void playVideo(String mediaUrl) {
    emit(MediaVideoPlaying(mediaUrl));
  }

  void closeVideoPlayer() {
    emit(MediaInitial());
  }

  void viewPhotos(List<String> photoMediaUrls, int openedPhotoIndex) {
    // emit(MediaViewingPhotos());
  }
}
