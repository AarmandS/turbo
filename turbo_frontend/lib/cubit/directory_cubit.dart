import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:turbo/models/token.dart';

import '../models/media_file.dart';
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
      emit(DirectoryRefresh(directoryModel.directories, directoryModel.images,
          directoryModel.videos));
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

  String getVideoURL() {
    if (state is DirectoryViewingVideo) {
      var videoState = state as DirectoryViewingVideo;
      var encodedPath =
          '$navigationPath/${videoState.filename}'.replaceAll("/", "%2F");
      return '$baseUrl/files/$encodedPath';
    }
    return '';
  }

  void uploadFile(PlatformFile file) async {
    var success = await _networkService.uploadFile(navigationPath, file);
    // if (success) {
    await _networkService
        .getDirectory(navigationPath)
        .then((directoryModel) async {
      emit(DirectoryRefresh(directoryModel.directories, directoryModel.images,
          directoryModel.videos));
    });
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

  void viewVideo(String filename) {
    emit(DirectoryViewingVideo(
        filename, state.directories, state.images, state.videos));
  }

  String getToken() {
    return _networkService.accessToken!.accessToken;
  }
}
