import 'dart:convert';
import 'dart:developer';

import 'package:desktop_experiments/functions/filehandler.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/models/gfile.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:oauth2/oauth2.dart';

class GDriveManager {
  late drive.DriveApi driveApi;

  String? folderID;

  GDriveManager(Client client) {
    driveApi = drive.DriveApi(client);
  }

  Future<List<GFile>> getFiles() async {
    if (folderID == null) return []; // TODO: FIX THIS SHIT
    var data = await driveApi.files.list(
      q: "'$folderID' in parents",
      $fields: "files(id, name, size, createdTime)",
    );

    List<GFile> files = [];
    for (var item in data.files!) {
      var gfile = await FileHandler.decryptGfile(GFile(
          item.id!, item.name!, int.parse(item.size!), item.createdTime!));
      files.add(gfile);
    }
    return files;
  }

  Future<bool> checkIfNewUser() async {
    String? folderId;

    var files = await driveApi.files.list();
    for (var item in files.files!) {
      if (item.name == "ArthurMorgan") {
        folderId = item.id;
        break;
      }
    }

    if (folderId == null) return true;

    folderID = folderId;

    var data = await driveApi.files.list(
      q: "'$folderID' in parents",
      $fields: "files(id, name)",
    );
    return data.files!.isEmpty;
  }

  Future<bool> setupArthurMorgan() async {
    try {
      var folder = await driveApi.files.create(drive.File()
        ..name = "ArthurMorgan"
        ..mimeType = 'application/vnd.google-apps.folder');

      final Stream<List<int>> mediaStream =
          Future.value([104, 105]).asStream().asBroadcastStream();
      var media = drive.Media(mediaStream, 2);
      var driveFile = drive.File();
      driveFile.name = "arthurmorgan";
      driveFile.parents = [folder.id!];
      final result = await driveApi.files.create(driveFile, uploadMedia: media);
      print("Upload result: $result");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile(
      String fileName, int fileLength, Stream<List<int>> steram) async {
    var media = drive.Media(steram, fileLength);

    var driveFile = drive.File();
    driveFile.name = fileName;
    driveFile.parents = [folderID!];

    final response = await driveApi.files.create(driveFile, uploadMedia: media);
    log("response: ${response.toString()}");

    return true;
  }

  Future<String> downloadFile(GFile gfile) async {
    drive.Media file = await driveApi.files.get(gfile.id,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    List<int> dataStore = [];
    file.stream.listen((data) {
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      return "ok";
      print("DL Done");
    }, onError: (error) {
      print("Some Error");
    });
  }
}
