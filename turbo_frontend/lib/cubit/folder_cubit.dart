import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/file_model.dart';
import '../network_service.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  late NetworkService _networkService;
  String navigationPath = '';
  FolderCubit(NetworkService networkService) : super(FolderInitial([], [])) {
    _networkService = networkService;
  }

  void createFolder(String name) async {
    await _networkService.createFolder('$navigationPath/$name');
    // handle unsuccesful folder creation
    state.folders.add(name);
    emit(FolderRefresh(state.folders, state.files));
  }

  void navigateToFolder(String path) async {
    navigationPath = path;
    await _networkService.getFolder(navigationPath).then((folderModel) async {
      var fileModels =
          await Future.wait(folderModel.containedFiles.map((filePath) async {
        FileModel file =
            await _networkService.getFile('$navigationPath/$filePath');
        return file;
      }).toList());
      emit(FolderRefresh(folderModel.containedFolders, fileModels));
    });
  }

  void navigateBack() {
    var pathParts = navigationPath.split('/');
    if (pathParts.length > 1) {
      pathParts.removeLast();
      navigationPath = pathParts.join('/');
      navigateToFolder(navigationPath);
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
        emit(FolderRefresh(state.folders, state.files));
      });
    }
  }
}
