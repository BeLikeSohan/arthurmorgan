import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/functions/gdrivemanager.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:arthurmorgan/utils.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as path;

class EncryptionUploadProvider extends ChangeNotifier {
  EncryptionState encryptionState = EncryptionState.free;
  int currentFileIndex = 0;
  int totalFiles = 0;

  void startVideoEncryptionAndUpload(BuildContext context, File file) {
    Utils.clearTemp();

    encryptionState = EncryptionState.encrypting;
    double encryptionProgress = 0;
    notifyListeners();

    Provider.of<TaskInfoPopUpProvider>(context, listen: false).show(
        "Encrypting ${file.path.split("\\").last} (${currentFileIndex}/$totalFiles)");

    final port = ReceivePort();

    String docDir = GlobalData.gAppDocDir!.path;
    String tempPath = path.join(docDir, "ArthurMorgan", "Temp", "temp.meb");

    File tempFile = File(tempPath);

    String fileNameEncrypted =
        GlobalData.gMorgan!.encryptFileName(file.path.split('\\').last);

    Isolate.spawn(GlobalData.gMorgan!.packVideo, {
      "videoFile": file,
      "tempFile": tempFile,
      "port": port.sendPort,
    });

    port.listen((message) {
      if (message == "PACK_VIDEO_DONE") {
        encryptionProgress = 100;
        Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        uploadFileToDrive(
            context, tempFile, file.path.split('\\').last, fileNameEncrypted);
        port.close();
      } else {
        encryptionProgress = message;
      }
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .setProgress(encryptionProgress);
      log(encryptionProgress.toString());
      notifyListeners();
    });
  }

  void startImageEncryptionAndUpload(BuildContext context, File file) async {
    Utils.clearTemp();

    encryptionState = EncryptionState.encrypting;
    double encryptionProgress = 0;
    notifyListeners();

    Provider.of<TaskInfoPopUpProvider>(context, listen: false).show(
        "Encrypting ${file.path.split("\\").last} (${currentFileIndex}/$totalFiles)");

    final port = ReceivePort();

    String docDir = GlobalData.gAppDocDir!.path;
    String tempPath = path.join(docDir, "ArthurMorgan", "Temp", "temp.meb");

    File tempFile = File(tempPath);

    String fileNameEncrypted =
        GlobalData.gMorgan!.encryptFileName(file.path.split('\\').last);

    Isolate.spawn(GlobalData.gMorgan!.packImage, {
      "imageFile": file,
      "tempFile": tempFile,
      "port": port.sendPort,
    });

    port.listen((message) {
      if (message == "PACK_IMAGE_DONE") {
        encryptionProgress = 100;
        Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        uploadFileToDrive(
            context, tempFile, file.path.split('\\').last, fileNameEncrypted);
        port.close();
      } else {
        encryptionProgress = message;
      }
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .setProgress(encryptionProgress);
      log(encryptionProgress.toString());
      notifyListeners();
    });
  }

  void uploadFileToDrive(BuildContext context, File file, String fileName,
      String fileNameEncrypted) async {
    encryptionState = EncryptionState.uploading;
    double uploadProgress = 0;

    Provider.of<TaskInfoPopUpProvider>(context, listen: false)
        .show("Uploading $fileName (${currentFileIndex}/$totalFiles)");
    Provider.of<TaskInfoPopUpProvider>(context, listen: false)
        .setProgress(uploadProgress);

    await GlobalData.gDriveManager!.uploadFile(
        context, fileNameEncrypted, file.lengthSync(), file.openRead());
    Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    currentFileIndex++;

    Provider.of<GDriveProvider>(context, listen: false).getFileList();
    encryptionState = EncryptionState.free;
  }

