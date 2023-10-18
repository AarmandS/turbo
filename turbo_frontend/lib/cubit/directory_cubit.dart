import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/file_model.dart';
import '../network_service.dart';

part 'directory_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> {
  late NetworkService _networkService;
  String navigationPath = '';
  DirectoryCubit(NetworkService networkService)
      : super(DirectoryInitial([], [])) {
    _networkService = networkService;
  }

  void createDirectory(String name) async {
    await _networkService.createDirectory('$navigationPath/$name');
    // handle unsuccesful directory creation
    state.directories.add(name);
    emit(DirectoryRefresh(state.directories, state.files));
  }

  void deleteDirectory(String name) async {
    _networkService.deleteDirectory('$navigationPath/$name');
    // handle unsuccesful directory deletion
    state.directories.remove(name);
    emit(DirectoryRefresh(state.directories, state.files));
  }

  void navigateToDirectory(String path) async {
    navigationPath = path;
    await _networkService
        .getDirectory(navigationPath)
        .then((directoryModel) async {
      var fileModels =
          await Future.wait(directoryModel.containedFiles.map((filePath) async {
        FileModel file =
            await _networkService.getFile('$navigationPath/$filePath');
        return file;
      }).toList());
      emit(DirectoryRefresh(directoryModel.containedDirectorys, fileModels));
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

  NetworkImage? getImage(String mediaUrl) {
    return _networkService.getImage(mediaUrl);
  }

  void uploadImage(String name, String fileExtension, String filePath) async {
    var success = await _networkService.uploadImage(
        navigationPath, name, fileExtension, filePath);
    if (success) {
      await _networkService.getFile('$navigationPath/$name').then((fileModel) {
        state.files.add(fileModel);
        emit(DirectoryRefresh(state.directories, state.files));
      });
    }
  }
}
