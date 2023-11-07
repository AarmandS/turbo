import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/file_model.dart';
import '../network_service.dart';

part 'directory_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> {
  late NetworkService _networkService;
  String navigationPath = '';
  DirectoryCubit(NetworkService networkService)
      // maybe directory initial should be without args
      : super(DirectoryInitial([], [], [])) {
    _networkService = networkService;
  }

  void createDirectory(String name) async {
    await _networkService.createDirectory('$navigationPath/$name');
    // handle unsuccesful directory creation
    state.directories.add(name);
    emit(DirectoryRefresh(state.directories, state.images, state.videos));
  }

  // terjen vissza resultal
  void shareDirectory(String directoryName, String username) async {
    await _networkService.shareDirectory(
        '$navigationPath/$directoryName', username);
  }

  void renameDirectory(String oldName, String newName) async {
    _networkService.renameDirectory('$navigationPath/$oldName', newName);
    // handle unsuccesful directory creation
    var oldDirIndex = state.directories.indexOf(oldName);
    state.directories.remove(oldName);
    state.directories.insert(oldDirIndex, newName);
    emit(DirectoryRefresh(state.directories, state.images, state.videos));
  }

  void deleteDirectory(String name) async {
    _networkService.deleteDirectory('$navigationPath/$name');
    // handle unsuccesful directory deletion
    state.directories.remove(name);
    emit(DirectoryRefresh(state.directories, state.images, state.videos));
  }

  void navigateToDirectory(String path) async {
    navigationPath = path;
    await _networkService
        .getDirectory(navigationPath)
        .then((directoryModel) async {
      // var fileModels =
      //     await Future.wait(directoryModel.containedFiles.map((filePath) async {
      //   FileModel file =
      //       await _networkService.getFile('$navigationPath/$filePath');
      //   return file;
      // }).toList());
      emit(DirectoryRefresh(
          directoryModel.directories, directoryModel.images, []));
    });
  }

  void navigateBack() {
    var pathParts = navigationPath.split('/');
    if (pathParts.length > 1) {
      pathParts.removeLast();
      navigationPath = pathParts.join('/');
      navigateToDirectory(navigationPath);
    }
  }

  NetworkImage? getImage(String filename) {
    return _networkService.getImage('$navigationPath/$filename');
  }

  void uploadFile(PlatformFile file) async {
    var success = await _networkService.uploadFile(navigationPath, file);
    // if (success) {
    //   await _networkService.getFile('$navigationPath/$name').then((fileModel) {
    //     state.files.add(fileModel);
    //     emit(DirectoryRefresh(state.directories, state.files));
    //   });
    // }
  }

  void viewImage(int imageIndex) {
    emit(DirectoryViewingImages(
        imageIndex, state.directories, state.images, state.videos));
  }

  void viewNextImage() {
    if (state is DirectoryViewingImages) {
      var index = (state as DirectoryViewingImages).selectedImageIndex;
      if (index < state.images.length - 1) {
        emit(DirectoryViewingImages(
            index + 1, state.directories, state.images, state.videos));
      }
    }
  }

  void viewPreviousImage() {
    if (state is DirectoryViewingImages) {
      var index = (state as DirectoryViewingImages).selectedImageIndex;
      if (index > 0) {
        emit(DirectoryViewingImages(
            index - 1, state.directories, state.images, state.videos));
      }
    }
  }
}
