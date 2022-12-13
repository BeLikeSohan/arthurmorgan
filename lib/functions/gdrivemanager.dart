import 'dart:developer';

import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/pubsub/v1.dart';
import 'package:mime/mime.dart';
import 'package:oauth2/oauth2.dart';
import 'package:provider/provider.dart';

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
          item.id!,
          item.name!,
          lookupMimeType(item.name!),
          int.parse(item.size!),
          item.createdTime!));
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
      GlobalData.logger.d("this");
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
      GlobalData.logger.d("that");
      String? folderId;

      var files = await driveApi.files.list(
        q: "'root' in parents",
        $fields: "files(id, name, parents)",
      );

      for (var item in files.files!) {
        GlobalData.logger.d(item.name!);
        GlobalData.logger.d(item.parents.toString());
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
      GlobalData.logger.d("Upload result: $result");
      checkIfNewUser(); // calling this here to update the folderId, not good
      return true;
    } catch (e) {
      GlobalData.logger.d(e.toString());
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

  Future<bool> uploadFile(BuildContext context, String fileName, int fileLength,
      Stream<List<int>> steram) async {
    final options = drive.UploadOptions.resumable;
    var media = drive.Media(
        steram.chunkRead(
          chunkSize: options.chunkSize,
          read: (val) {
            GlobalData.logger.d("Progress % : ${(val / fileLength) * 100}");
            Provider.of<TaskInfoPopUpProvider>(context, listen: false)
                .setProgress((val / fileLength) * 100);
          },
        ),
        fileLength);

    var driveFile = drive.File();
    driveFile.name = fileName;
    driveFile.parents = [folderID!];

    final response = await driveApi.files.create(driveFile, uploadMedia: media);
    GlobalData.logger.d("response: ${response.toString()}");

    return true;
  }

  Future<Stream> downloadFile(GFile gfile) async {
    drive.Media media = await driveApi.files.get(gfile.id,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    return media.stream;
  }

  Future<Stream> downloadThumbnail(GFile gfile) async {
    drive.Media media = await driveApi.files.get(gfile.id,
            downloadOptions:
                drive.PartialDownloadOptions(drive.ByteRange(0, 65536)))
        as drive.Media;
    return media.stream;
  }
}

extension on Stream<List<int>> {
  /// read: callback to print the progress
  /// chunkSize: size of the chunk default is 1024 bytes
  Stream<List<int>> chunkRead(
      {Function(int read)? read, int chunkSize = 1024}) async* {
    final buffer = <int>[];
    var loaded = 0;
    await for (var data in this) {
      buffer.addAll(data);
      for (int i = 0; i < buffer.length; i += chunkSize) {
        data = buffer.sublist(
            i, i + chunkSize > buffer.length ? buffer.length : i + chunkSize);
        loaded += data.length;
        if (read != null) {
          read(loaded);
        }
        yield data;
      }
      buffer.removeRange(0, buffer.length);
    }
  }
}
