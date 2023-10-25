import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:turbo/models/token.dart';

import 'models/file_model.dart';
import 'models/directory_model.dart';
import 'dart:developer' as developer;

// this should be on the local screen on android
const String baseUrl = String.fromEnvironment("BACKEND_URL");

class NetworkService {
  AccessToken? accessToken;

  Future<bool> getAccessToken(String username, String password) async {
    developer.log(baseUrl, name: 'my.app.category');
    var url = Uri.parse('$baseUrl/login');

    final Map<String, String> headers = {
      'Content-Type': 'application/json', // Set the Content-Type here
    };
    // fix on web
    var response = await http.post(url,
        body: jsonEncode({'username': username, 'password': password}),
        headers: headers);

    if (response.statusCode != 200) {
      return false;
    }

    accessToken = AccessToken.fromJson(jsonDecode(response.body));
    return true;
  }

  NetworkImage? getImage(String mediaUrl) {
    if (accessToken != null) {
      var url = '$baseUrl/media/$mediaUrl';
      var token = accessToken?.accessToken;
      var image =
          NetworkImage(url, headers: {'Authorization': 'Bearer $token'});
      return image;
    }

    return null;
  }

  Future<bool> createDirectory(String path) async {
    if (accessToken != null) {
      var encodedPath = path.replaceAll("/", "%2F");
      var url = Uri.parse('$baseUrl/directories/$encodedPath');
      var token = accessToken?.accessToken;
      // nincs lekezelve ha mondjuk ugyan az a neve, szerver oldalon se
      var response = await http.post(url, headers: {'Authorization': token!});

      if (response.statusCode == 201) {
        return true;
      }
    }
    return false;
  }

  Future<bool> shareDirectory(String path, String username) async {
    if (accessToken != null) {
      // var encodedPath = path.replaceAll("/", "%2F");
      var url = Uri.parse('$baseUrl/share');
      var token = accessToken?.accessToken;
      // nincs lekezelve ha mondjuk ugyan az a neve, szerver oldalon se
      var response = await http.post(url,
          headers: {
            'Authorization': token!,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "media_path": path,
            "username": username,
          }));

      if (response.statusCode == 200) {
        return true;
      } // itt is resultot hasznalni mint rustban, es kulon lekezelni az eseteket
    }
    return false;
  }

  // handle failures
  void renameDirectory(String path, String newName) async {
    if (accessToken != null) {
      var encodedPath = path.replaceAll("/", "%2F");
      var url = Uri.parse('$baseUrl/directories/$encodedPath');
      var token = accessToken?.accessToken;
      final Map<String, String> headers = {
        'Authorization': token!,
        'Content-Type': 'application/json',
      };

      http.put(
        url,
        headers: headers,
        body: jsonEncode({'new_name': newName}),
      );
    }
  }

  void deleteDirectory(String path) async {
    if (accessToken != null) {
      var encodedPath = path.replaceAll("/", "%2F");
      var url = Uri.parse('$baseUrl/directories/$encodedPath');
      var token = accessToken?.accessToken;
      // nincs lekezelve ha mondjuk ugyan az a neve, szerver oldalon se
      var response = await http.delete(url, headers: {'Authorization': token!});
    }
  }

  Future<DirectoryModel> getDirectory(String path) async {
    var encodedPath = path.replaceAll("/", "%2F");
    var url = Uri.parse('$baseUrl/directories/$encodedPath');
    var token = accessToken?.accessToken;

    // nincs lekezelve ha mondjuk ugyan az a neve, szerver oldalon se
    // ! unsafe
    var response = await http.get(url, headers: {'Authorization': token!});

    return DirectoryModel.fromJson(jsonDecode(response.body));
  }

  Future<FileModel> getFile(String path) async {
    var url = Uri.http(baseUrl, 'files/$path');
    var token = accessToken?.accessToken;

    var response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    return FileModel.fromJson(jsonDecode(response.body));
  }

// bad name not only image
  Future<bool> uploadImage(
      String path, String name, String fileExtension, String filePath) async {
    var url = Uri.http(baseUrl, 'files/$path');
    var token = accessToken?.accessToken;

    var request = http.MultipartRequest(
      'POST',
      url,
    );
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType('application', 'octet-stream'),
    ));

    var response = await request.send();
    return response.statusCode == 200;
  }
}