  void downloadAndDecryptVideo(
      BuildContext context, GFile encryptedFile) async {
    Provider.of<TaskInfoPopUpProvider>(context, listen: false).setProgress(0);
    Provider.of<TaskInfoPopUpProvider>(context, listen: false)
        .show("Downloading ${encryptedFile.name}");

    double totalGetLen = 0;

    String docDir = GlobalData.gAppDocDir!.path;

    String tempPath = path.join(docDir, "ArthurMorgan", "Temp", "temp.meb");

    File tempFile = File(tempPath);

    tempFile.createSync(recursive: true);
    var stream = await GlobalData.gDriveManager!.downloadFile(encryptedFile);
    stream.listen((data) {
      tempFile.writeAsBytesSync(data, mode: FileMode.append);
      totalGetLen += data.length;
      log(totalGetLen.toString());
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .setProgress((totalGetLen / encryptedFile.size) * 100);
    }, onDone: () {
      log("Download (Save to disk)");
      Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();

      String savePath =
          path.join(docDir, "ArthurMorgan", "Downloads", encryptedFile.name);

      File saveFile = File(savePath);

      double totalGetLen = 0;

      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .show("Decrypting ${encryptedFile.name}");

      final port = ReceivePort();

      Isolate.spawn(GlobalData.gMorgan!.unpackVideo, {
        "tempFile": tempFile,
        "saveFile": saveFile,
        "port": port.sendPort,
      });

      port.listen((message) {
        log(message.toString());
        if (message == "UNPACK_VIDEO_DONE") {
          Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        } else {
          Provider.of<TaskInfoPopUpProvider>(context, listen: false)
              .setProgress(message);
        }
      });
    }, onError: (error) {
      log("Download (Save to disk) error");
      Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    });
  }

  void downloadAndDecryptImage(
      BuildContext context, GFile encryptedFile) async {
    Provider.of<TaskInfoPopUpProvider>(context, listen: false).setProgress(0);
    Provider.of<TaskInfoPopUpProvider>(context, listen: false)
        .show("Downloading ${encryptedFile.name}");

    double totalGetLen = 0;

    String docDir = GlobalData.gAppDocDir!.path;

    String tempPath = path.join(docDir, "ArthurMorgan", "Temp", "temp.meb");

    File tempFile = File(tempPath);

    tempFile.createSync(recursive: true);
    var stream = await GlobalData.gDriveManager!.downloadFile(encryptedFile);
    stream.listen((data) {
      tempFile.writeAsBytesSync(data, mode: FileMode.append);
      totalGetLen += data.length;
      log(totalGetLen.toString());
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .setProgress((totalGetLen / encryptedFile.size) * 100);
    }, onDone: () {
      log("Download (Save to disk)");
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .show("Decrypting ${encryptedFile.name}");

      String savePath =
          path.join(docDir, "ArthurMorgan", "Downloads", encryptedFile.name);

      File saveFile = File(savePath);

      double totalGetLen = 0;

      final port = ReceivePort();

      Isolate.spawn(GlobalData.gMorgan!.unpackImage, {
        "tempFile": tempFile,
        "saveFile": saveFile,
        "port": port.sendPort,
      });

      port.listen((message) {
        log(message.toString());
        if (message == "UNPACK_IMAGE_DONE") {
          Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
        } else {
          Provider.of<TaskInfoPopUpProvider>(context, listen: false)
              .setProgress(message);
        }
      }, onDone: () {
        Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
      });
    }, onError: (error) {
      log("Download (Save to disk) error");
      Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    });
  }

  void uploadFiles(BuildContext context, List<File> files) {
    totalFiles = files.length;
    currentFileIndex = 0;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentFileIndex == totalFiles) {
        log("all files done");
        timer.cancel();
      }

      if (encryptionState == EncryptionState.free) {
        if (lookupMimeType(files[currentFileIndex].path)!.startsWith("image")) {
          startImageEncryptionAndUpload(context, files[currentFileIndex]);
        } else if (lookupMimeType(files[currentFileIndex].path)!
            .startsWith("video")) {
          startVideoEncryptionAndUpload(context, files[currentFileIndex]);
        }
        currentFileIndex++;
      }
    });
  }

  get getEncryptionState {
    return encryptionState;
  }
}
