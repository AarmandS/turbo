// import 'package:bloc/bloc.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:turbo/cubit/directory_cubit.dart';

// import '../models/media_file.dart';
// import '../network_service.dart';

// part 'image_viewer_state.dart';

// class ImageViewerCubit extends Cubit<ImageViewerState> {
//   ImageViewerCubit() : super(ImageViewerState([], -1));

//   void viewImage(int imageIndex) {
//     emit(ImageViewerState([], imageIndex));
//   }

//   void viewNextImage() {
//     var index = state.selectedImageIndex;
//     if (index < state.images.length - 1) {
//       emit(DirectoryViewingImages(state.images, index + 1));
//     }
//   }

//   void viewPreviousImage() {
//     if (state is ViewingImages) {
//       var index = (state as ViewingImages).selectedImageIndex;
//       if (index > 0) {
//         emit(ViewingImages(
//             index - 1, state.directories, state.images, state.videos));
//       }
//     }
//   }
// }
