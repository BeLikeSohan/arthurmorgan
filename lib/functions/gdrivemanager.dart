import 'dart:developer';

import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
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
      if (item.name == "arthurmorgan") continue;
      var gfile = await FileHandler.decryptGfile(GFile(
          item.id!, item.name!, int.parse(item.size!), item.createdTime!));
      files.add(gfile);
    }
    return files;
  }

  Future<String?> getFolderId(String folderName) async {
    String? folderId;

    var files = await driveApi.files.list();
    for (var item in files.files!) {
      if (item.name == folderName) {
        folderId = item.id;
        break;
      }
    }

    return folderId;
  }

  Future<bool> checkIfNewUser() async {
    if (GlobalData.gCustomRootFolder != null) {
      log("this");
      GlobalData.gCustomRootFolderId =
          await getFolderId(GlobalData.gCustomRootFolder!);
      String? folderId;

      var files = await driveApi.files.list(
        q: "'${GlobalData.gCustomRootFolderId}' in parents",
      );
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
    } else {
      log("that");
      String? folderId;

      var files = await driveApi.files.list(
        q: "'root' in parents",
        $fields: "files(id, name, parents)",
      );

      for (var item in files.files!) {
        log(item.name!);
        log(item.parents.toString());
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
  }

  Future<bool> setupArthurMorgan(String verifyString) async {
    try {
      var folder = await driveApi.files.create(drive.File()
        ..name = "ArthurMorgan"
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = GlobalData.gCustomRootFolder == null
            ? null
            : [GlobalData.gCustomRootFolderId!]);

      final Stream<List<int>> mediaStream =
          Future.value(verifyString.codeUnits).asStream().asBroadcastStream();
      var media = drive.Media(mediaStream, verifyString.length);
      var driveFile = drive.File();
      driveFile.name = "arthurmorgan";
      driveFile.parents = [folder.id!];
      final result = await driveApi.files.create(driveFile, uploadMedia: media);
      log("Upload result: $result");
      checkIfNewUser(); // calling this here to update the folderId, not good
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<drive.Media> getVerifyFile() async {
    var data = await driveApi.files.list(
      q: "'$folderID' in parents",
      $fields: "files(id, name)",
    );

    String? verifyFileId;

    for (var item in data.files!) {
      if (item.name == "arthurmorgan") verifyFileId = item.id;
    }

    drive.Media verifyFileMedia = await driveApi.files.get(verifyFileId!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    return verifyFileMedia;
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

  Future<Stream> downloadFile(GFile gfile) async {
    drive.Media media = await driveApi.files.get(gfile.id,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    return media.stream;
  }
}
