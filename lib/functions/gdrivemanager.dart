import 'dart:developer';

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
    log(folderID!);
    var data = await driveApi.files.list(
      q: "'$folderID' in parents",
      $fields: "files(id, name)",
    );

    List<GFile> files = [];
    for (var item in data.files!) {
      files.add(GFile(item.name!, item.id!));
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
}
